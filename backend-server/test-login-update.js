const axios = require('axios');

const BASE_URL = 'http://localhost:3000/api/v1';

async function testLogin() {
  console.log('Testing Updated Login Functionality...\n');

  const testCases = [
    {
      name: 'Login with Email',
      credentials: {
        email: 'test@example.com',
        password: 'password123'
      }
    },
    {
      name: 'Login with Phone Number',
      credentials: {
        email: '9876543210', // Using email field for phone
        password: 'password123'
      }
    },
    {
      name: 'Invalid Email Format',
      credentials: {
        email: 'invalid-email',
        password: 'password123'
      }
    },
    {
      name: 'Invalid Phone Format',
      credentials: {
        email: '123456', // Too short
        password: 'password123'
      }
    }
  ];

  for (const testCase of testCases) {
    console.log(`Testing: ${testCase.name}`);
    
    try {
      const response = await axios.post(`${BASE_URL}/auth/login`, testCase.credentials);
      console.log('✅ Success:', response.data.message);
    } catch (error) {
      if (error.response) {
        console.log('❌ Error:', error.response.data.error);
      } else {
        console.log('❌ Network Error:', error.message);
      }
    }
    
    console.log('-'.repeat(50));
  }
}

// Run tests
testLogin().catch(console.error);