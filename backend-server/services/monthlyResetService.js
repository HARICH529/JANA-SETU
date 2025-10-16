const User = require('../models/User');
const cron = require('node-cron');

class MonthlyResetService {
  constructor() {
    this.isScheduled = false;
  }
  // Reset monthly points for all users
  async resetAllMonthlyPoints() {
    try {
      console.log('🔄 Starting monthly points reset...');
      
      const result = await User.updateMany(
        {},
        { 
          $set: { 
            monthlyPoints: 0,
            lastMonthlyReset: new Date()
          }
        }
      );

      console.log(`✅ Monthly points reset completed for ${result.modifiedCount} users`);
      return result.modifiedCount;
    } catch (error) {
      console.error('❌ Monthly points reset failed:', error);
      throw error;
    }
  }

  // Check if any user needs monthly reset
  async checkAndResetIndividualUsers() {
    try {
      const now = new Date();
      const currentMonth = now.getMonth();
      const currentYear = now.getFullYear();

      const users = await User.find({
        $or: [
          { lastMonthlyReset: { $exists: false } },
          {
            $expr: {
              $or: [
                { $ne: [{ $month: '$lastMonthlyReset' }, currentMonth + 1] },
                { $ne: [{ $year: '$lastMonthlyReset' }, currentYear] }
              ]
            }
          }
        ]
      });

      let resetCount = 0;
      for (const user of users) {
        user.monthlyPoints = 0;
        user.lastMonthlyReset = new Date();
        await user.save();
        resetCount++;
      }

      if (resetCount > 0) {
        console.log(`🔄 Reset monthly points for ${resetCount} individual users`);
      }

      return resetCount;
    } catch (error) {
      console.error('❌ Individual monthly reset failed:', error);
      throw error;
    }
  }

  // Schedule monthly reset (runs on 1st of every month at 00:00)
  scheduleMonthlyReset() {
    if (this.isScheduled) {
      console.log('⚠️ Monthly reset already scheduled');
      return;
    }

    // Schedule for 1st of every month at midnight
    cron.schedule('0 0 1 * *', async () => {
      console.log('📅 Monthly reset cron job triggered');
      try {
        await this.resetAllMonthlyPoints();
      } catch (error) {
        console.error('❌ Scheduled monthly reset failed:', error);
      }
    });

    // Also check daily for individual users who might need reset
    cron.schedule('0 0 * * *', async () => {
      try {
        await this.checkAndResetIndividualUsers();
      } catch (error) {
        console.error('❌ Daily individual reset check failed:', error);
      }
    });

    this.isScheduled = true;
    console.log('✅ Monthly reset service scheduled');
  }
}

module.exports = new MonthlyResetService();