const mongoose = require('mongoose');
const Admin = require('../models/Admin');
require('dotenv').config();

const checkAdmin = async () => {
  try {
    await mongoose.connect(`${process.env.DB_URI}/CivicResponses`);
    
    const admins = await Admin.find().select('+password');
    console.log('All admins:', admins);
    
    const testAdmin = await Admin.findOne({ email: 'hari@gmail.com' }).select('+password');
    if (testAdmin) {
      console.log('Found admin:', testAdmin);
      const isValid = await testAdmin.comparePassword('hari1234');
      console.log('Password valid:', isValid);
    } else {
      console.log('Admin not found');
    }
  } catch (error) {
    console.error('Error:', error);
  } finally {
    mongoose.disconnect();
  }
};

checkAdmin();