#!/usr/bin/env node

/**
 * CORS Proxy Server for Flutter Web Development
 * This proxy forwards requests from Flutter web app to the ASP.NET Core backend
 * while handling CORS headers properly.
 */

const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');
const cors = require('cors');

const app = express();
const PORT = 8081;
const BACKEND_URL = 'http://localhost:5001';

// Configure CORS to allow all origins during development
const corsOptions = {
  origin: true, // Allow all origins
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With', 'Accept', 'Origin'],
  exposedHeaders: ['Content-Type', 'Authorization'],
  preflightContinue: false,
  optionsSuccessStatus: 200
};

app.use(cors(corsOptions));

// Proxy configuration
const proxyOptions = {
  target: BACKEND_URL,
  changeOrigin: true,
  pathRewrite: {
    '^/api': '/api', // Keep API path
  },
  onProxyReq: (proxyReq, req, res) => {
    console.log(`🔄 Proxying ${req.method} ${req.url} -> ${BACKEND_URL}${req.url}`);
    
    // Add necessary headers
    proxyReq.setHeader('Origin', BACKEND_URL);
    
    // Handle body for POST requests
    if (req.body && (req.method === 'POST' || req.method === 'PUT' || req.method === 'PATCH')) {
      const bodyData = JSON.stringify(req.body);
      proxyReq.setHeader('Content-Type', 'application/json');
      proxyReq.setHeader('Content-Length', Buffer.byteLength(bodyData));
      proxyReq.write(bodyData);
    }
  },
  onProxyRes: (proxyRes, req, res) => {
    // Add CORS headers to response
    proxyRes.headers['Access-Control-Allow-Origin'] = '*';
    proxyRes.headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS';
    proxyRes.headers['Access-Control-Allow-Headers'] = 'Content-Type, Authorization, X-Requested-With, Accept, Origin';
    proxyRes.headers['Access-Control-Allow-Credentials'] = 'true';
    
    console.log(`✅ Response ${proxyRes.statusCode} for ${req.method} ${req.url}`);
  },
  onError: (err, req, res) => {
    console.error(`❌ Proxy error for ${req.method} ${req.url}:`, err.message);
    res.status(500).json({
      success: false,
      message: 'Proxy server error',
      error: err.message
    });
  }
};

// Enable parsing of JSON bodies
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    proxy: 'running',
    backend: BACKEND_URL,
    timestamp: new Date().toISOString()
  });
});

// Proxy all API requests
app.use('/api', createProxyMiddleware(proxyOptions));

// Handle OPTIONS requests explicitly
app.options('*', (req, res) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.header('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With, Accept, Origin');
  res.header('Access-Control-Allow-Credentials', 'true');
  res.sendStatus(200);
});

// Start the proxy server
app.listen(PORT, () => {
  console.log('🚀 CORS Proxy Server Started');
  console.log('==============================');
  console.log(`📡 Proxy URL: http://localhost:${PORT}`);
  console.log(`🎯 Backend URL: ${BACKEND_URL}`);
  console.log(`📱 Flutter app should use: http://localhost:${PORT}/api`);
  console.log('');
  console.log('📋 Available endpoints:');
  console.log(`   GET  http://localhost:${PORT}/health - Proxy health check`);
  console.log(`   ALL  http://localhost:${PORT}/api/* - Proxied to backend`);
  console.log('');
  console.log('🔧 To use with Flutter app:');
  console.log('   Update baseUrl in environment_config.dart to:');
  console.log(`   baseUrl: 'http://localhost:${PORT}'`);
});

module.exports = app;