import React from 'react';
import { MapPin, BarChart3, TrendingUp } from 'lucide-react';
import ReportsMap from '../components/ReportsMap';
import { useReports } from '../hooks/useReports';

const MapAnalytics = () => {
  const { stats, loading } = useReports();

  if (loading) {
    return (
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
  }

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '24px' }}>
      {/* Header */}
      <div>
        <h2 style={{ fontSize: '32px', fontWeight: '700', color: '#111827', margin: 0 }}>
          Map Analytics
        </h2>
        <p style={{ color: '#6b7280', marginTop: '4px', margin: 0 }}>
          Visualize report locations and hotspots across the city
        </p>
      </div>

      {/* Quick Stats */}
      <div style={{ 
        display: 'grid', 
        gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', 
        gap: '16px' 
      }}>
        <div style={{
          backgroundColor: 'white',
          borderRadius: '8px',
          padding: '16px',
          boxShadow: '0 1px 3px rgba(0,0,0,0.1)',
          border: '1px solid #e5e7eb'
        }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
            <MapPin size={20} color="#3b82f6" />
            <div>
              <p style={{ fontSize: '12px', color: '#6b7280', margin: 0 }}>Total Locations</p>
              <p style={{ fontSize: '20px', fontWeight: '600', color: '#111827', margin: 0 }}>
                {stats.total}
              </p>
            </div>
          </div>
        </div>

        <div style={{
          backgroundColor: 'white',
          borderRadius: '8px',
          padding: '16px',
          boxShadow: '0 1px 3px rgba(0,0,0,0.1)',
          border: '1px solid #e5e7eb'
        }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
            <BarChart3 size={20} color="#10b981" />
            <div>
              <p style={{ fontSize: '12px', color: '#6b7280', margin: 0 }}>Top Department</p>
              <p style={{ fontSize: '20px', fontWeight: '600', color: '#111827', margin: 0 }}>
                {Object.entries(stats.byDepartment).sort(([,a], [,b]) => b - a)[0]?.[0] || 'N/A'}
              </p>
            </div>
          </div>
        </div>

        <div style={{
          backgroundColor: 'white',
          borderRadius: '8px',
          padding: '16px',
          boxShadow: '0 1px 3px rgba(0,0,0,0.1)',
          border: '1px solid #e5e7eb'
        }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
            <TrendingUp size={20} color="#f59e0b" />
            <div>
              <p style={{ fontSize: '12px', color: '#6b7280', margin: 0 }}>Critical Issues</p>
              <p style={{ fontSize: '20px', fontWeight: '600', color: '#111827', margin: 0 }}>
                {stats.bySeverity.CRITICAL || 0}
              </p>
            </div>
          </div>
        </div>
      </div>

      {/* Map */}
      <ReportsMap />

      <style>{`
        @keyframes spin {
          0% { transform: rotate(0deg); }
          100% { transform: rotate(360deg); }
        }
      `}</style>
    </div>
  );
};

export default MapAnalytics;