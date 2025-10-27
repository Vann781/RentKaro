const mongoose = require('mongoose');

const RentalSchema = new mongoose.Schema({
    // Item Details
    item: {
        type: mongoose.Schema.ObjectId,
        ref: 'Item',
        required: true
    },
    
    // Users Involved
    owner: {
        type: mongoose.Schema.ObjectId,
        ref: 'User',
        required: true,
    },
    renter: {
        type: mongoose.Schema.ObjectId,
        ref: 'User',
        required: true,
    },

    // Transaction Details
    startDate: {
        type: Date,
        required: true
    },
    endDate: {
        type: Date,
        required: true
    },
    totalPrice: {
        type: Number,
        required: true
    },
    status: {
        type: String,
        enum: ['Pending', 'Active', 'Returned', 'Cancelled'],
        default: 'Pending'
    },
    
    // Metadata
    createdAt: {
        type: Date,
        default: Date.now
    }
});

module.exports = mongoose.model('Rental', RentalSchema);