const mongoose = require('mongoose');

const ItemSchema = new mongoose.Schema({
    // --- Basic Item Information ---
    name: {
        type: String,
        required: [true, 'Please add a name for the item'],
        trim: true,
        maxlength: [100, 'Name can not be more than 100 characters']
    },
    description: {
        type: String,
        required: [true, 'Please add a description'],
        maxlength: [1000, 'Description can not be more than 1000 characters']
    },
    rentalPrice: {
        type: Number,
        required: [true, 'Please add a daily rental price'],
        min: [1, 'Price must be at least 1']
    },
    category: {
        type: String,
        required: [true, 'Please select a category'],
        enum: ['Tools', 'Electronics', 'Sports', 'Vehicles', 'Other']
    },

    // --- ADD THIS FIELD ---
    imageUrl: {
        type: String,
        required: [true, 'Please add an image URL']
    },
    // --- Ownership and Status ---
    owner: {
        // Reference to the User who listed the item
        type: mongoose.Schema.ObjectId,
        ref: 'User',
        required: true
    },
    isAvailable: {
        type: Boolean,
        default: true
    },
    // --- Location for Proximity Search (1km Radius Feature) ---
    location: {
        type: {
            type: String,
            enum: ['Point'], // GeoJSON type
            required: true
        },
        // Coordinates must be an array of [longitude, latitude]
        coordinates: {
            type: [Number],
            required: true
        },
        // Store the address text for display purposes
        formattedAddress: String,
    },
    // --- Metadata ---
    createdAt: {
        type: Date,
        default: Date.now
    }
});

// Create a geospatial index on the location field (2dsphere index)
// This is necessary to perform proximity queries (like the 1km radius search).
ItemSchema.index({ location: '2dsphere' });

module.exports = mongoose.model('Item', ItemSchema);
