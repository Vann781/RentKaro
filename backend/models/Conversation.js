const mongoose = require('mongoose');

const ConversationSchema = new mongoose.Schema({
  // An array of User IDs who are part of this chat
  participants: [
    {
      type: mongoose.Schema.ObjectId,
      ref: 'User',
      required: true,
    },
  ],

  // The item this chat is about
  item: {
    type: mongoose.Schema.ObjectId,
    ref: 'Item',
    required: true,
  },

  // --- These fields are for the "Chat List" screen ---
  
  // The text of the very last message
  lastMessage: {
    type: String,
    default: '',
  },
  
  // The user who sent the last message
  lastMessageSender: {
    type: mongoose.Schema.ObjectId,
    ref: 'User',
  },
  
  // The time of the last message (for sorting)
  lastMessageAt: {
    type: Date,
    default: Date.now,
  },
}, {
  timestamps: true // Adds createdAt and updatedAt
});

module.exports = mongoose.model('Conversation', ConversationSchema);