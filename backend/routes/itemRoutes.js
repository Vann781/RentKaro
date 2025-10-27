// const express = require('express');
// const mongoose = require('mongoose');
// const Item = require('../models/Item');
// const { protect } = require('../middleware/auth');
// const multer = require('multer');
// const moment = require('moment'); 
// const Rental = require('../models/Rental');

// // --- NEW IMPORTS ---
// // Import the Cloudinary config we created
// const { cloudinary, formatBufferToDataUri } = require('../config/cloudinary');
// // ---

// const router = express.Router();

// const storage = multer.memoryStorage();
// const upload = multer({ storage: storage });

// const ONE_KILOMETER_IN_METERS = 1000;

// // @route   POST /api/items
// // @desc    Create a new rental item listing
// // @access  Private
// //
// // --- V V V THIS ROUTE IS UPDATED V V V ---
// //
// router.post('/', protect, upload.single('image'), async (req, res) => {
//     try {
//         const { name, description, rentalPrice, category, formattedAddress, latitude, longitude } = req.body;

//         if (!req.file) {
//              return res.status(400).json({ message: 'Image file is required' });
//         }
        
//         // --- 1. Format and Upload to Cloudinary ---
//         const fileUri = formatBufferToDataUri(req);
//         const uploadResponse = await cloudinary.uploader.upload(fileUri, {
//             folder: "rentkaro_items", // Optional: organizes files in Cloudinary
//         });
        
//         // --- 2. Get the real image URL ---
//         const imageUrl = uploadResponse.secure_url;
//         // ---

//         const item = await Item.create({
//             owner: req.user.id,
//             name,
//             description,
//             rentalPrice,
//             category,
//             imageUrl: imageUrl, // <-- Use the REAL URL
//             location: {
//                 type: 'Point',
//                 coordinates: [longitude, latitude], 
//             },
//             formattedAddress,
//         });

//         res.status(201).json({
//             success: true,
//             data: item
//         });

//     } catch (error) {
//         console.error('Error during item creation:', error);
//         if (error.name === 'ValidationError') {
//             return res.status(400).json({ message: error.message });
//         }
//         // Check for Cloudinary errors
//         if (error.http_code) {
//              return res.status(error.http_code).json({ message: 'Error uploading image to cloud.' });
//         }
//         res.status(500).json({ message: 'Server Error during item creation' });
//     }
// });


// // @route   GET /api/items/nearby
// // (This route is unchanged from your code)
// router.get('/nearby', protect, async (req, res) => {
//     try {
//         const { lat, lng } = req.query;

//         if (!lat || !lng) {
//             return res.status(400).json({ message: 'Missing location query parameters (lat, lng).' });
//         }

//         const userLatitude = parseFloat(lat);
//         const userLongitude = parseFloat(lng);

//         const nearbyItems = await Item.aggregate([
//             {
//                 $geoNear: {
//                     near: {
//                         type: 'Point',
//                         coordinates: [userLongitude, userLatitude]
//                     },
//                     distanceField: "distance",
//                     maxDistance: ONE_KILOMETER_IN_METERS,
//                     query: {
//                         isAvailable: true,
//                         owner: { $ne: new mongoose.Types.ObjectId(req.user.id) }
//                     },
//                     spherical: true
//                 }
//             },
//             {
//                 $lookup: {
//                     from: "users",
//                     localField: "owner",
//                     foreignField: "_id",
//                     as: "ownerDetails"
//                 }
//             },
//             {
//                 $project: {
//                     _id: 1,
//                     title: "$name",
//                     description: 1,
//                     pricePerDay: "$rentalPrice",
//                     category: 1,
//                     imageUrl: 1,
//                     isAvailable: 1,
//                     location: 1,
//                     distance: 1,
//                     ownerUsername: { $arrayElemAt: ["$ownerDetails.username", 0] },
//                     ownerId: "$owner",
//                 }
//             },
//             { $limit: 50 }
//         ]);

//         res.status(200).json({
//             success: true,
//             count: nearbyItems.length,
//             data: nearbyItems
//         });

//     } catch (error) {
//         console.error(error);
//         res.status(500).json({ message: 'Server Error during nearby item search' });
//     }
// });


