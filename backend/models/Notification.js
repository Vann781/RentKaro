const mongoose = require('mongoose');

const NotificationSchema = new mongoose.Schema({
    // User who receives the notification
    recipient: {
        type: mongoose.Schema.ObjectId,
        ref: 'User',
        required: true,
    },
    // Type of notification (e.g., 'chat_message', 'rental_request')
    type: {
        type: String,
        enum: ['chat_message', 'rental_request', 'system', 'general'],
        required: true,
    },
    // Main text content
    title: {
        type: String,
        required: true,
    },
    body: {
        type: String,
        required: true,
    },
    // Optional link data (e.g., conversation ID, item ID)
    linkId: {
        type: String,
    },
    // Status
    isRead: {
        type: Boolean,
        default: false,
    },
    createdAt: {
        type: Date,
        default: Date.now,
    },
});

// Index for efficient lookup and sorting
NotificationSchema.index({ recipient: 1, createdAt: -1 }); 

module.exports = mongoose.model('Notification', NotificationSchema);