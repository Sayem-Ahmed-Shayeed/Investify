const express = require('express');
const router = express.Router();
const Comment = require('../models/comment.model');
const Post = require('../models/post.model');
const User = require('../models/user.model');

// GET /api/posts/:postId/comments — List comments (paginated, newest first)
router.get('/:postId/comments', async (req, res) => {
    try {
        const { page = 1, limit = 20 } = req.query;
        const { postId } = req.params;

        const post = await Post.findById(postId);
        if (!post) {
            return res.status(404).json({ error: 'Post not found' });
        }

        const skip = (parseInt(page) - 1) * parseInt(limit);

        const [comments, total] = await Promise.all([
            Comment.find({ postId })
                .sort({ createdAt: -1 })
                .skip(skip)
                .limit(parseInt(limit))
                .lean(),
            Comment.countDocuments({ postId })
        ]);

        // Transform _id to id for lean results
        const transformed = comments.map(c => ({
            ...c,
            id: c._id,
            _id: undefined,
            __v: undefined
        }));

        res.json({
            success: true,
            data: transformed,
            pagination: {
                page: parseInt(page),
                limit: parseInt(limit),
                total,
                pages: Math.ceil(total / parseInt(limit))
            }
        });

    } catch (error) {
        console.error('Error fetching comments:', error);
        res.status(500).json({ error: 'Failed to fetch comments' });
    }
});

// POST /api/posts/:postId/comments — Add a comment
router.post('/:postId/comments', async (req, res) => {
    try {
        const { postId } = req.params;
        const { content } = req.body;
        const userId = req.user.uid;

        if (!content || content.trim().length === 0) {
            return res.status(400).json({ error: 'Comment content is required' });
        }

        const post = await Post.findById(postId);
        if (!post) {
            return res.status(404).json({ error: 'Post not found' });
        }

        // Fetch user info for the comment
        const user = await User.findOne({ uid: userId });
        const userName = user ? user.name : 'User';
        const userProfileImageUrl = user ? user.profileImageUrl : null;

        const comment = new Comment({
            postId,
            userId,
            userName,
            userProfileImageUrl,
            content: content.trim()
        });

        await comment.save();

        // Increment comment count on the post
        post.comments = (post.comments || 0) + 1;
        await post.save();

        res.status(201).json({
            success: true,
            data: comment,
            commentCount: post.comments
        });

    } catch (error) {
        console.error('Error adding comment:', error);
        res.status(500).json({ error: 'Failed to add comment' });
    }
});

// DELETE /api/posts/:postId/comments/:commentId — Delete own comment
router.delete('/:postId/comments/:commentId', async (req, res) => {
    try {
        const { postId, commentId } = req.params;
        const userId = req.user.uid;

        const comment = await Comment.findById(commentId);
        if (!comment) {
            return res.status(404).json({ error: 'Comment not found' });
        }

        if (comment.userId !== userId) {
            return res.status(403).json({ error: 'Access denied' });
        }

        await Comment.findByIdAndDelete(commentId);

        // Decrement comment count on the post
        const post = await Post.findById(postId);
        if (post) {
            post.comments = Math.max(0, (post.comments || 0) - 1);
            await post.save();
        }

        res.json({
            success: true,
            message: 'Comment deleted successfully',
            commentCount: post ? post.comments : 0
        });

    } catch (error) {
        console.error('Error deleting comment:', error);
        res.status(500).json({ error: 'Failed to delete comment' });
    }
});

module.exports = router;
