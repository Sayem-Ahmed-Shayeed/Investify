const mongoose = require('mongoose');

const SandboxSchema = new mongoose.Schema({
    userId: {
        type: String,
        required: true,
        index: true
    },
    userEmail: {
        type: String,
        required: true
    },
    userName: {
        type: String,
        default: ''
    },
    caption: {
        type: String,
        required: true,
        maxlength: 5000
    },
    media: [{
        url: { type: String, required: true },
        type: { type: String, enum: ['image', 'video'], required: true },
        thumbnailUrl: { type: String }
    }],
    status: {
        type: String,
        enum: ['pending', 'reviewed', 'failed'],
        default: 'pending',
        index: true
    },
    feedback: {
        verdict: { type: String, enum: ['approved', 'needs_changes'] },
        summary: { type: String },
        suggestions: [{ type: String }],
        score: { type: Number, min: 0, max: 100 },
        reviewedAt: { type: Date }
    }
}, { timestamps: true });

// Ensure a user can only have one 'pending' submission at a time
SandboxSchema.index({ userId: 1, status: 1 }, {
    unique: true,
    partialFilterExpression: { status: 'pending' }
});

const Sandbox = mongoose.model('Sandbox', SandboxSchema);

module.exports = Sandbox;
