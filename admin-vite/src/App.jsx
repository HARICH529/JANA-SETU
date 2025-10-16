import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import Login from './pages/Login';
import Dashboard from './pages/Dashboard';
import Reports from './pages/Reports';
import MapAnalytics from './pages/MapAnalytics';
import Layout from './components/Layout';

function App() {
  const isAuthenticated = localStorage.getItem('adminToken');

  return (
    <Router>
      <Routes>
        <Route path="/login" element={!isAuthenticated ? <Login /> : <Navigate to="/dashboard" />} />
        <Route path="/" element={isAuthenticated ? <Layout /> : <Navigate to="/login" />}>
          <Route index element={<Navigate to="/dashboard" />} />
          <Route path="dashboard" element={<Dashboard />} />
          <Route path="reports" element={<Reports />} />
          <Route path="map-analytics" element={<MapAnalytics />} />
        </Route>
      </Routes>
    </Router>
  );
}

export default App;