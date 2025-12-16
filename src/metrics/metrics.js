const client = require('prom-client');

const register = new client.Registry();
client.collectDefaultMetrics({ register });

// HTTP Metrics
const httpRequestsTotal = new client.Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'code']
});

const httpRequestDuration = new client.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'code'],
  buckets: [0.1, 0.5, 1, 2, 5]
});

// Tasks Metrics
const tasksTotal = new client.Gauge({
  name: 'tasks_total',
  help: 'Total number of tasks in the system'
});

const tasksCreated = new client.Counter({
  name: 'tasks_created_total',
  help: 'Total number of tasks created',
  labelNames: ['status']
});

const tasksUpdated = new client.Counter({
  name: 'tasks_updated_total',
  help: 'Total number of tasks updated'
});

const tasksDeleted = new client.Counter({
  name: 'tasks_deleted_total',
  help: 'Total number of tasks deleted'
});

const tasksCompletedRatio = new client.Gauge({
  name: 'tasks_completed_ratio',
  help: 'Ratio of completed tasks to total tasks'
});

// Database Metrics
const databaseOperationDuration = new client.Histogram({
  name: 'database_operation_duration_seconds',
  help: 'Duration of database operations in seconds',
  labelNames: ['operation', 'status'],
  buckets: [0.01, 0.05, 0.1, 0.5, 1]
});

const databaseErrors = new client.Counter({
  name: 'database_errors_total',
  help: 'Total number of database errors',
  labelNames: ['operation', 'error_type']
});

// Error Metrics
const applicationErrors = new client.Counter({
  name: 'application_errors_total',
  help: 'Total number of application errors',
  labelNames: ['error_type', 'endpoint']
});

// API Response Size
const httpResponseSize = new client.Histogram({
  name: 'http_response_size_bytes',
  help: 'Size of HTTP responses in bytes',
  labelNames: ['method', 'route', 'code'],
  buckets: [100, 1000, 10000, 100000, 1000000]
});

// Active Connections
const activeConnections = new client.Gauge({
  name: 'active_connections',
  help: 'Number of active connections'
});

// Register all metrics
register.registerMetric(httpRequestsTotal);
register.registerMetric(httpRequestDuration);
register.registerMetric(tasksTotal);
register.registerMetric(tasksCreated);
register.registerMetric(tasksUpdated);
register.registerMetric(tasksDeleted);
register.registerMetric(tasksCompletedRatio);
register.registerMetric(databaseOperationDuration);
register.registerMetric(databaseErrors);
register.registerMetric(applicationErrors);
register.registerMetric(httpResponseSize);
register.registerMetric(activeConnections);

module.exports = {
  register,
  httpRequestsTotal,
  httpRequestDuration,
  tasksTotal,
  tasksCreated,
  tasksUpdated,
  tasksDeleted,
  tasksCompletedRatio,
  databaseOperationDuration,
  databaseErrors,
  applicationErrors,
  httpResponseSize,
  activeConnections
};
