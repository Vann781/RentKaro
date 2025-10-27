// const fs = require('fs');
// const express = require('express');
// const mongoose = require('mongoose');
// const dotenv = require('dotenv');
// const http = require('http');
// const { Server } = require('socket.io');

// // --- CRITICAL INITIALIZATION ---
// dotenv.config();

// // --- Firebase Admin Imports/Setup ---
// const admin = require('firebase-admin');
// const serviceAccountPath = './firebase-service-account.json';

// // Load and parse the service account file (handles newlines correctly)
// const serviceAccount = JSON.parse(fs.readFileSync(serviceAccountPath, 'utf8'));

// // Initialize Firebase Admin SDK
// admin.initializeApp({
//     credential: admin.credential.cert(serviceAccount)
// });
// // --- END FIREBASE SETUP ---

// // --- Model Imports ---
// const Message = require('./models/Message');
// const Conversation = require('./models/Conversation');
// const User = require('./models/User'); 

// // --- Route Imports ---
// const authRoutes = require('./routes/authRoutes');
// const itemRoutes = require('./routes/itemRoutes');
// const conversationRoutes = require('./routes/conversationRoutes');

// // --- Push Notification Sender Function ---
// const sendPushNotification = async (recipientId, senderUsername, messageContent) => {
//     try {
//         const recipient = await User.findById(recipientId).select('fcmToken');
//         const token = recipient?.fcmToken;

//         if (!token) {
//             return console.log(`No FCM token found for user ${recipientId}. Notification skipped.`);
//         }
        
//         // 1. Build the message object (using the official 'send' method structure)
//         const message = {
//             notification: {
//                 title: `New message from ${senderUsername}`,
//                 body: messageContent.length > 50 ? `${messageContent.substring(0, 50)}...` : messageContent,
//             },
//             data: {
//                 conversation_id: recipientId.toString(),
//                 type: 'chat_message',
//             },
//             token: token, // Specify the recipient token here
//         };

//         // 2. Send the message using the official 'send' method
//         await admin.messaging().send(message); 
//         console.log(`Push notification sent to ${recipientId}`);

//     } catch (error) {
//         console.error('Error sending push notification:', error);
//     }
// };
// // --- END Push Notification Sender Function ---

// // Initialize the app
// const app = express();
// const server = http.createServer(app);

// // Middleware
// app.use(express.json());

// // --- Socket.io Setup ---
// const io = new Server(server, {
//     cors: {
//         origin: '*',
//         methods: ['GET', 'POST'],
//     },
// });

// // --- Socket.io Logic (UPDATED with Push Notifications) ---
// io.on('connection', (socket) => {
//     console.log(`User connected: ${socket.id}`);

//     socket.on('join_room', (conversationId) => {
//         socket.join(conversationId);
//         console.log(`User ${socket.id} joined room: ${conversationId}`);
//     });

//     socket.on('send_message', async (data) => {
//         const { conversationId, senderId, content } = data;

//         try {
//             // 1. Save Message
//             const message = new Message({
//                 conversationId: conversationId,
//                 sender: senderId,
//                 content: content,
//             });
//             await message.save();
            
//             // 2. Update Conversation
//             await Conversation.findByIdAndUpdate(conversationId, {
//                 lastMessage: content,
//                 lastMessageSender: senderId,
//                 lastMessageAt: Date.now(),
//             });

//             // 3. Broadcast to others in the room
//             socket.to(conversationId).emit('receive_message', {
//                 conversationId: message.conversationId,
//                 senderId: message.sender,
//                 content: message.content,
//                 createdAt: message.createdAt,
//             });

//             // 4. FIND RECIPIENT AND SEND PUSH NOTIFICATION
//             const conversation = await Conversation.findById(conversationId).populate('participants', 'username');
            
//             const recipient = conversation.participants
//                 .find(p => p._id.toString() !== senderId.toString());
            
//             const sender = conversation.participants
//                 .find(p => p._id.toString() === senderId.toString());

//             if (recipient && sender) {
//                 sendPushNotification(recipient._id, sender.username, content);
//             }
//             // END PUSH NOTIFICATION LOGIC

//             console.log(`Message sent to room ${conversationId}: ${content}`);
//         } catch (error) {
//             console.error('Error saving or sending message:', error.message);
//         }
//     });

//     socket.on('disconnect', () => {
//         console.log('User disconnected', socket.id);
//     });
// });

// // --- Database Connection ---
// const connectDB = async () => {
//     const mongoUri = process.env.MONGO_URI || 'mongodb://localhost:27017/rentkaroDB';
//     try {
//         await mongoose.connect(mongoUri);
//         console.log('MongoDB Connected Successfully...');
//     } catch (err) {
//         console.error(err.message);
//         process.exit(1);
//     }
// };
// connectDB();

// // --- Basic Route ---
// app.get('/', (req, res) => res.send('RentKaro API Running'));

// // --- Define Routes ---
// app.use('/api/auth', authRoutes);
// app.use('/api/items', itemRoutes);
// app.use('/api/conversations', conversationRoutes);

