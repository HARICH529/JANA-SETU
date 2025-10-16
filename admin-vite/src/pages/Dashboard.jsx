import React from 'react';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, PieChart, Pie, Cell } from 'recharts';
import { AlertTriangle, CheckCircle, Clock, FileText, TrendingUp, Users, MapPin } from 'lucide-react';
import { useReports } from '../hooks/useReports';
import Leaderboard from '../components/Leaderboard';

const Dashboard = () => {
  const { stats, loading, error } = useReports();

  if (loading) return (
    <div style={{ 
      display: 'flex', 
      alignItems: 'center', 
      justifyContent: 'center', 
      height: '200px' 
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
  
  if (error) return (
    <div style={{ textAlign: 'center', padding: '48px' }}>
      <div style={{ color: '#dc2626', marginBottom: '16px' }}>Error: {error}</div>
    </div>
  );

  const departmentData = Object.entries(stats.byDepartment).map(([name, value]) => ({
    name,
    value
  }));

  const severityData = Object.entries(stats.bySeverity).map(([name, value]) => ({
    name,
    value
  }));

  const COLORS = ['#3b82f6', '#10b981', '#f59e0b', '#ef4444', '#8b5cf6'];

  const StatCard = ({ title, value, icon: Icon, color, trend }) => (
    <div style={{
      backgroundColor: 'white',
      borderRadius: '12px',
      padding: '24px',
      boxShadow: '0 1px 3px rgba(0,0,0,0.1)',
      border: '1px solid #e5e7eb',
      transition: 'box-shadow 0.2s'
    }}
    onMouseEnter={(e) => e.currentTarget.style.boxShadow = '0 4px 6px rgba(0,0,0,0.1)'}
    onMouseLeave={(e) => e.currentTarget.style.boxShadow = '0 1px 3px rgba(0,0,0,0.1)'}
    >
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <div>
          <p style={{ fontSize: '14px', fontWeight: '500', color: '#6b7280', margin: 0 }}>{title}</p>
          <p style={{ fontSize: '32px', fontWeight: '700', color: '#111827', margin: '8px 0' }}>{value}</p>
          {trend && (
            <div style={{ display: 'flex', alignItems: 'center', marginTop: '8px' }}>
              <TrendingUp size={16} color="#10b981" style={{ marginRight: '4px' }} />
              <span style={{ fontSize: '14px', color: '#10b981' }}>{trend}</span>
            </div>
          )}
        </div>
        <div style={{
          padding: '12px',
          borderRadius: '50%',
          backgroundColor: color
        }}>
          <Icon size={24} color="white" />
        </div>
      </div>
    </div>
  );

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '24px' }}>
      {/* Header */}
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <div>
          <h2 style={{ fontSize: '32px', fontWeight: '700', color: '#111827', margin: 0 }}>Dashboard Overview</h2>
          <p style={{ color: '#6b7280', marginTop: '4px', margin: 0 }}>Monitor and manage civic issues efficiently</p>
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: '8px', fontSize: '14px', color: '#6b7280' }}>
          <Clock size={16} />
          Last updated: {new Date().toLocaleTimeString()}
        </div>
      </div>
      
      {/* Stats Cards */}
      <div style={{ 
        display: 'grid', 
        gridTemplateColumns: 'repeat(auto-fit, minmax(250px, 1fr))', 
        gap: '24px' 
      }}>
        <StatCard 
          title="Total Reports" 
          value={stats.total} 
          icon={FileText} 
          color="#3b82f6"
          trend="+12% from last month"
        />
        <StatCard 
          title="Pending Review" 
          value={stats.submitted} 
          icon={Clock} 
          color="#f59e0b"
        />
        <StatCard 
          title="In Progress" 
          value={stats.acknowledged} 
          icon={AlertTriangle} 
          color="#f97316"
        />
        <StatCard 
          title="Resolved" 
          value={stats.resolved} 
          icon={CheckCircle} 
          color="#10b981"
          trend="+8% resolution rate"
        />
      </div>

      {/* Charts Section */}
      <div style={{ 
        display: 'grid', 
        gridTemplateColumns: 'repeat(auto-fit, minmax(400px, 1fr))', 
        gap: '24px' 
      }}>
        {/* Department Distribution */}
        <div style={{
          backgroundColor: 'white',
          borderRadius: '12px',
          padding: '24px',
          boxShadow: '0 1px 3px rgba(0,0,0,0.1)',
          border: '1px solid #e5e7eb'
        }}>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '24px' }}>
            <h3 style={{ fontSize: '18px', fontWeight: '600', color: '#111827', margin: 0 }}>Reports by Department</h3>
            <div style={{ display: 'flex', alignItems: 'center', gap: '8px', fontSize: '14px', color: '#6b7280' }}>
              <MapPin size={16} />
              Distribution
            </div>
          </div>
          <ResponsiveContainer width="100%" height={300}>
            <BarChart data={departmentData}>
              <CartesianGrid strokeDasharray="3 3" stroke="#f3f4f6" />
              <XAxis 
                dataKey="name" 
                tick={{ fontSize: 12 }}
                stroke="#6b7280"
              />
              <YAxis 
                tick={{ fontSize: 12 }}
                stroke="#6b7280"
              />
              <Tooltip 
                contentStyle={{
                  backgroundColor: 'white',
                  border: '1px solid #e5e7eb',
                  borderRadius: '8px',
                  boxShadow: '0 4px 6px rgba(0,0,0,0.1)'
                }}
              />
              <Bar 
                dataKey="value" 
                fill="#3b82f6" 
                radius={[4, 4, 0, 0]}
              />
            </BarChart>
          </ResponsiveContainer>
        </div>

        {/* Severity Distribution */}
        <div style={{
          backgroundColor: 'white',
          borderRadius: '12px',
          padding: '24px',
          boxShadow: '0 1px 3px rgba(0,0,0,0.1)',
          border: '1px solid #e5e7eb'
        }}>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '24px' }}>
            <h3 style={{ fontSize: '18px', fontWeight: '600', color: '#111827', margin: 0 }}>Severity Levels</h3>
            <div style={{ display: 'flex', alignItems: 'center', gap: '8px', fontSize: '14px', color: '#6b7280' }}>
              <AlertTriangle size={16} />
              Priority
            </div>
          </div>
          <ResponsiveContainer width="100%" height={300}>
            <PieChart>
              <Pie
                data={severityData}
                cx="50%"
                cy="50%"
                labelLine={false}
                label={({ name, percent }) => `${name} ${(percent * 100).toFixed(0)}%`}
                outerRadius={100}
                fill="#8884d8"
                dataKey="value"
              >
                {severityData.map((entry, index) => (
                  <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                ))}
              </Pie>
              <Tooltip 
                contentStyle={{
                  backgroundColor: 'white',
                  border: '1px solid #e5e7eb',
                  borderRadius: '8px',
                  boxShadow: '0 4px 6px rgba(0,0,0,0.1)'
                }}
              />
            </PieChart>
          </ResponsiveContainer>
        </div>

        {/* Leaderboard */}
        <Leaderboard />
      </div>

      {/* Quick Actions */}
      <div style={{
        backgroundColor: 'white',
        borderRadius: '12px',
        padding: '24px',
        boxShadow: '0 1px 3px rgba(0,0,0,0.1)',
        border: '1px solid #e5e7eb'
      }}>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '24px' }}>
          <h3 style={{ fontSize: '18px', fontWeight: '600', color: '#111827', margin: 0 }}>Quick Actions</h3>
          <Users size={20} color="#6b7280" />
        </div>
        <div style={{ 
          display: 'grid', 
          gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', 
          gap: '16px' 
        }}>
          <button 
            style={{
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              gap: '8px',
              padding: '16px',
              backgroundColor: '#3b82f6',
              color: 'white',
              border: 'none',
              borderRadius: '8px',
              cursor: 'pointer',
              fontSize: '14px',
              fontWeight: '500',
              transition: 'background-color 0.2s'
            }}
            onClick={() => window.location.href = '/reports'}
            onMouseEnter={(e) => e.target.style.backgroundColor = '#2563eb'}
            onMouseLeave={(e) => e.target.style.backgroundColor = '#3b82f6'}
          >
            <FileText size={20} />
            View All Reports
          </button>
          <button 
            style={{
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              gap: '8px',
              padding: '16px',
              backgroundColor: '#10b981',
              color: 'white',
              border: 'none',
              borderRadius: '8px',
              cursor: 'pointer',
              fontSize: '14px',
              fontWeight: '500',
              transition: 'background-color 0.2s'
            }}
            onClick={() => window.location.href = '/reports?status=SUBMITTED'}
            onMouseEnter={(e) => e.target.style.backgroundColor = '#059669'}
            onMouseLeave={(e) => e.target.style.backgroundColor = '#10b981'}
          >
            <Clock size={20} />
            Review Pending ({stats.submitted})
          </button>
          <button 
            style={{
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              gap: '8px',
              padding: '16px',
              backgroundColor: '#f97316',
              color: 'white',
              border: 'none',
              borderRadius: '8px',
              cursor: 'pointer',
              fontSize: '14px',
              fontWeight: '500',
              transition: 'background-color 0.2s'
            }}
            onClick={() => window.location.href = '/reports?severity=CRITICAL'}
            onMouseEnter={(e) => e.target.style.backgroundColor = '#ea580c'}
            onMouseLeave={(e) => e.target.style.backgroundColor = '#f97316'}
          >
            <AlertTriangle size={20} />
            Critical Issues
          </button>
        </div>
      </div>

      <style>{`
        @keyframes spin {
          0% { transform: rotate(0deg); }
          100% { transform: rotate(360deg); }
        }
      `}</style>
    </div>
  );
};

export default Dashboard;