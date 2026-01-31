const mongoose = require('mongoose');

const MediaSchema = new mongoose.Schema({
  url: { type: String, required: true },
  fileKey: { type: String, required: true },
  type: { type: String, enum: ['image', 'video'], required: true },
  mimeType: { type: String },
  thumbnailUrl: { type: String },
  order: { type: Number, default: 0 }
});

const PostSchema = new mongoose.Schema({
  userId: {
    type: String,
    required: true,
    index: true
  },
  caption: {
    type: String,
    required: true,
    maxlength: 5000,
    trim: true
  },
  media: [MediaSchema],
  status: {
    type: String,
    enum: ['draft', 'published', 'archived'],
    default: 'draft',
    index: true
  },
  likes: {
    type: Number,
    default: 0
  },
  comments: {
    type: Number,
    default: 0
  },
  shares: {
    type: Number,
    default: 0
  },
  views: {
    type: Number,
    default: 0
  },
  likedBy: [{
    type: String,
    index: true
  }],
  tags: [{
    type: String,
    lowercase: true,
    trim: true
  }],
  publishedAt: { type: Date },
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

PostSchema.index({ userId: 1, status: 1, createdAt: -1 });
PostSchema.index({ status: 1, publishedAt: -1 });
PostSchema.index({ tags: 1, status: 1 });

PostSchema.virtual('imageCount').get(function() {
  return this.media?.filter(m => m.type === 'image').length || 0;
});

PostSchema.virtual('videoCount').get(function() {
  return this.media?.filter(m => m.type === 'video').length || 0;
});

PostSchema.set('toJSON', {
  transform: function(doc, ret) {
    ret.id = ret._id;
    delete ret._id;
    delete ret.__v;
    if (ret.media) {
      ret.media = ret.media.map(m => ({
        url: m.url,
        type: m.type,
        thumbnailUrl: m.thumbnailUrl,
        order: m.order
      }));
    }
    return ret;
  }
});

module.exports = mongoose.model('Post', PostSchema);
