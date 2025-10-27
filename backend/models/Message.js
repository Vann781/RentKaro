const mongoose = require('mongoose');

const MessageSchema = new mongoose.Schema({
  // --- THIS IS THE CHANGE ---
  // It now links to a specific Conversation
  conversationId: {
    type: mongoose.Schema.ObjectId,
    ref: 'Conversation',
    required: true,
  },
  // --- END CHANGE ---

  // The user who sent this message
  sender: {
    type: mongoose.Schema.ObjectId,
    ref: 'User',
    required: true,
  },
  
  // The actual text content
  content: {
    type: String,
    required: [true, 'Message content cannot be empty'],
    trim: true,
  },
}, {
  timestamps: true // Adds createdAt (which we use for message time)
});

module.exports = mongoose.model('Message', MessageSchema);