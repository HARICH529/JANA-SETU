const mongoose = require('mongoose');
const Admin = require('../models/Admin');
require('dotenv').config();

const createAdmin = async () => {
  try {
    await mongoose.connect(`${process.env.DB_URI}/CivicResponses`);
    
    const adminData = {
      email: 'hari@gmail.com',
      password: 'hari1234'
    };

    const existingAdmin = await Admin.findOne({ email: adminData.email });
    if (existingAdmin) {
      console.log('Admin already exists');
      return;
    }

    const admin = await Admin.create(adminData);
    console.log('Admin created successfully:', admin.email);
  } catch (error) {
    console.error('Error creating admin:', error);
  } finally {
    mongoose.disconnect();
  }
};

createAdmin();