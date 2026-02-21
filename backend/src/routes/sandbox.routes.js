const express = require('express');
const router = express.Router();
const Sandbox = require('../models/sandbox.model');

// ==============================================================================
// 1. GET /api/sandbox/status
// Check if the user currently has a 'pending' submission
// ==============================================================================
router.get('/status', async (req, res) => {
  try {
    const userId = req.user.uid;
    const pendingSubmission = await Sandbox.findOne({ userId, status: 'pending' });

    if (pendingSubmission) {
      return res.json({
        isPending: true,
        submission: {
          id: pendingSubmission._id,
          submittedAt: pendingSubmission.createdAt,
        }
      });
    }

    res.json({ isPending: false });
  } catch (error) {
    console.error('Error checking sandbox status:', error);
    res.status(500).json({ error: 'Failed to check status' });
  }
});

// ==============================================================================
// 2. POST /api/sandbox/submit
// Receive submission, save to MongoDB as pending, trigger n8n
// ==============================================================================
router.post('/submit', async (req, res) => {
  try {
    const { caption, media } = req.body;
    const userId = req.user.uid;
    const userEmail = req.user.email || '';
    const userName = req.user.name || '';

    // Validation
    if (!caption || !caption.trim()) {
      return res.status(400).json({ error: 'Caption is required' });
    }
    if (!Array.isArray(media) || media.length === 0) {
      return res.status(400).json({ error: 'At least one media file is required' });
    }

    // Check configuration
    const webhookUrl = process.env.N8N_SANDBOX_WEBHOOK_URL;
    if (!webhookUrl) {
      console.error('❌ N8N_SANDBOX_WEBHOOK_URL not configured');
      return res.status(500).json({ error: 'Review service is not configured' });
    }

    // Check for existing pending submission
    const existingPending = await Sandbox.findOne({ userId, status: 'pending' });
    if (existingPending) {
      return res.status(400).json({
        error: 'You already have a submission pending review. Please wait for the email feedback before submitting another.'
      });
    }

    // 1. Save to MongoDB
    const submission = new Sandbox({
      userId,
      userEmail,
      userName,
      caption: caption.trim(),
      media,
      status: 'pending'
    });

    await submission.save();

    // 2. Fire-and-forget POST to n8n webhook using native https
    const payload = JSON.stringify({
      submissionId: submission._id.toString(),
      userId,
      userEmail,
      userName,
      caption: submission.caption,
      media,
      submittedAt: submission.createdAt,
    });

    const url = new URL(webhookUrl);
    const httpModule = url.protocol === 'https:' ? require('https') : require('http');

    const webhookReq = httpModule.request(url, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(payload),
      },
    }, (webhookRes) => {
      console.log(`✅ n8n webhook triggered for ID ${submission._id}, status: ${webhookRes.statusCode}`);
    });

    webhookReq.on('error', (err) => {
      console.error('❌ Failed to trigger n8n webhook:', err.message);
      // Even if webhook fails, we return success to user because DB save worked.
      // n8n might be temporarily down, we could implement a retry queue later.
    });

    webhookReq.write(payload);
    webhookReq.end();

    res.json({
      success: true,
      submissionId: submission._id,
      message: 'Your content has been submitted for review. You will receive feedback via email within 5-7 minutes.',
    });

  } catch (error) {
    if (error.code === 11000) { // MongoDB duplicate key error (duplicate pending)
      return res.status(400).json({
        error: 'You already have a submission pending review.'
      });
    }
    console.error('Error in sandbox submit:', error);
    res.status(500).json({ error: 'Failed to submit for review' });
  }
});

// ==============================================================================
// 3. POST /api/sandbox/:id/feedback
// Callback from n8n to update MongoDB status to 'reviewed'
// Note: This endpoint should NOT use the verifyFirebaseToken middleware 
// in server.js because n8n calls it, not the app. We use a secret key instead.
// ==============================================================================
router.post('/:id/feedback', async (req, res) => {
  try {
    const { id } = req.params;
    const { secret, verdict, score, summary, suggestions } = req.body;

    // Validate n8n secret
    const expectedSecret = process.env.N8N_CALLBACK_SECRET;
    if (!expectedSecret || secret !== expectedSecret) {
      console.warn(`⚠️ Unauthorized feedback attempt for Sandbox ID: ${id}`);
      return res.status(401).json({ error: 'Unauthorized' });
    }

    // Find and update submission
    const submission = await Sandbox.findById(id);
    if (!submission) {
      return res.status(404).json({ error: 'Submission not found' });
    }

    if (submission.status !== 'pending') {
      return res.status(400).json({ error: 'Submission is no longer pending' });
    }

    // Update with feedback
    submission.status = 'reviewed';
    submission.feedback = {
      verdict,
      score,
      summary,
      suggestions: Array.isArray(suggestions) ? suggestions : [],
      reviewedAt: new Date()
    };

    await submission.save();

    console.log(`✅ Sandbox feedback saved successfully for ID: ${id}`);
    res.json({ success: true, message: 'Feedback recorded' });

  } catch (error) {
    console.error('Error saving sandbox feedback:', error);
    res.status(500).json({ error: 'Failed to save feedback' });
  }
});

module.exports = router;
