const express=require('express');
const cors=require('cors');
const cookie_parser=require('cookie-parser');
const errorHandler=require('./middlewares/errorHandler');

const app=express();

app.use(express.json());
app.use(cors({
    origin: true,
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS', 'PATCH'],
    allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With', 'Accept', 'ngrok-skip-browser-warning'],
    optionsSuccessStatus: 200
}));



// Handle preflight requests
app.use((req, res, next) => {
    if (req.method === 'OPTIONS') {
        res.header('Access-Control-Allow-Origin', req.headers.origin || '*');
        res.header('Access-Control-Allow-Methods', 'GET,POST,PUT,DELETE,OPTIONS,PATCH');
        res.header('Access-Control-Allow-Headers', 'Content-Type,Authorization,X-Requested-With,Accept,ngrok-skip-browser-warning');
        res.header('Access-Control-Allow-Credentials', 'true');
        return res.sendStatus(200);
    }
    next();
});

// Debug middleware
app.use((req, res, next) => {
    console.log(`📡 ${req.method} ${req.path}`);
    console.log('Headers:', req.headers.authorization ? 'Auth present' : 'No auth');
    next();
});




app.use(express.urlencoded({extended:true}));
app.use(express.static("public"));
app.use(cookie_parser());

// Test route to verify server is working
app.get('/api/v1/test', (req, res) => {
  res.json({ message: 'Server is working!', timestamp: new Date() });
});

// Test admin route
app.get('/api/v1/admin/test', (req, res) => {
  res.json({ message: 'Admin routes working!', timestamp: new Date() });
});

// Server info endpoint for clients
app.get('/api/v1/server-info', (req, res) => {
  const { getLocalIP } = require('./utils/networkUtils');
  const host = req.get('host');
  const protocol = req.protocol;
  
  res.json({
    serverIP: getLocalIP(),
    currentURL: `${protocol}://${host}`,
    port: process.env.PORT || 3000,
    timestamp: new Date()
  });
});

//Auth Routes
app.use('/api/v1/auth',require('./routes/authRoutes'));

//Report Routes
app.use('/api/v1/reports',require('./routes/reportRoutes'));

//Admin Routes
app.use('/api/v1/admin',require('./routes/adminRoutes'));

//Blockchain Routes
app.use('/api/v1/blockchain',require('./routes/blockchainRoutes'));

//Blockchain Test Routes
app.use('/api/v1/blockchain-test',require('./routes/blockchainTestRoutes'));

//Config Routes
app.use('/api/v1/config',require('./routes/configRoutes'));

//Leaderboard Routes
app.use('/api/v1/leaderboard',require('./routes/leaderboardRoutes'));

//Notification Routes
app.use('/api/v1/notifications',require('./routes/notificationRoutes'));

app.use(errorHandler);
module.exports=app;