const express = require('express');
const jwt = require('jsonwebtoken');
const User = require('../models/User');
const multer = require('multer'); // Used for image upload

// --- CRITICAL IMPORTS ---
// Import the 'protect' middleware
const { protect } = require('../middleware/auth'); 
// Import Cloudinary helpers
const { cloudinary, formatBufferToDataUri } = require('../config/cloudinary'); 
// ---

const router = express.Router();
// Multer setup for image upload
const upload = multer({ storage: multer.memoryStorage() });

// Helper function to generate a JWT token
const signToken = (id) => {
    return jwt.sign({ id }, process.env.JWT_SECRET, {
        expiresIn: '7d' 
    });
};

// @route   POST /api/auth/signup
// @desc    Register user and get token
// @access  Public
router.post('/signup', async (req, res) => {
    try {
        const {name ,username, email, password } = req.body;

        let user = await User.findOne({ email });
        if (user) {
            return res.status(400).json({ message: 'User already exists' });
        }

        user = await User.create({
            name,
            username,
            email,
            password,
        });

        const token = signToken(user._id);

        res.status(201).json({
            token,
            user: {
                id: user._id,
                username: user.username,
                email: user.email,
            }
        });

    } catch (error) {
        console.error(error.message);
        if (error.name === 'ValidationError') {
            return res.status(400).json({ message: error.message });
        }
        res.status(500).send('Server Error during signup');
    }
});


// @route   POST /api/auth/login
// @desc    Authenticate user and get token
// @access  Public
router.post('/login', async (req, res) => {
    try {
        const { email, password } = req.body;

        const user = await User.findOne({ email }).select('+password');
        if (!user) {
            return res.status(400).json({ message: 'Invalid Credentials' });
        }

        const isMatch = await user.matchPassword(password);
        if (!isMatch) {
            return res.status(400).json({ message: 'Invalid Credentials' });
        }

        const token = signToken(user._id);

        // NOTE: We should send back the profilePicUrl here too if we load it from the User model!
        res.json({
            token,
            user: {
                id: user._id,
                username: user.username,
                email: user.email,
                profilePicUrl: user.profilePicUrl 
            }
        });

    } catch (error) {
        console.error(error.message);
        res.status(500).send('Server Error during login');
    }
});


// @route   PUT /api/auth/fcmtoken
// @desc    Save the Firebase device token for push notifications
// @access  Private (uses protect middleware)
router.put('/fcmtoken', protect, async (req, res) => {
    const { fcmToken } = req.body;
    
    try {
        await User.findByIdAndUpdate(
            req.user.id,
            { fcmToken: fcmToken },
            { new: true, runValidators: true }
        );

        res.status(200).json({ success: true, message: 'FCM token updated.' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server Error updating token.' });
    }
});


// --- NEW: PROFILE PICTURE UPLOAD ROUTE ---
// @route   PUT /api/auth/profilepic
// @desc    Upload and update user profile picture
// @access  Private
router.put('/profilepic', protect, upload.single('avatar'), async (req, res) => {
    if (!req.file) {
        return res.status(400).json({ message: 'Avatar image file is required' });
    }
    
    try {
        // Upload to Cloudinary
        const fileUri = formatBufferToDataUri(req);
        const uploadResponse = await cloudinary.uploader.upload(fileUri, {
            folder: "rentkaro_dp",
        });
        const profilePicUrl = uploadResponse.secure_url;
        
        // Update user document
        const user = await User.findByIdAndUpdate(
            req.user.id,
            { profilePicUrl },
            { new: true, runValidators: true }
        ).select('-password -fcmToken'); // Exclude sensitive fields

        res.status(200).json({ 
            success: true, 
            user: { id: user._id, profilePicUrl: user.profilePicUrl } // Send back the new URL
        });

    } catch (error) {
        console.error('DP Upload Error:', error);
        res.status(500).json({ message: 'Server Error during DP upload.' });
    }
});


module.exports = router;