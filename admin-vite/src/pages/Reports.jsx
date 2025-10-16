import React, { useState, useMemo } from 'react';
import { RefreshCw, Filter, Search } from 'lucide-react';
import { useReports } from '../hooks/useReports';
import ReportTable from '../components/ReportTable';

const Reports = () => {
  const [filters, setFilters] = useState({});
  const { reports, loading, error, acknowledgeReport, deleteReport, refetch } = useReports();

  const filteredReports = useMemo(() => {
    let filtered = reports;

    if (filters.department) {
      filtered = filtered.filter(report => report.department === filters.department);
    }
    if (filters.status) {
      filtered = filtered.filter(report => report.reportStatus === filters.status);
    }
    if (filters.severity) {
      filtered = filtered.filter(report => report.severity === filters.severity);
    }
    if (filters.search) {
      const searchTerm = filters.search.toLowerCase();
      filtered = filtered.filter(report => 
        report.title.toLowerCase().includes(searchTerm) ||
        report.description.toLowerCase().includes(searchTerm) ||
        report.address?.toLowerCase().includes(searchTerm)
      );
    }

    return filtered;
  }, [reports, filters]);

  const handleAcknowledge = async (reportId) => {
    const success = await acknowledgeReport(reportId);
    if (success) {
      alert('Report acknowledged successfully!');
    }
  };

  const handleDelete = async (reportId) => {
    const success = await deleteReport(reportId);
    if (success) {
      alert('Report deleted successfully!');
    }
  };

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

  if (error) {
    return (
      <div style={{ textAlign: 'center', padding: '48px' }}>
        <div style={{ color: '#dc2626', marginBottom: '16px' }}>Error: {error}</div>
        <button 
          style={{
            padding: '8px 16px',
            backgroundColor: '#3b82f6',
            color: 'white',
            border: 'none',
            borderRadius: '6px',
            cursor: 'pointer'
          }}
          onClick={refetch}
        >
          Try Again
        </button>
      </div>
    );
  }

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '24px' }}>
      {/* Header */}
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <div>
          <h2 style={{ fontSize: '32px', fontWeight: '700', color: '#111827', margin: 0 }}>Reports Management</h2>
          <p style={{ color: '#6b7280', marginTop: '4px', margin: 0 }}>Monitor and manage civic issue reports</p>
        </div>
        <button 
          style={{
            display: 'flex',
            alignItems: 'center',
            gap: '8px',
            padding: '10px 16px',
            backgroundColor: '#3b82f6',
            color: 'white',
            border: 'none',
            borderRadius: '8px',
            cursor: 'pointer',
            fontSize: '14px',
            fontWeight: '500',
            transition: 'background-color 0.2s'
          }}
          onClick={refetch}
          onMouseEnter={(e) => e.target.style.backgroundColor = '#2563eb'}
          onMouseLeave={(e) => e.target.style.backgroundColor = '#3b82f6'}
        >
          <RefreshCw size={16} />
          Refresh
        </button>
      </div>

      {/* Filters */}
      <div style={{
        backgroundColor: 'white',
        borderRadius: '12px',
        padding: '24px',
        boxShadow: '0 1px 3px rgba(0,0,0,0.1)',
        border: '1px solid #e5e7eb'
      }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '20px' }}>
          <Filter size={20} color="#6b7280" />
          <h3 style={{ fontSize: '18px', fontWeight: '600', color: '#111827', margin: 0 }}>Filters</h3>
        </div>
        
        <div style={{ 
          display: 'grid', 
          gridTemplateColumns: '1fr 1fr 1fr 1fr', 
          gap: '16px',
          marginBottom: '16px'
        }}>
          <div>
            <label style={{ 
              display: 'block', 
              fontSize: '14px', 
              fontWeight: '500', 
              color: '#374151', 
              marginBottom: '6px' 
            }}>
              Department
            </label>
            <select
              style={{
                width: '100%',
                padding: '8px 12px',
                border: '1px solid #d1d5db',
                borderRadius: '6px',
                fontSize: '14px',
                backgroundColor: 'white',
                outline: 'none',
                boxSizing: 'border-box'
              }}
              value={filters.department || ''}
              onChange={(e) => setFilters({ ...filters, department: e.target.value || undefined })}
            >
              <option value="">All Departments</option>
              <option value="Roads">Roads</option>
              <option value="Water">Water</option>
              <option value="Electricity">Electricity</option>
              <option value="Sanitation">Sanitation</option>
              <option value="Other">Other</option>
            </select>
          </div>

          <div>
            <label style={{ 
              display: 'block', 
              fontSize: '14px', 
              fontWeight: '500', 
              color: '#374151', 
              marginBottom: '6px' 
            }}>
              Status
            </label>
            <select
              style={{
                width: '100%',
                padding: '8px 12px',
                border: '1px solid #d1d5db',
                borderRadius: '6px',
                fontSize: '14px',
                backgroundColor: 'white',
                outline: 'none',
                boxSizing: 'border-box'
              }}
              value={filters.status || ''}
              onChange={(e) => setFilters({ ...filters, status: e.target.value || undefined })}
            >
              <option value="">All Statuses</option>
              <option value="SUBMITTED">Submitted</option>
              <option value="ACKNOWLEDGED">Acknowledged</option>
              <option value="RESOLVED">Resolved</option>
            </select>
          </div>

          <div>
            <label style={{ 
              display: 'block', 
              fontSize: '14px', 
              fontWeight: '500', 
              color: '#374151', 
              marginBottom: '6px' 
            }}>
              Severity
            </label>
            <select
              style={{
                width: '100%',
                padding: '8px 12px',
                border: '1px solid #d1d5db',
                borderRadius: '6px',
                fontSize: '14px',
                backgroundColor: 'white',
                outline: 'none',
                boxSizing: 'border-box'
              }}
              value={filters.severity || ''}
              onChange={(e) => setFilters({ ...filters, severity: e.target.value || undefined })}
            >
              <option value="">All Severities</option>
              <option value="LOW">Low</option>
              <option value="MEDIUM">Medium</option>
              <option value="HIGH">High</option>
              <option value="CRITICAL">Critical</option>
            </select>
          </div>

          <div>
            <label style={{ 
              display: 'block', 
              fontSize: '14px', 
              fontWeight: '500', 
              color: '#374151', 
              marginBottom: '6px' 
            }}>
              Search
            </label>
            <div style={{ position: 'relative' }}>
              <Search 
                size={16} 
                color="#9ca3af" 
                style={{
                  position: 'absolute',
                  left: '12px',
                  top: '50%',
                  transform: 'translateY(-50%)'
                }}
              />
              <input
                type="text"
                style={{
                  width: '100%',
                  paddingLeft: '40px',
                  paddingRight: '12px',
                  paddingTop: '8px',
                  paddingBottom: '8px',
                  border: '1px solid #d1d5db',
                  borderRadius: '6px',
                  fontSize: '14px',
                  outline: 'none',
                  boxSizing: 'border-box'
                }}
                placeholder="Search reports..."
                value={filters.search || ''}
                onChange={(e) => setFilters({ ...filters, search: e.target.value || undefined })}
              />
            </div>
          </div>
        </div>

        <button
          style={{
            padding: '8px 16px',
            backgroundColor: '#6b7280',
            color: 'white',
            border: 'none',
            borderRadius: '6px',
            cursor: 'pointer',
            fontSize: '14px',
            fontWeight: '500',
            transition: 'background-color 0.2s'
          }}
          onClick={() => setFilters({})}
          onMouseEnter={(e) => e.target.style.backgroundColor = '#4b5563'}
          onMouseLeave={(e) => e.target.style.backgroundColor = '#6b7280'}
        >
          Clear Filters
        </button>
      </div>

      {/* Reports Table */}
      <ReportTable 
        reports={filteredReports}
        onAcknowledge={handleAcknowledge}
        onDelete={handleDelete}
      />

      {/* Summary */}
      <div style={{
        backgroundColor: 'white',
        borderRadius: '12px',
        padding: '20px',
        boxShadow: '0 1px 3px rgba(0,0,0,0.1)',
        border: '1px solid #e5e7eb'
      }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <div>
            <span style={{ fontSize: '16px', fontWeight: '600', color: '#111827' }}>
              Showing {filteredReports.length} of {reports.length} reports
            </span>
          </div>
          <div style={{ display: 'flex', gap: '24px', fontSize: '14px' }}>
            <span style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
              <div style={{ width: '12px', height: '12px', backgroundColor: '#f59e0b', borderRadius: '50%' }}></div>
              Pending: {filteredReports.filter(r => r.reportStatus === 'SUBMITTED').length}
            </span>
            <span style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
              <div style={{ width: '12px', height: '12px', backgroundColor: '#3b82f6', borderRadius: '50%' }}></div>
              Acknowledged: {filteredReports.filter(r => r.reportStatus === 'ACKNOWLEDGED').length}
            </span>
            <span style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
              <div style={{ width: '12px', height: '12px', backgroundColor: '#10b981', borderRadius: '50%' }}></div>
              Resolved: {filteredReports.filter(r => r.reportStatus === 'RESOLVED').length}
            </span>
          </div>
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

export default Reports;