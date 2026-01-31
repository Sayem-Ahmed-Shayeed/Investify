const express = require('express');
const router = express.Router();
const spacesService = require('../services/spaces.service');

/**
 * POST /api/uploads/presigned-url
 * Generate a pre-signed URL for direct upload to DigitalOcean Spaces
 * 
 * The Flutter app:
 * 1. Requests a pre-signed URL from this endpoint
 * 2. Uploads the file directly to Spaces using the URL
 * 3. Creates a post with the returned public URL
 * 
 * This way, Spaces credentials NEVER touch the mobile app
 */
router.post('/presigned-url', async (req, res) => {
  try {
    const { fileType, mimeType } = req.body;
    const userId = req.user.uid;

    // Validate input
    if (!fileType || !['image', 'video'].includes(fileType)) {
      return res.status(400).json({ 
        error: 'Invalid fileType. Must be "image" or "video"' 
      });
    }

    if (!mimeType) {
      return res.status(400).json({ error: 'mimeType is required' });
    }

    // Generate pre-signed URL
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

/**
 * POST /api/uploads/batch-presigned-urls
 * Generate multiple pre-signed URLs at once (for gallery uploads)
 */
router.post('/batch-presigned-urls', async (req, res) => {
  try {
    const { files } = req.body; // Array of { fileType, mimeType }
    const userId = req.user.uid;

    if (!Array.isArray(files) || files.length === 0) {
      return res.status(400).json({ error: 'files array is required' });
    }

    // Limit batch size to prevent abuse
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

/**
 * DELETE /api/uploads/file
 * Delete a file from Spaces (for cleanup when post is deleted)
 */
router.delete('/file', async (req, res) => {
  try {
    const { publicUrl } = req.body;
    
    if (!publicUrl) {
      return res.status(400).json({ error: 'publicUrl is required' });
    }

    const fileKey = spacesService.extractFileKey(publicUrl);
    
    // Verify the file belongs to this user (key contains userId)
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
