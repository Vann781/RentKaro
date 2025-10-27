// config/cloudinary.js
const cloudinary = require('cloudinary').v2;
const Datauri = require('datauri/parser');
const path = require('path');

// Configure Cloudinary
cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET,
});

// Configure Datauri
const parser = new Datauri();

/**
 * @description Formats the buffer from multer into a data URI
 * @param {object} req - The request object (to get the file)
 * @returns {string} The data URI string
 */
const formatBufferToDataUri = (req) => {
  // Use the original file extension
  const fileExtension = path.extname(req.file.originalname).toString();
  return parser.format(fileExtension, req.file.buffer).content;
};

module.exports = { cloudinary, formatBufferToDataUri };