const mongoose = require('mongoose');

const MediaSchema = new mongoose.Schema({
  url: { type: String, required: true },
  fileKey: { type: String, required: true }, // For deletion purposes
  type: { type: String, enum: ['image', 'video'], required: true },
  mimeType: { type: String },
  thumbnailUrl: { type: String }, // For videos
  order: { type: Number, default: 0 }
});

const PostSchema = new mongoose.Schema({
  // Reference to Firebase user
  userId: {
    type: String,
    required: true,
    index: true
  },
  
  // Post content
  caption: {
    type: String,
    required: true,
    maxlength: 5000,
    trim: true
  },
  
  // Media attachments
  media: [MediaSchema],
  
  // Post status
  status: {
    type: String,
    enum: ['draft', 'published', 'archived'],
    default: 'draft',
    index: true
  },
  
  // Engagement metrics
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
  
  // Users who liked this post
  likedBy: [{
    type: String, // Firebase user IDs
    index: true
  }],
  
  // Tags/Categories
  tags: [{
    type: String,
    lowercase: true,
    trim: true
  }],
  
  // Timestamps
  publishedAt: { type: Date },
  
}, {
  timestamps: true, // Adds createdAt and updatedAt
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Index for efficient queries
PostSchema.index({ userId: 1, status: 1, createdAt: -1 });
PostSchema.index({ status: 1, publishedAt: -1 }); // For feed queries
PostSchema.index({ tags: 1, status: 1 });

// Virtual for media counts
PostSchema.virtual('imageCount').get(function() {
  return this.media?.filter(m => m.type === 'image').length || 0;
});

PostSchema.virtual('videoCount').get(function() {
  return this.media?.filter(m => m.type === 'video').length || 0;
});

// Transform output to hide internal fields
PostSchema.set('toJSON', {
  transform: function(doc, ret) {
    ret.id = ret._id;
    delete ret._id;
    delete ret.__v;
    // Don't expose file keys to clients
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
