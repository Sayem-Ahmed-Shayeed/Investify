const express = require('express');
const router = express.Router();
const User = require('../models/user.model');

router.post('/', async (req, res) => {
  try {
    const { name, email, age, nidCardUrl } = req.body;
    const uid = req.user.uid;

    if (!name || name.trim().length === 0) {
      return res.status(400).json({ error: 'Name is required' });
    }

    let user = await User.findOne({ uid });

    if (user) {
      user.name = name.trim();
      if (email) user.email = email;
      if (age) user.age = age;
      if (nidCardUrl) user.nidCardUrl = nidCardUrl;
      await user.save();
    } else {
      user = new User({
        uid,
        name: name.trim(),
        email: email || req.user.email,
        age,
        nidCardUrl
      });
      await user.save();
    }

    res.status(201).json({
      success: true,
      data: user
    });

  } catch (error) {
    console.error('Error creating/updating user:', error);
    res.status(500).json({ error: 'Failed to save user' });
  }
});

router.get('/me', async (req, res) => {
  try {
    const user = await User.findOne({ uid: req.user.uid });

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json({
      success: true,
      data: user
    });

  } catch (error) {
    console.error('Error fetching user:', error);
    res.status(500).json({ error: 'Failed to fetch user' });
  }
});

router.put('/me', async (req, res) => {
  try {
    const { name, age, bio, profileImageUrl } = req.body;
    const user = await User.findOne({ uid: req.user.uid });

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    if (name !== undefined) user.name = name.trim();
    if (age !== undefined) user.age = age;
    if (bio !== undefined) user.bio = bio;
    if (profileImageUrl !== undefined) user.profileImageUrl = profileImageUrl;

    await user.save();

    res.json({
      success: true,
      data: user
    });

  } catch (error) {
    console.error('Error updating user:', error);
    res.status(500).json({ error: 'Failed to update user' });
  }
});

router.get('/:uid', async (req, res) => {
  try {
    const user = await User.findOne({ uid: req.params.uid });

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json({
      success: true,
      data: {
        uid: user.uid,
        name: user.name,
        profileImageUrl: user.profileImageUrl,
        bio: user.bio
      }
    });

  } catch (error) {
    console.error('Error fetching user:', error);
    res.status(500).json({ error: 'Failed to fetch user' });
  }
});

module.exports = router;
