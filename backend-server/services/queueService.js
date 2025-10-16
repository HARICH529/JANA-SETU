const Queue = require('bull');
const redis = require('redis');

// Create Redis connection
const redisClient = redis.createClient({
  url: process.env.REDIS_URL || 'redis://localhost:6379'
});

redisClient.on('error', (err) => {
  console.error('Redis Client Error:', err);
});

redisClient.on('connect', () => {
  console.log('Connected to Redis');
});

// Create ML classification queue
const mlClassificationQueue = new Queue('ML Classification', process.env.REDIS_URL || 'redis://localhost:6379');

// Add job to queue for ML classification
const addClassificationJob = async (reportData) => {
  try {
    const job = await mlClassificationQueue.add('classify-report', {
      reportId: reportData._id,
      description: reportData.description,
      imageUrl: reportData.image_url,
      title: reportData.title
    }, {
      attempts: 3,
      backoff: {
        type: 'exponential',
        delay: 2000,
      },
    });

    console.log(`Classification job added for report ${reportData._id}, Job ID: ${job.id}`);
    return job;
  } catch (error) {
    console.error('Error adding classification job:', error);
    throw error;
  }
};

// Initialize Redis connection
const initializeRedis = async () => {
  try {
    await redisClient.connect();
  } catch (error) {
    console.error('Failed to connect to Redis:', error);
  }
};

module.exports = {
  mlClassificationQueue,
  addClassificationJob,
  redisClient,
  initializeRedis
};