const express = require('express');
const router = express.Router();

// ==============================================================================
// POST /api/enhance
// Proxy to OpenRouter API for grammar/spelling correction
// Keeps the API key secure on the server side
// ==============================================================================
router.post('/', async (req, res) => {
    try {
        const { text } = req.body;

        if (!text || !text.trim()) {
            return res.status(400).json({ error: 'Text is required' });
        }

        const apiKey = process.env.OPENROUTER_API_KEY;
        if (!apiKey) {
            console.error('❌ OPENROUTER_API_KEY not configured');
            return res.status(500).json({ error: 'Enhancement service is not configured' });
        }

        const payload = JSON.stringify({
            model: 'openai/gpt-oss-20b:free',
            messages: [
                {
                    role: 'system',
                    content: 'You are a writing assistant. Your ONLY job is to fix grammar, spelling, and punctuation errors in the user\'s text. Keep the original meaning, tone, and style exactly the same. Do NOT add new content, do NOT change the structure, do NOT add greetings or explanations. Return ONLY the corrected text, nothing else.'
                },
                {
                    role: 'user',
                    content: text.trim()
                }
            ],
            max_tokens: 2000,
            temperature: 0.3,
        });

        const response = await fetch('https://openrouter.ai/api/v1/chat/completions', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${apiKey}`,
                'HTTP-Referer': 'https://investify.app',
                'X-Title': 'Investify',
            },
            body: payload,
        });

        if (!response.ok) {
            const errorText = await response.text();
            console.error(`❌ OpenRouter API error: ${response.status} ${errorText}`);
            return res.status(500).json({ error: 'Enhancement failed' });
        }

        const data = await response.json();
        const enhancedText = data.choices?.[0]?.message?.content?.trim();

        if (!enhancedText) {
            return res.status(500).json({ error: 'No enhanced text received' });
        }

        console.log(`✅ Text enhanced successfully for user ${req.user.uid}`);
        res.json({ enhancedText });

    } catch (error) {
        console.error('Error enhancing text:', error);
        res.status(500).json({ error: 'Failed to enhance text' });
    }
});

module.exports = router;
