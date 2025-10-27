const admin = require('firebase-admin');
const User = require('../models/User');
const Notification = require('../models/Notification'); // <-- NEW IMPORT

// ... (sendPushNotification function definition) ...

const sendPushNotification = async (recipientId, title, body, linkId, type = 'general') => { // <-- UPDATED PARAMS
    try {
        // 1. SAVE RECORD TO DATABASE
        await Notification.create({
            recipient: recipientId,
            title: title,
            body: body,
            linkId: linkId,
            type: type, // e.g., 'chat_message' or 'rental_request'
        });
        console.log(`Notification record saved for user ${recipientId}. Type: ${type}`);


        // 2. SEND PUSH NOTIFICATION (FCM Logic remains the same)
        const recipient = await User.findById(recipientId).select('fcmToken');
        const token = recipient?.fcmToken;

        if (!token) {
            return console.log(`No FCM token found for user ${recipientId}. Notification skipped.`);
        }
        
        const message = {
            notification: {
                title: title,
                body: body.length > 50 ? `${body.substring(0, 50)}...` : body,
                sound: 'default',
            },
            data: {
                type: type,
                link_id: linkId ? linkId.toString() : '',
            },
            token: token,
        };

        await admin.messaging().send(message);
        console.log(`Push notification sent to ${recipientId}`);

    } catch (error) {
        console.error('Error sending push notification:', error);
    }
};

module.exports = { sendPushNotification };