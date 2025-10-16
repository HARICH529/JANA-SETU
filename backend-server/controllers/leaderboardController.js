const User = require('../models/User');

// Get monthly leaderboard (top 10)
const getMonthlyLeaderboard = async (req, res) => {
  try {
    const Report = require('../models/Report');
    const now = new Date();
    const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);
    
    // Get all users with their resolved reports count for this month
    const users = await User.find({ isActive: true })
      .select('name email monthlyPoints badge')
      .lean();

    // Calculate monthly points from resolved reports for each user
    const leaderboardData = await Promise.all(
      users.map(async (user) => {
        const resolvedReportsThisMonth = await Report.countDocuments({
          userId: user._id,
          reportStatus: 'RESOLVED',
          updatedAt: { $gte: startOfMonth }
        });
        
        const monthlyPointsFromReports = resolvedReportsThisMonth * 20;
        
        return {
          ...user,
          monthlyPoints: monthlyPointsFromReports,
          resolvedReportsCount: resolvedReportsThisMonth
        };
      })
    );

    // Sort by monthly points and take top 10
    const leaderboard = leaderboardData
      .sort((a, b) => b.monthlyPoints - a.monthlyPoints)
      .slice(0, 10);

    res.json({
      success: true,
      data: { leaderboard }
    });
  } catch (error) {
    console.error('Get monthly leaderboard error:', error);
    res.status(500).json({ error: 'Failed to fetch leaderboard' });
  }
};

module.exports = {
  getMonthlyLeaderboard
};