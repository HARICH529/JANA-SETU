const redis = require('redis');

class MLService {
  constructor() {
    this.redisClient = redis.createClient({
      url: process.env.REDIS_URL || 'redis://localhost:6379'
    });
    
    this.redisClient.on('error', (err) => {
      console.error('Redis Client Error:', err);
    });
    
    this.redisClient.on('connect', () => {
      console.log('ML Service connected to Redis');
    });
  }

  async initialize() {
    try {
      await this.redisClient.connect();
    } catch (error) {
      console.error('Failed to connect ML Service to Redis:', error);
    }
  }

  async queueClassificationJob(reportData) {
    try {
      const job = {
        reportId: reportData._id.toString(),
        description: reportData.description || '',
        imageUrl: reportData.image_url || null,
        title: reportData.title || '',
        timestamp: new Date().toISOString()
      };

      await this.redisClient.lPush('ml_classification_queue', JSON.stringify(job));
      console.log(`ML classification job queued for report ${reportData._id}`);
      
      return { success: true, jobId: reportData._id };
    } catch (error) {
      console.error('Error queueing ML classification job:', error);
      return { success: false, error: error.message };
    }
  }

  async getQueueStatus() {
    try {
      const queueLength = await this.redisClient.lLen('ml_classification_queue');
      return { queueLength };
    } catch (error) {
      console.error('Error getting queue status:', error);
      return { queueLength: 0 };
    }
  }
}

module.exports = new MLService();