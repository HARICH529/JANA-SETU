import React, { useState, useEffect } from 'react';
import { Trophy, Medal, Award, Crown, Star } from 'lucide-react';
import api from '../services/api';

const Leaderboard = () => {
  const [monthlyLeaderboard, setMonthlyLeaderboard] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    fetchLeaderboard();
  }, []);

  const fetchLeaderboard = async () => {
    try {
      setLoading(true);
      const response = await api.get('/leaderboard/monthly');
      
      if (response.data.success) {
        setMonthlyLeaderboard(response.data.data.leaderboard);
      } else {
        setError('Failed to fetch leaderboard');
      }
    } catch (err) {
      setError('Error fetching leaderboard');
      console.error('Leaderboard fetch error:', err);
    } finally {
      setLoading(false);
    }
  };

  const getRankIcon = (rank) => {
    switch (rank) {
      case 1: return <Crown size={20} color="#FFD700" />;
      case 2: return <Medal size={20} color="#C0C0C0" />;
      case 3: return <Award size={20} color="#CD7F32" />;
      default: return <Star size={16} color="#6b7280" />;
    }
  };

  const getBadgeColor = (badge) => {
    switch (badge) {
      case 'Platinum': return '#E5E4E2';
      case 'Gold': return '#FFD700';
      case 'Silver': return '#C0C0C0';
      case 'Bronze': return '#CD7F32';
      default: return '#CD7F32';
    }
  };

  if (loading) {
    return (
      <div style={{
        backgroundColor: 'white',
        borderRadius: '12px',
        padding: '24px',
        boxShadow: '0 1px 3px rgba(0,0,0,0.1)',
        border: '1px solid #e5e7eb',
        height: '400px',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center'
      }}>
        <div style={{
          width: '32px',
          height: '32px',
          border: '3px solid #f3f4f6',
          borderTop: '3px solid #3b82f6',
          borderRadius: '50%',
          animation: 'spin 1s linear infinite'
        }}></div>
      </div>
    );
  }

  if (error) {
    return (
      <div style={{
        backgroundColor: 'white',
        borderRadius: '12px',
        padding: '24px',
        boxShadow: '0 1px 3px rgba(0,0,0,0.1)',
        border: '1px solid #e5e7eb',
        textAlign: 'center'
      }}>
        <div style={{ color: '#dc2626', marginBottom: '16px' }}>
          Error: {error}
        </div>
        <button
          onClick={fetchLeaderboard}
          style={{
            padding: '8px 16px',
            backgroundColor: '#3b82f6',
            color: 'white',
            border: 'none',
            borderRadius: '6px',
            cursor: 'pointer'
          }}
        >
          Retry
        </button>
      </div>
    );
  }

  return (
    <div style={{
      backgroundColor: 'white',
      borderRadius: '12px',
      padding: '24px',
      boxShadow: '0 1px 3px rgba(0,0,0,0.1)',
      border: '1px solid #e5e7eb',
      height: '400px',
      display: 'flex',
      flexDirection: 'column'
    }}>
      <div style={{
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'space-between',
        marginBottom: '20px'
      }}>
        <h3 style={{
          fontSize: '18px',
          fontWeight: '600',
          color: '#111827',
          margin: 0,
          display: 'flex',
          alignItems: 'center',
          gap: '8px'
        }}>
          <Trophy size={20} color="#3b82f6" />
          Monthly Leaderboard
        </h3>
        <button
          onClick={fetchLeaderboard}
          style={{
            padding: '6px 12px',
            backgroundColor: '#f3f4f6',
            border: '1px solid #d1d5db',
            borderRadius: '6px',
            cursor: 'pointer',
            fontSize: '12px',
            color: '#6b7280'
          }}
        >
          Refresh
        </button>
      </div>

      <div style={{
        flex: 1,
        overflowY: 'auto'
      }}>
        {monthlyLeaderboard.length === 0 ? (
          <div style={{
            textAlign: 'center',
            color: '#6b7280',
            padding: '40px 0'
          }}>
            No data available
          </div>
        ) : (
          <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
            {monthlyLeaderboard.map((user, index) => (
              <div
                key={user._id}
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  padding: '12px',
                  backgroundColor: index < 3 ? '#f8fafc' : 'transparent',
                  borderRadius: '8px',
                  border: index < 3 ? '1px solid #e2e8f0' : '1px solid transparent'
                }}
              >
                <div style={{
                  display: 'flex',
                  alignItems: 'center',
                  minWidth: '40px'
                }}>
                  {getRankIcon(index + 1)}
                  <span style={{
                    marginLeft: '8px',
                    fontWeight: index < 3 ? '600' : '500',
                    color: index < 3 ? '#111827' : '#6b7280',
                    fontSize: '14px'
                  }}>
                    #{index + 1}
                  </span>
                </div>

                <div style={{
                  flex: 1,
                  marginLeft: '12px',
                  minWidth: 0
                }}>
                  <div style={{
                    fontWeight: '500',
                    color: '#111827',
                    fontSize: '14px',
                    overflow: 'hidden',
                    textOverflow: 'ellipsis',
                    whiteSpace: 'nowrap'
                  }}>
                    {user.name}
                  </div>
                  <div style={{
                    fontSize: '12px',
                    color: '#6b7280',
                    overflow: 'hidden',
                    textOverflow: 'ellipsis',
                    whiteSpace: 'nowrap'
                  }}>
                    {user.email}
                  </div>
                </div>

                <div style={{
                  display: 'flex',
                  alignItems: 'center',
                  gap: '8px'
                }}>
                  <div style={{
                    padding: '4px 8px',
                    backgroundColor: getBadgeColor(user.badge),
                    color: user.badge === 'Platinum' ? '#374151' : '#ffffff',
                    borderRadius: '12px',
                    fontSize: '10px',
                    fontWeight: '600',
                    textTransform: 'uppercase'
                  }}>
                    {user.badge}
                  </div>
                  <div style={{
                    fontWeight: '600',
                    color: '#3b82f6',
                    fontSize: '14px'
                  }}>
                    {user.monthlyPoints}
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
};

export default Leaderboard;