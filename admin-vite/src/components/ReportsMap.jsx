import React, { useEffect, useRef, useState } from 'react';
import { MapPin } from 'lucide-react';
import { reportsAPI } from '../services/api';

const ReportsMap = () => {
  const mapRef = useRef(null);
  const [locations, setLocations] = useState([]);
  const [loading, setLoading] = useState(true);
  const [dataSource, setDataSource] = useState('loading');
  const mapInstanceRef = useRef(null);

  useEffect(() => {
    const loadData = async () => {
      try {
        console.log('Fetching report locations...');
        const response = await reportsAPI.getReportLocations();
        console.log('API Response:', response.data);
        
        const realLocations = response.data.data.locations || [];
        console.log('Real locations found:', realLocations.length);
        console.log('Sample locations:', realLocations.slice(0, 3));
        
        setLocations(realLocations);
        setDataSource(realLocations.length > 0 ? 'database' : 'empty');
      } catch (err) {
        console.error('Error fetching locations:', err);
        setLocations([]);
        setDataSource('error');
      }
      setLoading(false);
    };
    loadData();
  }, []);

  useEffect(() => {
    const initMap = () => {
      if (!mapRef.current || !window.L || locations.length === 0) {
        if (locations.length === 0 && !loading) {
          // Show empty map
          setTimeout(initMap, 100);
        }
        return;
      }

      try {
        // Clear existing map
        if (mapInstanceRef.current) {
          mapInstanceRef.current.remove();
        }

        const L = window.L;
        const map = L.map(mapRef.current).setView([16.5062, 80.6480], 12);
        mapInstanceRef.current = map;

        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
          attribution: '© OpenStreetMap contributors'
        }).addTo(map);

        // Add markers for each location
        locations.forEach((loc, i) => {
          console.log(`Adding marker ${i}: lat=${loc.lat}, lng=${loc.lng}, dept=${loc.department}`);
          
          const color = getSeverityColor(loc.severity);
          const marker = L.circleMarker([loc.lat, loc.lng], {
            radius: 8,
            fillColor: color,
            color: '#fff',
            weight: 2,
            opacity: 1,
            fillOpacity: 0.8
          }).addTo(map);

          marker.bindPopup(`
            <div style="font-size: 12px;">
              <strong>Title:</strong> ${loc.title || 'N/A'}<br>
              <strong>Department:</strong> ${loc.department}<br>
              <strong>Severity:</strong> ${loc.severity}<br>
              <strong>Location:</strong> ${loc.lat.toFixed(4)}, ${loc.lng.toFixed(4)}
            </div>
          `);
        });

        // Fit map to show all markers if multiple locations
        if (locations.length > 1) {
          const group = new L.featureGroup(locations.map(loc => 
            L.marker([loc.lat, loc.lng])
          ));
          map.fitBounds(group.getBounds().pad(0.1));
        }

      } catch (err) {
        console.error('Map initialization error:', err);
      }
    };

    if (!loading) {
      setTimeout(initMap, 200);
    }

    return () => {
      if (mapInstanceRef.current) {
        mapInstanceRef.current.remove();
        mapInstanceRef.current = null;
      }
    };
  }, [locations, loading]);

  const getSeverityColor = (severity) => {
    switch (severity) {
      case 'CRITICAL': return '#dc2626';
      case 'HIGH': return '#ea580c';
      case 'MEDIUM': return '#d97706';
      case 'LOW': return '#16a34a';
      default: return '#6b7280';
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
          width: '20px', 
          height: '20px', 
          border: '2px solid #f3f4f6', 
          borderTop: '2px solid #3b82f6', 
          borderRadius: '50%', 
          animation: 'spin 1s linear infinite' 
        }}></div>
      </div>
    );
  }

  return (
    <div style={{
      backgroundColor: 'white',
      borderRadius: '12px',
      padding: '24px',
      boxShadow: '0 1px 3px rgba(0,0,0,0.1)',
      border: '1px solid #e5e7eb'
    }}>
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '16px' }}>
        <h3 style={{ fontSize: '18px', fontWeight: '600', color: '#111827', margin: 0 }}>
          Reports Map ({locations.length} locations)
        </h3>
        <MapPin size={20} color="#6b7280" />
      </div>
      
      <div style={{ marginBottom: '16px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '16px', fontSize: '12px' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '4px' }}>
            <div style={{ width: '12px', height: '12px', borderRadius: '50%', backgroundColor: '#16a34a' }}></div>
            <span>Low</span>
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: '4px' }}>
            <div style={{ width: '12px', height: '12px', borderRadius: '50%', backgroundColor: '#d97706' }}></div>
            <span>Medium</span>
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: '4px' }}>
            <div style={{ width: '12px', height: '12px', borderRadius: '50%', backgroundColor: '#ea580c' }}></div>
            <span>High</span>
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: '4px' }}>
            <div style={{ width: '12px', height: '12px', borderRadius: '50%', backgroundColor: '#dc2626' }}></div>
            <span>Critical</span>
          </div>
          <div style={{ fontSize: '10px', color: '#666', marginLeft: '16px' }}>
            {dataSource === 'database' ? '📍 Real Data' : 
             dataSource === 'empty' ? '📋 No Reports' : 
             dataSource === 'error' ? '⚠️ API Error' : '🔄 Loading...'}
          </div>
        </div>
      </div>

      <div 
        ref={mapRef} 
        style={{ 
          height: '400px', 
          width: '100%', 
          borderRadius: '8px',
          border: '1px solid #e5e7eb',
          backgroundColor: '#f8fafc'
        }} 
      />

      {dataSource === 'empty' && (
        <div style={{
          position: 'absolute',
          top: '50%',
          left: '50%',
          transform: 'translate(-50%, -50%)',
          textAlign: 'center',
          color: '#6b7280'
        }}>
          <MapPin size={48} style={{ margin: '0 auto 16px', opacity: 0.3 }} />
          <p>No reports with location data found</p>
        </div>
      )}

      <style>{`
        @keyframes spin {
          0% { transform: rotate(0deg); }
          100% { transform: rotate(360deg); }
        }
      `}</style>
    </div>
  );
};

export default ReportsMap;