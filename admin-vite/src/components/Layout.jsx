import React from 'react';
import { Outlet, Link, useLocation } from 'react-router-dom';
import { BarChart3, FileText, Home, LogOut, User, MapPin } from 'lucide-react';

const Layout = () => {
  const location = useLocation();

  const handleLogout = () => {
    localStorage.removeItem('adminToken');
    window.location.href = '/login';
  };

  const navItems = [
    { path: '/dashboard', icon: Home, label: 'Dashboard' },
    { path: '/reports', icon: FileText, label: 'Reports' },
    { path: '/map-analytics', icon: MapPin, label: 'Map Analytics' },
  ];

  const isActive = (path) => location.pathname === path;

  return (
    <div style={{ display: 'flex', height: '100vh', width: '100vw', backgroundColor: '#E6E6FA', overflow: 'hidden', margin: 0, padding: 0 }}>
      {/* Sidebar */}
      <div style={{ 
        width: '280px', 
        minWidth: '280px',
        backgroundColor: '#1f2937', 
        color: 'white',
        display: 'flex',
        flexDirection: 'column',
        boxShadow: '2px 0 10px rgba(0,0,0,0.1)',
        height: '100vh',
        margin: 0,
        padding: 0
      }}>
        {/* Header */}
        <div style={{ 
          padding: '24px', 
          borderBottom: '1px solid #374151',
          backgroundColor: '#111827'
        }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
            <div style={{ 
              padding: '8px', 
              backgroundColor: '#3b82f6', 
              borderRadius: '8px' 
            }}>
              <BarChart3 size={24} color="white" />
            </div>
            <div>
              <h2 style={{ fontSize: '18px', fontWeight: '600', margin: 0 }}>Admin Panel</h2>
              <p style={{ fontSize: '14px', color: '#9ca3af', margin: 0 }}>Civic Management</p>
            </div>
          </div>
        </div>

        {/* Navigation */}
        <nav style={{ flex: 1, padding: '16px' }}>
          <ul style={{ listStyle: 'none', padding: 0, margin: 0 }}>
            {navItems.map(({ path, icon: Icon, label }) => (
              <li key={path} style={{ marginBottom: '8px' }}>
                <Link
                  to={path}
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    gap: '12px',
                    padding: '12px 16px',
                    borderRadius: '8px',
                    textDecoration: 'none',
                    color: isActive(path) ? '#3b82f6' : '#d1d5db',
                    backgroundColor: isActive(path) ? '#1e3a8a20' : 'transparent',
                    borderLeft: isActive(path) ? '3px solid #3b82f6' : 'none',
                    transition: 'all 0.2s'
                  }}
                  onMouseEnter={(e) => {
                    if (!isActive(path)) {
                      e.target.style.backgroundColor = '#374151';
                      e.target.style.color = 'white';
                    }
                  }}
                  onMouseLeave={(e) => {
                    if (!isActive(path)) {
                      e.target.style.backgroundColor = 'transparent';
                      e.target.style.color = '#d1d5db';
                    }
                  }}
                >
                  <Icon size={20} />
                  <span style={{ fontWeight: '500' }}>{label}</span>
                </Link>
              </li>
            ))}
          </ul>
        </nav>

        {/* User Profile & Logout */}
        <div style={{ 
          padding: '16px', 
          borderTop: '1px solid #374151',
          backgroundColor: '#111827'
        }}>
          <div style={{ 
            display: 'flex', 
            alignItems: 'center', 
            gap: '12px', 
            padding: '12px', 
            borderRadius: '8px', 
            backgroundColor: '#374151',
            marginBottom: '12px'
          }}>
            <div style={{ 
              padding: '8px', 
              backgroundColor: '#6b7280', 
              borderRadius: '50%' 
            }}>
              <User size={16} color="white" />
            </div>
            <div style={{ flex: 1 }}>
              <p style={{ fontSize: '14px', fontWeight: '500', margin: 0, color: 'white' }}>Admin User</p>
              <p style={{ fontSize: '12px', color: '#9ca3af', margin: 0 }}>hari@gmail.com</p>
            </div>
          </div>
          <button
            onClick={handleLogout}
            style={{
              width: '100%',
              display: 'flex',
              alignItems: 'center',
              gap: '12px',
              padding: '12px 16px',
              backgroundColor: '#dc2626',
              color: 'white',
              border: 'none',
              borderRadius: '8px',
              cursor: 'pointer',
              fontSize: '14px',
              fontWeight: '500',
              transition: 'background-color 0.2s'
            }}
            onMouseEnter={(e) => e.target.style.backgroundColor = '#b91c1c'}
            onMouseLeave={(e) => e.target.style.backgroundColor = '#dc2626'}
          >
            <LogOut size={20} />
            Logout
          </button>
        </div>
      </div>

      {/* Main Content */}
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', minWidth: 0, overflow: 'hidden' }}>
        {/* Header */}
        <header style={{ 
          backgroundColor: 'white', 
          padding: '20px 24px', 
          borderBottom: '1px solid #e5e7eb',
          boxShadow: '0 1px 3px rgba(0,0,0,0.1)'
        }}>
          <h1 style={{ 
            fontSize: '24px', 
            fontWeight: '700', 
            color: '#111827',
            margin: 0
          }}>
            Civic Issues Management System
          </h1>
        </header>
        
        {/* Content */}
        <main style={{ 
          flex: 1, 
          overflow: 'auto', 
          padding: '24px',
          backgroundColor: '#E6E6FA',
          minHeight: 0
        }}>
          <Outlet />
        </main>
      </div>
    </div>
  );
};

export default Layout;