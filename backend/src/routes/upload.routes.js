const express = require('express');
const router = express.Router();
const spacesService = require('../services/spaces.service');

router.post('/presigned-url', async (req, res) => {
  try {
    const { fileType, mimeType } = req.body;
    const userId = req.user.uid;

    if (!fileType || !['image', 'video', 'pdf'].includes(fileType)) {
      return res.status(400).json({
        error: 'Invalid fileType. Must be "image", "video", or "pdf"'
      });
    }

    if (!mimeType) {
      return res.status(400).json({ error: 'mimeType is required' });
    }

    const result = await spacesService.generateUploadUrl(fileType, mimeType, userId);

    res.json({
      success: true,
      data: result
    });

  } catch (error) {
    console.error('Error generating presigned URL:', error);
    res.status(400).json({ error: error.message });
  }
});

router.post('/batch-presigned-urls', async (req, res) => {
  try {
    const { files } = req.body;
    const userId = req.user.uid;

    if (!Array.isArray(files) || files.length === 0) {
      return res.status(400).json({ error: 'files array is required' });
    }

    if (files.length > 10) {
      return res.status(400).json({ error: 'Maximum 10 files per batch' });
    }

    const results = await Promise.all(
      files.map(async (file, index) => {
        try {
          const result = await spacesService.generateUploadUrl(
            file.fileType,
            file.mimeType,
            userId
          );
          return { success: true, index, ...result };
        } catch (err) {
          return { success: false, index, error: err.message };
        }
      })
    );

    res.json({
      success: true,
      data: results
    });

  } catch (error) {
    console.error('Error generating batch presigned URLs:', error);
    res.status(500).json({ error: 'Failed to generate upload URLs' });
  }
});

router.delete('/file', async (req, res) => {
  try {
    const { publicUrl } = req.body;

    if (!publicUrl) {
      return res.status(400).json({ error: 'publicUrl is required' });
    }

    const fileKey = spacesService.extractFileKey(publicUrl);

    if (!fileKey.includes(req.user.uid)) {
      return res.status(403).json({ error: 'Unauthorized to delete this file' });
    }

    await spacesService.deleteFile(fileKey);

    res.json({ success: true, message: 'File deleted' });

  } catch (error) {
    console.error('Error deleting file:', error);
    res.status(500).json({ error: 'Failed to delete file' });
  }
});

module.exports = router;
