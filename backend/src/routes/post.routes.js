const express = require('express');
const router = express.Router();
const Post = require('../models/post.model');
const spacesService = require('../services/spaces.service');

/**
 * POST /api/posts
 * Create a new post
 */
router.post('/', async (req, res) => {
  try {
    const { caption, media, status, tags } = req.body;
    const userId = req.user.uid;

    // Validate caption
    if (!caption || caption.trim().length === 0) {
      return res.status(400).json({ error: 'Caption is required' });
    }

    // Validate media URLs belong to this user
    if (media && Array.isArray(media)) {
      for (const item of media) {
        if (!item.url.includes(userId)) {
          return res.status(403).json({ 
            error: 'Unauthorized media URL detected' 
          });
        }
      }
    }

    const post = new Post({
      userId,
      caption: caption.trim(),
      media: media || [],
      status: status || 'draft',
      tags: tags || [],
      publishedAt: status === 'published' ? new Date() : null
    });

    await post.save();

    res.status(201).json({
      success: true,
      data: post
    });

  } catch (error) {
    console.error('Error creating post:', error);
    res.status(500).json({ error: 'Failed to create post' });
  }
});

/**
 * GET /api/posts
 * Get posts (supports pagination and filtering)
 */
router.get('/', async (req, res) => {
  try {
    const { page = 1, limit = 20, status, userId: queryUserId } = req.query;
    const currentUserId = req.user.uid;

    const query = {};
    
    // If requesting own posts, allow all statuses
    // If requesting others' posts, only show published
    if (queryUserId === currentUserId) {
      if (status) query.status = status;
      query.userId = currentUserId;
    } else if (queryUserId) {
      query.userId = queryUserId;
      query.status = 'published';
    } else {
      // Feed - only published posts
      query.status = 'published';
    }

    const skip = (parseInt(page) - 1) * parseInt(limit);
    
    const [posts, total] = await Promise.all([
      Post.find(query)
        .sort({ publishedAt: -1, createdAt: -1 })
        .skip(skip)
        .limit(parseInt(limit))
        .lean(),
      Post.countDocuments(query)
    ]);

    res.json({
      success: true,
      data: posts,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / parseInt(limit))
      }
    });

  } catch (error) {
    console.error('Error fetching posts:', error);
    res.status(500).json({ error: 'Failed to fetch posts' });
  }
});

/**
 * GET /api/posts/:id
 * Get a single post by ID
 */
router.get('/:id', async (req, res) => {
  try {
    const post = await Post.findById(req.params.id);
    
    if (!post) {
      return res.status(404).json({ error: 'Post not found' });
    }

    // Only allow viewing non-published posts if owner
    if (post.status !== 'published' && post.userId !== req.user.uid) {
      return res.status(403).json({ error: 'Access denied' });
    }

    // Increment view count for published posts
    if (post.status === 'published') {
      post.views += 1;
      await post.save();
    }

    res.json({
      success: true,
      data: post
    });

  } catch (error) {
    console.error('Error fetching post:', error);
    res.status(500).json({ error: 'Failed to fetch post' });
  }
});

/**
 * PUT /api/posts/:id
 * Update a post
 */
router.put('/:id', async (req, res) => {
  try {
    const post = await Post.findById(req.params.id);
    
    if (!post) {
      return res.status(404).json({ error: 'Post not found' });
    }

    // Only owner can update
    if (post.userId !== req.user.uid) {
      return res.status(403).json({ error: 'Access denied' });
    }

    const { caption, media, status, tags } = req.body;

    // Update fields
    if (caption !== undefined) post.caption = caption.trim();
    if (media !== undefined) post.media = media;
    if (tags !== undefined) post.tags = tags;
    
    // Handle status change
    if (status !== undefined) {
      post.status = status;
      if (status === 'published' && !post.publishedAt) {
        post.publishedAt = new Date();
      }
    }

    await post.save();

    res.json({
      success: true,
      data: post
    });

  } catch (error) {
    console.error('Error updating post:', error);
    res.status(500).json({ error: 'Failed to update post' });
  }
});

/**
 * DELETE /api/posts/:id
 * Delete a post and its associated media
 */
router.delete('/:id', async (req, res) => {
  try {
    const post = await Post.findById(req.params.id);
    
    if (!post) {
      return res.status(404).json({ error: 'Post not found' });
    }

    // Only owner can delete
    if (post.userId !== req.user.uid) {
      return res.status(403).json({ error: 'Access denied' });
    }

    // Delete associated media files from Spaces
    for (const mediaItem of post.media) {
      try {
        await spacesService.deleteFile(mediaItem.fileKey);
      } catch (err) {
        console.error(`Failed to delete media file: ${mediaItem.fileKey}`, err);
        // Continue with other deletions even if one fails
      }
    }

    await Post.findByIdAndDelete(req.params.id);

    res.json({
      success: true,
      message: 'Post deleted successfully'
    });

  } catch (error) {
    console.error('Error deleting post:', error);
    res.status(500).json({ error: 'Failed to delete post' });
  }
});

/**
 * POST /api/posts/:id/like
 * Like/unlike a post
 */
router.post('/:id/like', async (req, res) => {
  try {
    const post = await Post.findById(req.params.id);
    
    if (!post) {
      return res.status(404).json({ error: 'Post not found' });
    }

    const userId = req.user.uid;
    const isLiked = post.likedBy.includes(userId);

    if (isLiked) {
      // Unlike
      post.likedBy = post.likedBy.filter(id => id !== userId);
      post.likes = Math.max(0, post.likes - 1);
    } else {
      // Like
      post.likedBy.push(userId);
      post.likes += 1;
    }

    await post.save();

    res.json({
      success: true,
      data: {
        liked: !isLiked,
        likes: post.likes
      }
    });

  } catch (error) {
    console.error('Error toggling like:', error);
    res.status(500).json({ error: 'Failed to update like' });
  }
});

module.exports = router;
