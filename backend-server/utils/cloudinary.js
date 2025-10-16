const cloudinary = require('cloudinary').v2;
const fs = require('fs');

cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_SECRET_KEY,
});

const cloudinaryUpload = async (filePath) => {
  try {
    if (!filePath) return null;

    const response = await cloudinary.uploader.upload(filePath, {
      resource_type: 'auto',
    });

    // Clean up local file after successful upload
    fs.unlinkSync(filePath);

    // Return only useful info
    return {
      url: response.secure_url,
      public_id: response.public_id,
      format: response.format,
      resource_type: response.resource_type,
    };
  } catch (error) {
    console.error("Cloudinary upload error:", error.message);
    if (fs.existsSync(filePath)) fs.unlinkSync(filePath); // cleanup
    return null;
  }
};

module.exports = cloudinaryUpload;
