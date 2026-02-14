const mongoose = require('mongoose');

const CommentSchema = new mongoose.Schema({
    postId: {
        type: mongoose.Schema.Types.ObjectId,
        required: true,
        index: true
    },
    userId: {
        type: String,
        required: true,
        index: true
    },
    userName: {
        type: String,
        required: true,
        trim: true
    },
    userProfileImageUrl: {
        type: String
    },
    content: {
        type: String,
        required: true,
        maxlength: 2000,
        trim: true
    }
}, {
    timestamps: true
});

CommentSchema.index({ postId: 1, createdAt: -1 });

CommentSchema.set('toJSON', {
    transform: function (doc, ret) {
        ret.id = ret._id;
        delete ret._id;
        delete ret.__v;
        return ret;
    }
});

module.exports = mongoose.model('Comment', CommentSchema);
