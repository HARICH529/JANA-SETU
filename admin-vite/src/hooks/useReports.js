import { useState, useEffect } from 'react';
import { reportsAPI } from '../services/api';

export const useReports = (filters = {}) => {
  const [reports, setReports] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [stats, setStats] = useState({
    total: 0,
    submitted: 0,
    acknowledged: 0,
    resolved: 0,
    byDepartment: {},
    bySeverity: {}
  });

  const fetchReports = async () => {
    try {
      setLoading(true);
      const response = await reportsAPI.getAllReports(filters);
      const reportsData = response.data.data.reports;
      setReports(reportsData);
      
      const newStats = {
        total: reportsData.length,
        submitted: reportsData.filter(r => r.reportStatus === 'SUBMITTED').length,
        acknowledged: reportsData.filter(r => r.reportStatus === 'ACKNOWLEDGED').length,
        resolved: reportsData.filter(r => r.reportStatus === 'RESOLVED').length,
        byDepartment: {},
        bySeverity: {}
      };

      reportsData.forEach(report => {
        newStats.byDepartment[report.department] = (newStats.byDepartment[report.department] || 0) + 1;
        newStats.bySeverity[report.severity] = (newStats.bySeverity[report.severity] || 0) + 1;
      });

      setStats(newStats);
      setError(null);
    } catch (err) {
      setError(err.response?.data?.error || 'Failed to fetch reports');
    } finally {
      setLoading(false);
    }
  };

  const acknowledgeReport = async (reportId) => {
    try {
      await reportsAPI.acknowledgeReport(reportId);
      await fetchReports();
      return true;
    } catch (err) {
      setError(err.response?.data?.error || 'Failed to acknowledge report');
      return false;
    }
  };

  const deleteReport = async (reportId) => {
    try {
      await reportsAPI.deleteReport(reportId);
      await fetchReports();
      return true;
    } catch (err) {
      setError(err.response?.data?.error || 'Failed to delete report');
      return false;
    }
  };

  useEffect(() => {
    fetchReports();
  }, [filters.department, filters.status, filters.severity]);

  return {
    reports,
    loading,
    error,
    stats,
    acknowledgeReport,
    deleteReport,
    refetch: fetchReports
  };
};