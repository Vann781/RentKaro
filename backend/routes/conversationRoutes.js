const express = require('express');
const mongoose = require('mongoose');
const { protect } = require('../middleware/auth');

const Conversation = require('../models/Conversation');
const Message = require('../models/Message');

const router = express.Router();

// @route   POST /api/conversations/start
// @desc    Start or find a conversation between two users about an item
// @access  Private
router.post('/start', protect, async (req, res) => {
  const { itemId, ownerId } = req.body;
  const myId = req.user.id;

  // Don't let users start a chat with themselves
  if (ownerId === myId) {
    return res.status(400).json({ message: "You cannot start a chat with yourself." });
  }

  try {
    // 1. Check if a conversation already exists for this item + participants
    let conversation = await Conversation.findOne({
      item: itemId,
      participants: { $all: [myId, ownerId] },
    });

    // 2. If it exists, return it
    if (conversation) {
      return res.status(200).json(conversation);
    }

    // 3. If it doesn't exist, create a new one
    conversation = await Conversation.create({
      item: itemId,
      participants: [myId, ownerId],
      lastMessage: `Chat started about item...`,
      lastMessageSender: myId,
    });

    res.status(201).json(conversation);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Server error starting conversation." });
  }
});


// @route   GET /api/conversations/my
// @desc    Get all of the current user's conversations
// @access  Private
router.get('/my', protect, async (req, res) => {
  try {
    const conversations = await Conversation.find({
      participants: req.user.id, // Find all conversations I'm in
    })
      .populate({
        path: 'participants', // Populate participants' details
        select: 'username', // Only get their username
      })
      .populate({
        path: 'item', // Populate the item's details
        select: 'name imageUrl', // Get item name and image
      })
      .sort({ lastMessageAt: -1 }); // Show newest chats first

    res.status(200).json(conversations);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Server error fetching conversations." });
  }
});


// @route   GET /api/conversations/:id/messages
// @desc    Get all messages for a single conversation
// @access  Private
router.get('/:id/messages', protect, async (req, res) => {
  try {
    const messages = await Message.find({
      conversationId: req.params.id,
    })
    //   .populate('sender', 'username') // Get sender's username
      .sort({ createdAt: 'asc' }); // Show oldest messages first

    res.status(200).json(messages);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Server error fetching messages." });
  }
});

module.exports = router;