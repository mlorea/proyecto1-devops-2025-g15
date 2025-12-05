const express = require('express');
const bodyParser = require('body-parser');
const tasksRoutes = require('./routes/tasks');
const metrics = require('./metrics/metrics');

const app = express();
app.use(bodyParser.json());

// metrics endpoint
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', metrics.register.contentType);
  res.end(await metrics.register.metrics());
});

app.use('/tasks', tasksRoutes);

// health
app.get('/health', (req, res) => res.json({status: 'ok'}));

module.exports = app;