// // @route   GET /api/items/my
// // @desc    Get all items owned by the authenticated user
// // (This route is unchanged from your code)
// router.get('/my', protect, async (req, res) => {
//     try {
//         // We use an aggregation to match the data shape of the 'nearby' route
//         const myItems = await Item.aggregate([
//             {
//                 // 1. Find items owned by the current user AND ONLY those that are available/listed
//                 $match: {
//                     owner: new mongoose.Types.ObjectId(req.user.id),
//                     isAvailable: true // <-- CRITICAL: ADD THIS FILTER
//                 }
//             },
//             {
//                 // 2. Look up the owner's details (even though it's us)
//                 $lookup: {
//                     from: "users", 
//                     localField: "owner",
//                     foreignField: "_id",
//                     as: "ownerDetails"
//                 }
//             },
//             {
//                 // 3. Reshape the data
//                 $project: {
//                     _id: 1,
//                     title: "$name", // Rename 'name' to 'title'
//                     description: 1,
//                     pricePerDay: "$rentalPrice", // Rename 'rentalPrice'
//                     category: 1,
//                     imageUrl: 1,
//                     isAvailable: 1,
//                     location: 1,
//                     distance: { $literal: 0 }, // Distance is 0 for your own items
//                     ownerUsername: { $arrayElemAt: ["$ownerDetails.username", 0] },
//                     ownerId: "$owner",
//                 }
//             },
//             {
//                 // 4. Sort by newest first
//                 $sort: { createdAt: -1 } 
//             }
//         ]);

//         res.status(200).json({
//             success: true,
//             count: myItems.length,
//             data: myItems
//         });

//     } catch (error) {
//         console.error(error);
//         res.status(500).json({ message: 'Server Error while fetching user items' });
//     }
// });

// // routes/itemRoutes.js (Add this route)

// // // @route   PUT /api/items/:id/status
// // // @desc    Toggle item's listing status (isAvailable)
// // // @access  Private
// // router.put('/:id/status', protect, async (req, res) => {
// //     const { isAvailable } = req.body;

// //     try {
// //         const item = await Item.findById(req.params.id);

// //         if (!item) {
// //             return res.status(404).json({ message: 'Item not found' });
// //         }
// //         // Ensure only the owner can change the status
// //         if (item.owner.toString() !== req.user.id) {
// //             return res.status(401).json({ message: 'Not authorized to change this item.' });
// //         }

// //         item.isAvailable = isAvailable; // Set the new status
// //         await item.save();

// //         res.status(200).json({ success: true, data: item });

// //     } catch (error) {
// //         console.error(error);
// //         res.status(500).json({ message: 'Server Error during status update.' });
// //     }
// // });
// // @route   PUT /api/items/:id/status
// // @desc    Toggle item's listing status (isAvailable)
// // @access  Private
// router.put('/:id/status', protect, async (req, res) => {
//     // The value received (true or false)
//     const { isAvailable } = req.body; 

//     try {
//         // Use updateOne to perform a direct update based on the item ID and owner ID
//         const result = await Item.updateOne(
//             {
//                 _id: req.params.id,
//                 owner: req.user.id // Security check: Ensure only the owner can update
//             },
//             {
//                 $set: { isAvailable: isAvailable } // Use $set to explicitly update the field
//             }
//         );

//         // Check if the item was actually updated
//         if (result.matchedCount === 0) {
//             // Item not found or owner didn't match
//             return res.status(404).json({ message: 'Item not found or unauthorized to modify.' });
//         }
        
//         if (result.modifiedCount === 0) {
//             // Item status was already the value being sent (e.g., trying to unlist an unlisted item)
//             return res.status(200).json({ success: true, message: 'Status already set.' });
//         }

//         res.status(200).json({ success: true, message: 'Status updated successfully.' });

//     } catch (error) {
//         console.error('Error during status update:', error);
//         res.status(500).json({ message: 'Server Error during status update.' });
//     }
// });


// // @route   POST /api/items/:id/rent
// // @desc    Initiate a rental transaction for a specific item
// // @access  Private (Renter needs to be logged in)
// router.post('/:id/rent', protect, async (req, res) => {
//     const itemId = req.params.id;
//     const renterId = req.user.id; 
    
//     // We expect dates as ISO strings from the frontend
//     const { startDate, endDate } = req.body; 

//     try {
//         // 1. Get Item details and ownership check
//         const item = await Item.findById(itemId);
        
