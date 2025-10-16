const { MongoClient } = require('mongodb');
require('dotenv').config();

async function forceDropIndex() {
  const client = new MongoClient(process.env.DB_URI);
  
  try {
    await client.connect();
    console.log('Connected to MongoDB');
    
    const db = client.db('CivicResponses');
    const collection = db.collection('users');
    
    // List current indexes
    const indexes = await collection.indexes();
    console.log('Current indexes:', indexes.map(idx => idx.name));
    
    // Force drop uid_1 index
    try {
      await collection.dropIndex('uid_1');
      console.log('✅ Successfully dropped uid_1 index');
    } catch (error) {
      console.log('uid_1 index not found or already dropped');
    }
    
    // Verify indexes after drop
    const newIndexes = await collection.indexes();
    console.log('Remaining indexes:', newIndexes.map(idx => idx.name));
    
    console.log('Index cleanup completed!');
  } catch (error) {
    console.error('Error:', error);
  } finally {
    await client.close();
  }
}

forceDropIndex();