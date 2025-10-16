const mongoose = require('mongoose');
require('dotenv').config();

async function dropUidIndex() {
  try {
    await mongoose.connect(process.env.DB_URI);
    console.log('Connected to MongoDB');

    const db = mongoose.connection.db;
    
    // Drop the uid index completely
    try {
      await db.collection('users').dropIndex('uid_1');
      console.log('✅ Dropped uid_1 index successfully');
    } catch (error) {
      console.log('uid_1 index does not exist or already dropped');
    }

    // List all indexes to verify
    const indexes = await db.collection('users').indexes();
    console.log('Current indexes:', indexes.map(idx => idx.name));

    console.log('Index cleanup completed!');
    process.exit(0);
  } catch (error) {
    console.error('Error:', error);
    process.exit(1);
  }
}

dropUidIndex();