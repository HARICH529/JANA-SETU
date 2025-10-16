import axios from 'axios';

const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:3000/api/v1';

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
    'ngrok-skip-browser-warning': 'true',
  },
});

api.interceptors.request.use((config) => {
  const token = localStorage.getItem('adminToken');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('adminToken');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

export const authAPI = {
  login: (credentials) => api.post('/admin/login', credentials),
};

export const reportsAPI = {
  getAllReports: (params) => api.get('/admin/get-all-reports', { params }),
  getReportLocations: () => api.get('/admin/get-report-locations'),
  acknowledgeReport: (reportId) => api.patch(`/admin/update-report-acknowledge/${reportId}`),
  deleteReport: (reportId) => api.delete(`/reports/${reportId}`),
};

export default api;