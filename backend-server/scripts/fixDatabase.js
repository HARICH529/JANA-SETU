const mongoose = require('mongoose');
require('dotenv').config();

async function fixDatabase() {
  try {
    await mongoose.connect(process.env.DB_URI);
    console.log('Connected to MongoDB');

    const db = mongoose.connection.db;
    
    // Drop the problematic uid index
    try {
      await db.collection('users').dropIndex('uid_1');
      console.log('✅ Dropped uid_1 index');
    } catch (error) {
      console.log('Index uid_1 does not exist or already dropped');
    }

    // Create proper sparse unique index for uid
    await db.collection('users').createIndex(
      { uid: 1 }, 
      { 
        unique: true, 
        sparse: true
      }
    );
    console.log('✅ Created proper uid index');

    // Remove any users with null uid (if any exist)
    const result = await db.collection('users').deleteMany({ uid: null });
    console.log(`✅ Removed ${result.deletedCount} users with null uid`);

    console.log('Database fixed successfully!');
    process.exit(0);
  } catch (error) {
    console.error('Error fixing database:', error);
    process.exit(1);
  }
}

fixDatabase();