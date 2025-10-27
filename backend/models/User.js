const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const UserSchema = new mongoose.Schema({
    username: {
        type: String,
        required: [true, 'Please add a username'],
        unique: true,
        trim: true,
    },
    email: {
        type: String,
        required: [true, 'Please add an email'],
        unique: true,
        match: [
            /^\w+([.-]?\w+)*@\w+([.-]?\w+)*(\.\w{2,3})+$/,
            'Please fill a valid email address'
        ]
    },
    password: {
        type: String,
        required: [true, 'Please add a password'],
        minlength: 6,
        select: false // Do not return the password hash by default
    },
    // GeoJSON Point to store location for proximity search (1km radius)
 location: {
  type: {
    type: String, 
    enum: ['Point'],
    default: 'Point'  // <-- ADD THIS
  },
  coordinates: {
    type: [Number],
    default: [0, 0]   // <-- ADD THIS (sets default to [lng, lat])
  }
},
profilePicUrl: {
    type: String,
    default: 'https://via.placeholder.com/150.png?text=DP', // Default image
},
fcmToken: {
        type: String,
        required: false, // Token is optional
        select: false,
    },
    createdAt: {
        type: Date,
        default: Date.now
    }
});

// Create a geospatial index on the location field (2dsphere)
UserSchema.index({ location: '2dsphere' });

// Pre-save hook: Encrypt password before saving the user
UserSchema.pre('save', async function(next) {
    // Only run if password was modified
    if (!this.isModified('password')) {
        return next();
    }
    const salt = await bcrypt.genSalt(10);
    this.password = await bcrypt.hash(this.password, salt);
    next();
});

// Method to check hashed password validity
UserSchema.methods.matchPassword = async function(enteredPassword) {
    // 'this.password' needs 'select: true' for this to work, or we fetch it explicitly in the controller
    return await bcrypt.compare(enteredPassword, this.password);
};

module.exports = mongoose.model('User', UserSchema);
