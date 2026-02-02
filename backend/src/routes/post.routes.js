const express = require('express');
const router = express.Router();
const Post = require('../models/post.model');
const spacesService = require('../services/spaces.service');

router.post('/', async (req, res) => {
  try {
    const { caption, media, status, tags } = req.body;
    const userId = req.user.uid;

    if (!caption || caption.trim().length === 0) {
      return res.status(400).json({ error: 'Caption is required' });
    }

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

router.get('/', async (req, res) => {
  try {
    const { page = 1, limit = 20, status, userId: queryUserId } = req.query;
    const currentUserId = req.user.uid;

    const query = {};
    
    if (queryUserId === currentUserId) {
      if (status) query.status = status;
      query.userId = currentUserId;
    } else if (queryUserId) {
      query.userId = queryUserId;
      query.status = 'published';
    } else {
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

router.get('/:id', async (req, res) => {
  try {
    const post = await Post.findById(req.params.id);
    
    if (!post) {
      return res.status(404).json({ error: 'Post not found' });
    }

    if (post.status !== 'published' && post.userId !== req.user.uid) {
      return res.status(403).json({ error: 'Access denied' });
    }

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

router.put('/:id', async (req, res) => {
  try {
    const post = await Post.findById(req.params.id);
    
    if (!post) {
      return res.status(404).json({ error: 'Post not found' });
    }

    if (post.userId !== req.user.uid) {
      return res.status(403).json({ error: 'Access denied' });
    }

    const { caption, media, status, tags } = req.body;

    if (caption !== undefined) post.caption = caption.trim();
    if (media !== undefined) post.media = media;
    if (tags !== undefined) post.tags = tags;
    
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

router.delete('/:id', async (req, res) => {
  try {
    const post = await Post.findById(req.params.id);
    
    if (!post) {
      return res.status(404).json({ error: 'Post not found' });
    }

    if (post.userId !== req.user.uid) {
      return res.status(403).json({ error: 'Access denied' });
    }

    for (const mediaItem of post.media) {
      try {
        await spacesService.deleteFile(mediaItem.fileKey);
      } catch (err) {
        console.error(`Failed to delete media file: ${mediaItem.fileKey}`, err);
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

router.post('/:id/like', async (req, res) => {
  try {
    const post = await Post.findById(req.params.id);
    
    if (!post) {
      return res.status(404).json({ error: 'Post not found' });
    }

    const userId = req.user.uid;
    const isLiked = post.likedBy.includes(userId);

    if (isLiked) {
      post.likedBy = post.likedBy.filter(id => id !== userId);
      post.likes = Math.max(0, post.likes - 1);
    } else {
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
