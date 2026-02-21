const express = require('express');
const router = express.Router();

// POST /api/sandbox/submit — receive submission and trigger n8n webhook
router.post('/submit', async (req, res) => {
  try {
    const { caption, media } = req.body;
    const userId = req.user.uid;
    const userEmail = req.user.email || '';
    const userName = req.user.name || '';

    if (!caption || !caption.trim()) {
      return res.status(400).json({ error: 'Caption is required' });
    }

    if (!Array.isArray(media) || media.length === 0) {
      return res.status(400).json({ error: 'At least one media file is required' });
    }

    const webhookUrl = process.env.N8N_SANDBOX_WEBHOOK_URL;
    if (!webhookUrl) {
      console.error('❌ N8N_SANDBOX_WEBHOOK_URL not configured');
      return res.status(500).json({ error: 'Review service is not configured' });
    }

    // Fire-and-forget POST to n8n webhook using native https
    const payload = JSON.stringify({
      userId,
      userEmail,
      userName,
      caption: caption.trim(),
      media,
      submittedAt: new Date().toISOString(),
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
      console.log(`✅ n8n webhook responded with status: ${webhookRes.statusCode}`);
    });

    webhookReq.on('error', (err) => {
      console.error('❌ Failed to trigger n8n webhook:', err.message);
    });

    webhookReq.write(payload);
    webhookReq.end();

    console.log(`✅ Sandbox submission triggered for user ${userId}`);

    res.json({
      success: true,
      message: 'Your content has been submitted for review. You will receive feedback via email within 5-7 minutes.',
    });

  } catch (error) {
    console.error('Error in sandbox submit:', error);
    res.status(500).json({ error: 'Failed to submit for review' });
  }
});

module.exports = router;
