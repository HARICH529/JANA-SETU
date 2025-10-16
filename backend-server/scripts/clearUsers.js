const mongoose = require('mongoose');
require('dotenv').config();

async function clearUsers() {
  try {
    await mongoose.connect(process.env.DB_URI);
    console.log('Connected to MongoDB');

    const db = mongoose.connection.db;
    
    // Delete all users to start fresh
    const result = await db.collection('users').deleteMany({});
    console.log(`✅ Deleted ${result.deletedCount} users`);

    // Drop all indexes on users collection
    await db.collection('users').dropIndexes();
    console.log('✅ Dropped all indexes');

    // Recreate only necessary indexes
    await db.collection('users').createIndex({ email: 1 }, { unique: true });
    await db.collection('users').createIndex({ mobile: 1 });
    console.log('✅ Created new indexes');

    console.log('Users collection reset successfully!');
    process.exit(0);
  } catch (error) {
    console.error('Error:', error);
    process.exit(1);
  }
}

clearUsers();