const express = require('express');
const bodyParser = require('body-parser');
const tasksRoutes = require('./routes/tasks');
const metrics = require('./metrics/metrics');

const app = express();

// Middleware to track active connections
app.use((req, res, next) => {
  metrics.activeConnections.inc();
  res.on('finish', () => {
    metrics.activeConnections.dec();
  });
  next();
});

// Middleware to track HTTP metrics
app.use((req, res, next) => {
  const start = Date.now();
  
  res.on('finish', () => {
    const duration = (Date.now() - start) / 1000;
    const route = req.route ? req.route.path : req.path;
    
    // Track request count
    metrics.httpRequestsTotal.inc({
      method: req.method,
      route: route,
      code: res.statusCode
    });
    
    // Track request duration
    metrics.httpRequestDuration.observe(
      {
        method: req.method,
        route: route,
        code: res.statusCode
      },
      duration
    );
    
    // Track response size
    const contentLength = res.get('Content-Length');
    if (contentLength) {
      metrics.httpResponseSize.observe(
        {
          method: req.method,
          route: route,
          code: res.statusCode
        },
        parseInt(contentLength)
      );
    }
  });
  
  next();
});

app.use(bodyParser.json());

// metrics endpoint
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', metrics.register.contentType);
  res.end(await metrics.register.metrics());
});

app.use('/tasks', tasksRoutes);

// health
app.get('/health', (req, res) => res.json({status: 'ok'}));

// 404 handler
app.use((req, res) => {
  metrics.applicationErrors.inc({ error_type: 'not_found', endpoint: req.path });
  res.status(404).json({ error: 'Route not found' });
});

// Error handler
app.use((err, req, res, next) => {
  metrics.applicationErrors.inc({ error_type: err.name || 'unknown', endpoint: req.path });
  console.error(err.stack);
  res.status(500).json({ error: 'Internal server error' });
});

module.exports = app;
