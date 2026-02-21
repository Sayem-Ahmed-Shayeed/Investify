const express = require('express');
const router = express.Router();
const Sandbox = require('../models/sandbox.model');

// ==============================================================================
// POST /api/sandbox/webhook/:id/feedback
// Callback from n8n to update MongoDB status to 'reviewed'
// Note: This endpoint does NOT use Firebase auth because n8n calls it.
// It relies on N8N_CALLBACK_SECRET.
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
