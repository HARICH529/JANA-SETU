import React, { useState } from 'react';
import { CheckCircle, Trash2, Eye, MapPin, Calendar, User } from 'lucide-react';

const ReportTable = ({ reports, onAcknowledge, onDelete }) => {
  const [selectedReport, setSelectedReport] = useState(null);

  const canDelete = (report) => {
    if (!report.acknowledgedAt) return false;
    const acknowledgedDate = new Date(report.acknowledgedAt);
    const thirtyDaysLater = new Date(acknowledgedDate.getTime() + (30 * 24 * 60 * 60 * 1000));
    return new Date() >= thirtyDaysLater;
  };

  const getStatusBadge = (status) => {
    const styles = {
      SUBMITTED: { backgroundColor: '#fef3c7', color: '#92400e', padding: '4px 12px', borderRadius: '12px', fontSize: '12px', fontWeight: '500' },
      ACKNOWLEDGED: { backgroundColor: '#dbeafe', color: '#1e40af', padding: '4px 12px', borderRadius: '12px', fontSize: '12px', fontWeight: '500' },
      RESOLVED: { backgroundColor: '#d1fae5', color: '#065f46', padding: '4px 12px', borderRadius: '12px', fontSize: '12px', fontWeight: '500' }
    };
    return <span style={styles[status] || styles.SUBMITTED}>{status}</span>;
  };

  const getSeverityBadge = (severity) => {
    const styles = {
      LOW: { backgroundColor: '#d1fae5', color: '#065f46', padding: '4px 12px', borderRadius: '12px', fontSize: '12px', fontWeight: '500' },
      MEDIUM: { backgroundColor: '#fef3c7', color: '#92400e', padding: '4px 12px', borderRadius: '12px', fontSize: '12px', fontWeight: '500' },
      HIGH: { backgroundColor: '#fed7d7', color: '#c53030', padding: '4px 12px', borderRadius: '12px', fontSize: '12px', fontWeight: '500' },
      CRITICAL: { backgroundColor: '#c53030', color: 'white', padding: '4px 12px', borderRadius: '12px', fontSize: '12px', fontWeight: '500' }
    };
    return <span style={styles[severity] || styles.MEDIUM}>{severity}</span>;
  };

  const formatDate = (dateString) => {
    return new Date(dateString).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });
  };

  const ReportModal = ({ report, onClose }) => (
    <div style={{
      position: 'fixed',
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      backgroundColor: 'rgba(0,0,0,0.5)',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      zIndex: 1000,
      padding: '16px'
    }}>
      <div style={{
        backgroundColor: 'white',
        borderRadius: '12px',
        maxWidth: '600px',
        width: '100%',
        maxHeight: '90vh',
        overflow: 'auto'
      }}>
        <div style={{ padding: '24px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px' }}>
            <h3 style={{ fontSize: '20px', fontWeight: '700', color: '#111827', margin: 0 }}>Report Details</h3>
            <button 
              onClick={onClose}
              style={{ 
                background: 'none', 
                border: 'none', 
                fontSize: '24px', 
                cursor: 'pointer',
                color: '#6b7280',
                padding: '4px'
              }}
            >
              ×
            </button>
          </div>
          
          <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
            <div>
              <h4 style={{ fontWeight: '600', color: '#111827', marginBottom: '8px', fontSize: '14px' }}>Title</h4>
              <p style={{ color: '#374151', margin: 0 }}>{report.title}</p>
            </div>
            
            <div>
              <h4 style={{ fontWeight: '600', color: '#111827', marginBottom: '8px', fontSize: '14px' }}>Description</h4>
              <p style={{ color: '#374151', margin: 0 }}>{report.description}</p>
            </div>
            
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px' }}>
              <div>
                <h4 style={{ fontWeight: '600', color: '#111827', marginBottom: '8px', fontSize: '14px' }}>Department</h4>
                <p style={{ color: '#374151', margin: 0 }}>{report.department}</p>
              </div>
              <div>
                <h4 style={{ fontWeight: '600', color: '#111827', marginBottom: '8px', fontSize: '14px' }}>Severity</h4>
                {getSeverityBadge(report.severity)}
              </div>
              <div>
                <h4 style={{ fontWeight: '600', color: '#111827', marginBottom: '8px', fontSize: '14px' }}>Status</h4>
                {getStatusBadge(report.reportStatus)}
              </div>
              <div>
                <h4 style={{ fontWeight: '600', color: '#111827', marginBottom: '8px', fontSize: '14px' }}>Upvotes</h4>
                <p style={{ color: '#374151', margin: 0 }}>{report.upvotes}</p>
              </div>
            </div>
            
            {report.address && (
              <div>
                <h4 style={{ fontWeight: '600', color: '#111827', marginBottom: '8px', fontSize: '14px' }}>Address</h4>
                <p style={{ color: '#374151', margin: 0 }}>{report.address}</p>
              </div>
            )}
            
            <div>
              <h4 style={{ fontWeight: '600', color: '#111827', marginBottom: '8px', fontSize: '14px' }}>Coordinates</h4>
              <p style={{ color: '#374151', margin: 0 }}>
                {report.location.coordinates[1]}, {report.location.coordinates[0]}
              </p>
            </div>
            
            {report.image_url && (
              <div>
                <h4 style={{ fontWeight: '600', color: '#111827', marginBottom: '8px', fontSize: '14px' }}>Image</h4>
                <img 
                  src={report.image_url} 
                  alt="Report" 
                  style={{ width: '100%', maxWidth: '400px', height: 'auto', borderRadius: '8px' }}
                />
              </div>
            )}
            
            <div>
              <h4 style={{ fontWeight: '600', color: '#111827', marginBottom: '8px', fontSize: '14px' }}>Reported by</h4>
              <p style={{ color: '#374151', margin: 0 }}>
                {report.userId?.name || 'Unknown'} ({report.userId?.email})
              </p>
            </div>
            
            <div>
              <h4 style={{ fontWeight: '600', color: '#111827', marginBottom: '8px', fontSize: '14px' }}>Created</h4>
              <p style={{ color: '#374151', margin: 0 }}>{formatDate(report.createdAt)}</p>
            </div>
            
            {report.mlClassified && (
              <div style={{ backgroundColor: '#eff6ff', padding: '16px', borderRadius: '8px' }}>
                <h4 style={{ fontWeight: '600', color: '#111827', marginBottom: '8px', fontSize: '14px' }}>ML Classification</h4>
                <div style={{ display: 'flex', flexDirection: 'column', gap: '4px', fontSize: '14px' }}>
                  <p style={{ margin: 0 }}>Department: {report.mlDepartment}</p>
                  <p style={{ margin: 0 }}>Severity: {report.mlSeverity}</p>
                  <p style={{ margin: 0 }}>Confidence: {report.mlConfidence?.department}% (Dept), {report.mlConfidence?.severity}% (Severity)</p>
                </div>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );

  return (
    <>
      <div style={{
        backgroundColor: 'white',
        borderRadius: '12px',
        padding: '24px',
        boxShadow: '0 1px 3px rgba(0,0,0,0.1)',
        border: '1px solid #e5e7eb'
      }}>
        <h3 style={{ 
          fontSize: '18px', 
          fontWeight: '600', 
          color: '#111827', 
          marginBottom: '20px',
          margin: 0
        }}>
          Reports ({reports.length})
        </h3>
        
        <div style={{ overflowX: 'auto', width: '100%' }}>
          <table style={{ width: '100%', borderCollapse: 'collapse', minWidth: '800px' }}>
            <thead>
              <tr style={{ borderBottom: '2px solid #f3f4f6' }}>
                <th style={{ textAlign: 'left', padding: '12px 16px', fontWeight: '600', color: '#374151', fontSize: '14px' }}>Title</th>
                <th style={{ textAlign: 'left', padding: '12px 16px', fontWeight: '600', color: '#374151', fontSize: '14px' }}>Department</th>
                <th style={{ textAlign: 'left', padding: '12px 16px', fontWeight: '600', color: '#374151', fontSize: '14px' }}>Status</th>
                <th style={{ textAlign: 'left', padding: '12px 16px', fontWeight: '600', color: '#374151', fontSize: '14px' }}>Severity</th>
                <th style={{ textAlign: 'left', padding: '12px 16px', fontWeight: '600', color: '#374151', fontSize: '14px' }}>Location</th>
                <th style={{ textAlign: 'left', padding: '12px 16px', fontWeight: '600', color: '#374151', fontSize: '14px' }}>Created</th>
                <th style={{ textAlign: 'left', padding: '12px 16px', fontWeight: '600', color: '#374151', fontSize: '14px' }}>Upvotes</th>
                <th style={{ textAlign: 'left', padding: '12px 16px', fontWeight: '600', color: '#374151', fontSize: '14px' }}>Actions</th>
              </tr>
            </thead>
            <tbody>
              {reports.map((report, index) => (
                <tr 
                  key={report._id} 
                  style={{ 
                    borderBottom: '1px solid #f3f4f6',
                    backgroundColor: index % 2 === 0 ? '#ffffff' : '#f9fafb'
                  }}
                  onMouseEnter={(e) => e.currentTarget.style.backgroundColor = '#f3f4f6'}
                  onMouseLeave={(e) => e.currentTarget.style.backgroundColor = index % 2 === 0 ? '#ffffff' : '#f9fafb'}
                >
                  <td style={{ padding: '16px', verticalAlign: 'top' }}>
                    <div style={{ maxWidth: '200px' }}>
                      <div style={{ fontWeight: '500', color: '#111827', marginBottom: '4px' }}>
                        {report.title.length > 30 ? report.title.substring(0, 30) + '...' : report.title}
                      </div>
                      <div style={{ fontSize: '12px', color: '#6b7280' }}>
                        {report.description.substring(0, 50)}...
                      </div>
                    </div>
                  </td>
                  <td style={{ padding: '16px', color: '#374151', fontSize: '14px' }}>{report.department}</td>
                  <td style={{ padding: '16px' }}>{getStatusBadge(report.reportStatus)}</td>
                  <td style={{ padding: '16px' }}>{getSeverityBadge(report.severity)}</td>
                  <td style={{ padding: '16px' }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '4px', fontSize: '12px', color: '#6b7280' }}>
                      <MapPin size={14} />
                      <span style={{ maxWidth: '120px', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
                        {report.address ? report.address.substring(0, 25) + '...' : 'No address'}
                      </span>
                    </div>
                  </td>
                  <td style={{ padding: '16px' }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '4px', fontSize: '12px', color: '#6b7280' }}>
                      <Calendar size={14} />
                      {formatDate(report.createdAt)}
                    </div>
                  </td>
                  <td style={{ padding: '16px', color: '#374151', fontSize: '14px', fontWeight: '500' }}>{report.upvotes}</td>
                  <td style={{ padding: '16px' }}>
                    <div style={{ display: 'flex', gap: '8px' }}>
                      <button
                        style={{
                          padding: '6px',
                          backgroundColor: '#eff6ff',
                          color: '#2563eb',
                          border: 'none',
                          borderRadius: '6px',
                          cursor: 'pointer',
                          transition: 'background-color 0.2s'
                        }}
                        onClick={() => setSelectedReport(report)}
                        title="View Details"
                        onMouseEnter={(e) => e.target.style.backgroundColor = '#dbeafe'}
                        onMouseLeave={(e) => e.target.style.backgroundColor = '#eff6ff'}
                      >
                        <Eye size={16} />
                      </button>
                      
                      {report.reportStatus === 'SUBMITTED' && (
                        <button
                          style={{
                            padding: '6px',
                            backgroundColor: '#f0fdf4',
                            color: '#16a34a',
                            border: 'none',
                            borderRadius: '6px',
                            cursor: 'pointer',
                            transition: 'background-color 0.2s'
                          }}
                          onClick={() => onAcknowledge(report._id)}
                          title="Acknowledge"
                          onMouseEnter={(e) => e.target.style.backgroundColor = '#dcfce7'}
                          onMouseLeave={(e) => e.target.style.backgroundColor = '#f0fdf4'}
                        >
                          <CheckCircle size={16} />
                        </button>
                      )}
                      
                      {canDelete(report) && (
                        <button
                          style={{
                            padding: '6px',
                            backgroundColor: '#fef2f2',
                            color: '#dc2626',
                            border: 'none',
                            borderRadius: '6px',
                            cursor: 'pointer',
                            transition: 'background-color 0.2s'
                          }}
                          onClick={() => {
                            if (window.confirm('Are you sure you want to delete this report?')) {
                              onDelete(report._id);
                            }
                          }}
                          title="Delete (Available after 30 days of acknowledgment)"
                          onMouseEnter={(e) => e.target.style.backgroundColor = '#fee2e2'}
                          onMouseLeave={(e) => e.target.style.backgroundColor = '#fef2f2'}
                        >
                          <Trash2 size={16} />
                        </button>
                      )}
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
          
          {reports.length === 0 && (
            <div style={{ 
              textAlign: 'center', 
              padding: '48px', 
              color: '#6b7280',
              fontSize: '16px'
            }}>
              No reports found matching the current filters.
            </div>
          )}
        </div>
      </div>

      {selectedReport && (
        <ReportModal 
          report={selectedReport} 
          onClose={() => setSelectedReport(null)} 
        />
      )}
    </>
  );
};

export default ReportTable;