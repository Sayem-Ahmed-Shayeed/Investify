const mongoose = require('mongoose');

const usersDb = mongoose.connection.useDb('users');

const UserSchema = new mongoose.Schema({
  uid: {
    type: String,
    required: true,
    unique: true,
    index: true
  },
  name: {
    type: String,
    required: true,
    trim: true,
    maxlength: 100
  },
  email: {
    type: String,
    required: true,
    trim: true,
    lowercase: true
  },
  age: {
    type: Number,
    min: 13,
    max: 120
  },
  nidCardUrl: {
    type: String
  },
  profileImageUrl: {
    type: String
  },
  bio: {
    type: String,
    maxlength: 500
  }
}, {
  timestamps: true
});

UserSchema.set('toJSON', {
  transform: function(doc, ret) {
    ret.id = ret._id;
    delete ret._id;
    delete ret.__v;
    return ret;
  }
});

module.exports = usersDb.model('User', UserSchema, 'user_list');