//         if (!item || !item.isAvailable) {
//             return res.status(404).json({ message: 'Item not found or unavailable.' });
//         }
//         if (item.owner.toString() === renterId) {
//             return res.status(400).json({ message: 'You cannot rent your own item.' });
//         }

//         // 2. Calculate duration and total price
//         const start = moment(startDate);
//         const end = moment(endDate);
//         const durationInDays = end.diff(start, 'days') + 1; // +1 to include both start and end days

//         if (durationInDays <= 0) {
//             return res.status(400).json({ message: 'End date must be after or same as start date.' });
//         }

//         const totalPrice = item.rentalPrice * durationInDays;

//         // 3. Create the Rental record
//         const rental = await Rental.create({
//             item: itemId,
//             owner: item.owner,
//             renter: renterId,
//             startDate,
//             endDate,
//             totalPrice,
//             status: 'Active' // Assuming payment/agreement happens immediately
//         });

//         // 4. Mark the Item as unavailable
//         item.isAvailable = false;
//         await item.save();

//         res.status(201).json({
//             success: true,
//             message: 'Rental initiated successfully.',
//             data: rental
//         });

//     } catch (error) {
//         console.error('Rental Initiation Error:', error);
//         res.status(500).json({ message: 'Server Error during rental initiation.' });
//     }
// });

// module.exports = router;

const express = require('express');
const mongoose = require('mongoose');
const Item = require('../models/Item');
const { protect } = require('../middleware/auth');
const multer = require('multer');
const moment = require('moment'); // For date calculations
const Rental = require('../models/Rental'); // For rental transactions

// --- CRITICAL IMPORTS ---
const { cloudinary, formatBufferToDataUri } = require('../config/cloudinary');
// Import the centralized notification sender utility
const { sendPushNotification } = require('../utils/notificationSender'); 
// ---

const router = express.Router();

const storage = multer.memoryStorage();
const upload = multer({ storage: storage });

const ONE_KILOMETER_IN_METERS = 1000;

// @route   POST /api/items
// @desc    Create a new rental item listing
// @access  Private
router.post('/', protect, upload.single('image'), async (req, res) => {
    try {
        const { name, description, rentalPrice, category, formattedAddress, latitude, longitude } = req.body;

        if (!req.file) {
             return res.status(400).json({ message: 'Image file is required' });
        }
        
        // Upload to Cloudinary and get URL
        const fileUri = formatBufferToDataUri(req);
        const uploadResponse = await cloudinary.uploader.upload(fileUri, {
            folder: "rentkaro_items",
        });
        const imageUrl = uploadResponse.secure_url;

        const item = await Item.create({
            owner: req.user.id,
            name,
            description,
            rentalPrice,
            category,
            imageUrl: imageUrl, 
            location: {
                type: 'Point',
                coordinates: [longitude, latitude], 
            },
            formattedAddress,
        });

        res.status(201).json({ success: true, data: item });

    } catch (error) {
        console.error('Error during item creation:', error);
        if (error.name === 'ValidationError') {
            return res.status(400).json({ message: error.message });
        }
        if (error.http_code) {
             return res.status(error.http_code).json({ message: 'Error uploading image to cloud.' });
        }
        res.status(500).json({ message: 'Server Error during item creation' });
    }
});


// @route   GET /api/items/nearby
router.get('/nearby', protect, async (req, res) => {
    try {
        const { lat, lng } = req.query;

        if (!lat || !lng) {
            return res.status(400).json({ message: 'Missing location query parameters (lat, lng).' });
        }

        const userLatitude = parseFloat(lat);
        const userLongitude = parseFloat(lng);

        const nearbyItems = await Item.aggregate([
            {
                $geoNear: {
                    near: { type: 'Point', coordinates: [userLongitude, userLatitude] },
                    distanceField: "distance",
                    maxDistance: ONE_KILOMETER_IN_METERS,
                    query: {
                        isAvailable: true,
                        owner: { $ne: new mongoose.Types.ObjectId(req.user.id) }
                    },
                    spherical: true
                }
            },
            {
                $lookup: { from: "users", localField: "owner", foreignField: "_id", as: "ownerDetails" }
            },
            {
                $project: {
                    _id: 1, title: "$name", description: 1, pricePerDay: "$rentalPrice", category: 1, imageUrl: 1,
                    isAvailable: 1, location: 1, distance: 1,
                    ownerUsername: { $arrayElemAt: ["$ownerDetails.username", 0] },
                    ownerId: "$owner",
                }
            },
            { $limit: 50 }
        ]);

        res.status(200).json({ success: true, count: nearbyItems.length, data: nearbyItems });

    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server Error during nearby item search' });
    }
});


