const mongoose = require('mongoose');
const Report = require('./models/Report');
const User = require('./models/User');
require('dotenv').config();

const addTestReports = async () => {
  try {
    await mongoose.connect(process.env.DB_URI);
    console.log('Connected to MongoDB');

    // Find or create a test user
    let testUser = await User.findOne({ email: 'test@example.com' });
    if (!testUser) {
      testUser = new User({
        name: 'Test User',
        email: 'test@example.com',
        mobile: '9876543210',
        password: 'password123'
      });
      await testUser.save();
      console.log('Created test user');
    }

    // Add test reports with Vijayawada locations
    const testReports = [
      {
        title: 'Road pothole issue',
        description: 'Large pothole on MG Road',
        location: {
          type: 'Point',
          coordinates: [80.6480, 16.5062] // [lng, lat] for Vijayawada
        },
        address: 'MG Road, Vijayawada',
        department: 'Roads',
        severity: 'HIGH',
        userId: testUser._id
      },
      {
        title: 'Water supply problem',
        description: 'No water supply in Benz Circle area',
        location: {
          type: 'Point',
          coordinates: [80.6320, 16.5180]
        },
        address: 'Benz Circle, Vijayawada',
        department: 'Water',
        severity: 'CRITICAL',
        userId: testUser._id
      },
      {
        title: 'Power outage',
        description: 'Frequent power cuts in Governorpet',
        location: {
          type: 'Point',
          coordinates: [80.6420, 16.5020]
        },
        address: 'Governorpet, Vijayawada',
        department: 'Electricity',
        severity: 'MEDIUM',
        userId: testUser._id
      }
    ];

    // Clear existing test reports
    await Report.deleteMany({ userId: testUser._id });
    console.log('Cleared existing test reports');

    // Insert new test reports
    const insertedReports = await Report.insertMany(testReports);
    console.log(`Added ${insertedReports.length} test reports with locations`);

    // Verify the reports
    const reportsWithLocation = await Report.find({
      location: { $exists: true, $ne: null }
    });
    console.log(`Total reports with location: ${reportsWithLocation.length}`);

    mongoose.disconnect();
    console.log('Test completed successfully');
  } catch (error) {
    console.error('Error:', error);
    mongoose.disconnect();
  }
};

addTestReports();