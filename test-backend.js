const axios = require('axios');

const testBackend = async () => {
  try {
    console.log('Testing backend connection...');
    
    // Test admin login
    const response = await axios.post('http://localhost:3000/api/v1/admin/login', {
      email: 'hari@gmail.com',
      password: 'hari1234'
    });
    
    console.log('✅ Backend is working!');
    console.log('Login successful:', response.data.success);
    console.log('Token received:', !!response.data.data.token);
    
  } catch (error) {
    console.log('❌ Backend connection failed:');
    if (error.code === 'ECONNREFUSED') {
      console.log('- Backend server is not running');
      console.log('- Run: cd backend-server && npm start');
    } else {
      console.log('- Error:', error.response?.data || error.message);
    }
  }
};

testBackend();