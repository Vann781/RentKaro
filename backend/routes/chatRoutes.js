const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/auth'); // Import the entire module exports
const protect = authMiddleware.protect || authMiddleware; // Safely get the protect function
const Message = require('../models/Message'); 

// @desc    Get chat history for a specific room
// @route   GET /api/chat/:roomId
// @access  Private (requires user authentication)
router.get('/:roomId', protect, async (req, res) => {
    try {
        const { roomId } = req.params;
        // In a real application, you would also check if the authenticated user
        // is authorized to view this specific roomId (i.e., if they are a participant).

        // Fetch messages for the room, sort by creation date (oldest first)
        const messages = await Message.find({ roomId })
            .sort({ createdAt: 1 }) // 1 means ascending (oldest first)
            .limit(100)
            .populate('sender', 'name') // Optionally populate sender's name if needed later
            .exec(); // Execute the query

        // Send the message history
        res.json(messages);
    } catch (error) {
        console.error('Error fetching chat history:', error.message);
        res.status(500).json({ msg: 'Server Error: Could not fetch chat history.' });
    }
});

module.exports = router;