// @route   GET /api/items/my
router.get('/my', protect, async (req, res) => {
    try {
        const myItems = await Item.aggregate([
            {
                $match: {
                    owner: new mongoose.Types.ObjectId(req.user.id),
                    isAvailable: true
                }
            },
            {
                $lookup: { from: "users", localField: "owner", foreignField: "_id", as: "ownerDetails" }
            },
            {
                $project: {
                    _id: 1, title: "$name", description: 1, pricePerDay: "$rentalPrice", category: 1, imageUrl: 1,
                    isAvailable: 1, location: 1, distance: { $literal: 0 },
                    ownerUsername: { $arrayElemAt: ["$ownerDetails.username", 0] },
                    ownerId: "$owner",
                }
            },
            { $sort: { createdAt: -1 } }
        ]);

        res.status(200).json({ success: true, count: myItems.length, data: myItems });

    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server Error while fetching user items' });
    }
});


// @route   PUT /api/items/:id/status
// @desc    Toggle item's listing status (isAvailable)
// @access  Private
router.put('/:id/status', protect, async (req, res) => {
    const { isAvailable } = req.body; 

    try {
        const result = await Item.updateOne(
            {
                _id: req.params.id,
                owner: req.user.id
            },
            {
                $set: { isAvailable: isAvailable }
            }
        );

        if (result.matchedCount === 0) {
            return res.status(404).json({ message: 'Item not found or unauthorized to modify.' });
        }
        
        if (result.modifiedCount === 0) {
            return res.status(200).json({ success: true, message: 'Status already set.' });
        }

        res.status(200).json({ success: true, message: 'Status updated successfully.' });

    } catch (error) {
        console.error('Error during status update:', error);
        res.status(500).json({ message: 'Server Error during status update.' });
    }
});


// @route   POST /api/items/:id/rent
// @desc    Initiate a rental transaction for a specific item
// @access  Private (Renter needs to be logged in)
router.post('/:id/rent', protect, async (req, res) => {
    const itemId = req.params.id;
    const renterId = req.user.id; 
    
    // We expect dates as ISO strings from the frontend
    const { startDate, endDate } = req.body; 

    try {
        // 1. Get Item details and ownership check. Populate owner for notification use.
        const item = await Item.findById(itemId).populate('owner', 'username'); 
        
        if (!item || !item.isAvailable) {
            return res.status(404).json({ message: 'Item not found or unavailable.' });
        }
        if (item.owner._id.toString() === renterId) {
            return res.status(400).json({ message: 'You cannot rent your own item.' });
        }

        // 2. Calculate duration and total price
        const start = moment(startDate);
        const end = moment(endDate);
        const durationInDays = end.diff(start, 'days') + 1;

        if (durationInDays <= 0) {
            return res.status(400).json({ message: 'End date must be after or same as start date.' });
        }

        const totalPrice = item.rentalPrice * durationInDays;

        // 3. Create the Rental record
        const rental = await Rental.create({
            item: itemId,
            owner: item.owner._id,
            renter: renterId,
            startDate,
            endDate,
            totalPrice,
            status: 'Active'
        });

        // 4. Mark the Item as unavailable
        item.isAvailable = false;
        await item.save();
        
        // 5. SEND PUSH NOTIFICATION TO THE OWNER
        const renterUsername = req.user.username; // Username from the protect middleware
        
        await sendPushNotification(
            item.owner._id, // Recipient: Owner's ID
            `RENTAL REQUEST: ${item.name}`, // Title
            `${renterUsername} wants to rent your ${item.name}! Total: $${totalPrice.toFixed(2)}.`, // Body
            item._id // Pass item ID as the data link (or conversation ID if one was created)
        );

        res.status(201).json({
            success: true,
            message: 'Rental initiated successfully.',
            data: rental
        });

    } catch (error) {
        console.error('Rental Initiation Error:', error);
        res.status(500).json({ message: 'Server Error during rental initiation.' });
    }
});


module.exports = router;