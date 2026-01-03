const express = require('express');
const { Pool } = require('pg');

const app = express();
const PORT = process.env.PORT || 3000;

// Database connection (will be configured via environment variables)
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ 
    status: 'healthy', 
    timestamp: new Date().toISOString() 
  });
});

// Main endpoint - shows environment info
app.get('/', async (req, res) => {
  const envInfo = {
    message: 'Ephemeral Environment Demo',
    environment: process.env.ENV_NAME || 'unknown',
    prNumber: process.env.PR_NUMBER || 'N/A',
    branch: process.env.BRANCH_NAME || 'N/A',
    timestamp: new Date().toISOString(),
  };

  // Try to query database if connected
  let dbStatus = 'not connected';
  try {
    if (process.env.DATABASE_URL) {
      const result = await pool.query('SELECT NOW()');
      dbStatus = 'connected - ' + result.rows[0].now;
    }
  } catch (err) {
    dbStatus = 'error: ' + err.message;
  }

  res.json({
    ...envInfo,
    database: dbStatus,
  });
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
  console.log(`Environment: ${process.env.ENV_NAME || 'not set'}`);
});