// // --- Server Startup ---
// const PORT = process.env.PORT || 5000;
// server.listen(PORT, () => console.log(`Server started on port ${PORT}`));
const express = require('express');
const mongoose = require('mongoose');
const dotenv = require('dotenv');
const http = require('http');
const { Server } = require('socket.io');

// --- CRITICAL INITIALIZATION ---
dotenv.config();

// --- Firebase Admin Imports/Setup ---
const admin = require('firebase-admin');

// 1. Load JSON string from environment variable (from Render's UI)
const FIREBASE_ADMIN_CONFIG_STRING = process.env.FIREBASE_ADMIN_CONFIG;

// 2. Safely parse the JSON string and initialize Firebase Admin SDK
try {
    if (!FIREBASE_ADMIN_CONFIG_STRING) {
        throw new Error('FIREBASE_ADMIN_CONFIG environment variable is missing.');
    }
    
    // IMPORTANT: Firebase requires the private key to have literal \n characters.
    // We use .replace(/\\n/g, '\n') to convert the string literal "\\n" into the newline character "\n".
    const safeConfigString = FIREBASE_ADMIN_CONFIG_STRING.replace(/\\n/g, '\n');
    
    const serviceAccount = JSON.parse(safeConfigString);

    admin.initializeApp({
        credential: admin.credential.cert(serviceAccount)
    });
    console.log('Firebase Admin SDK Initialized Successfully from Environment.');
    
} catch (error) {
    console.error('FATAL ERROR: Failed to initialize Firebase Admin SDK from environment variable.');
    console.error(error);
    process.exit(1); // Exit process if critical config fails
}
// --- END FIREBASE SETUP ---

// --- Model Imports ---
const Message = require('./models/Message');
const Conversation = require('./models/Conversation');
const User = require('./models/User'); 

// --- Route Imports ---
const authRoutes = require('./routes/authRoutes');
const itemRoutes = require('./routes/itemRoutes');
const conversationRoutes = require('./routes/conversationRoutes');

// --- Push Notification Sender Function ---
const sendPushNotification = async (recipientId, senderUsername, messageContent) => {
    // ... (Your existing sendPushNotification logic remains the same) ...
    try {
        const recipient = await User.findById(recipientId).select('fcmToken');
        const token = recipient?.fcmToken;

        if (!token) {
            return console.log(`No FCM token found for user ${recipientId}. Notification skipped.`);
        }
        
        const message = {
            notification: {
                title: `New message from ${senderUsername}`,
                body: messageContent.length > 50 ? `${messageContent.substring(0, 50)}...` : messageContent,
            },
            data: {
                conversation_id: recipientId.toString(),
                type: 'chat_message',
            },
            token: token,
        };

        await admin.messaging().send(message); 
        console.log(`Push notification sent to ${recipientId}`);

    } catch (error) {
        console.error('Error sending push notification:', error);
    }
};
// --- END Push Notification Sender Function ---

// Initialize the app
const app = express();
const server = http.createServer(app);

// Middleware
app.use(express.json());

// --- Socket.io Setup ---
const io = new Server(server, {
    cors: {
        origin: '*',
        methods: ['GET', 'POST'],
    },
});

// --- Socket.io Logic (UPDATED with Push Notifications) ---
io.on('connection', (socket) => {
    // ... (Socket logic remains the same) ...
    socket.on('send_message', async (data) => {
        const { conversationId, senderId, content } = data;

        try {
            // 1. Save Message
            const message = new Message({ conversationId, sender: senderId, content });
            await message.save();
            
            // 2. Update Conversation
            await Conversation.findByIdAndUpdate(conversationId, { lastMessage: content, lastMessageSender: senderId, lastMessageAt: Date.now() });

            // 3. Broadcast
            socket.to(conversationId).emit('receive_message', { conversationId: message.conversationId, senderId: message.sender, content: message.content, createdAt: message.createdAt });

            // 4. FIND RECIPIENT AND SEND PUSH NOTIFICATION
            const conversation = await Conversation.findById(conversationId).populate('participants', 'username');
            const recipient = conversation.participants.find(p => p._id.toString() !== senderId.toString());
            const sender = conversation.participants.find(p => p._id.toString() === senderId.toString());

            if (recipient && sender) {
                sendPushNotification(recipient._id, sender.username, content);
            }

            console.log(`Message sent to room ${conversationId}: ${content}`);
        } catch (error) {
            console.error('Error saving or sending message:', error.message);
        }
    });

    socket.on('disconnect', () => {
        console.log('User disconnected', socket.id);
    });
});

// --- Database Connection ---
const connectDB = async () => {
    const mongoUri = process.env.MONGO_URI || 'mongodb://localhost:27017/rentkaroDB';
    try {
        await mongoose.connect(mongoUri);
        console.log('MongoDB Connected Successfully...');
    } catch (err) {
        console.error(err.message);
        process.exit(1);
    }
};
connectDB();

// --- Basic Route ---
app.get('/', (req, res) => res.send('RentKaro API Running'));

// --- Define Routes ---
app.use('/api/auth', authRoutes);
app.use('/api/items', itemRoutes);
app.use('/api/conversations', conversationRoutes);

// --- Server Startup ---
const PORT = process.env.PORT || 5000;
server.listen(PORT, () => console.log(`Server started on port ${PORT}`));