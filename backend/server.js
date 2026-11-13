const express = require('express');
const cors = require('cors');
require('dotenv').config();
const connectDB = require('./config/db');
const apiRoutes = require('./routes/api');

const app = express();
const PORT = process.env.PORT || 5000;

app.use(cors());
app.use(express.json());

let isConnected = false;
connectDB().then((connected) => { isConnected = connected; });

app.use((req, res, next) => {
  req.dbConnected = isConnected;
  next();
});

app.use('/api', apiRoutes);

app.listen(PORT, '0.0.0.0', () => {
  console.log(`🌟 Backend GlowUp rodando em http://localhost:${PORT}/api/status`);
});
