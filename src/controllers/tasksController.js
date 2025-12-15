const dbModule = require('../db/sqlite');
const { nanoid } = require('nanoid');
const metrics = require('../metrics/metrics');

// Helper function to update task statistics
function updateTaskStatistics() {
  const tasks = dbModule.listTasks();
  const completedTasks = tasks.filter(t => t.completed).length;
  const totalTasks = tasks.length;
  
  metrics.tasksTotal.set(totalTasks);
  
  if (totalTasks > 0) {
    metrics.tasksCompletedRatio.set(completedTasks / totalTasks);
  } else {
    metrics.tasksCompletedRatio.set(0);
  }
}

module.exports = {
  listTasks: async (req, res) => {
    const start = Date.now();
    try {
      const tasks = dbModule.listTasks();
      const duration = (Date.now() - start) / 1000;
      
      metrics.databaseOperationDuration.observe(
        { operation: 'list', status: 'success' },
        duration
      );
      
      res.json(tasks);
    } catch (error) {
      const duration = (Date.now() - start) / 1000;
      metrics.databaseOperationDuration.observe(
        { operation: 'list', status: 'error' },
        duration
      );
      metrics.databaseErrors.inc({ operation: 'list', error_type: error.name });
      metrics.applicationErrors.inc({ error_type: error.name, endpoint: '/tasks' });
      res.status(500).json({ error: 'Internal server error' });
    }
  },

  createTask: async (req, res) => {
    const start = Date.now();
    try {
      const task = {
        id: nanoid(8),
        title: req.body.title || 'Untitled',
        completed: false,
        createdAt: new Date().toISOString()
      };
      
      dbModule.createTask(task);
      
      const duration = (Date.now() - start) / 1000;
      metrics.databaseOperationDuration.observe(
        { operation: 'create', status: 'success' },
        duration
      );
      
      metrics.tasksCreated.inc({ status: 'pending' });
      updateTaskStatistics();
      
      res.status(201).json(task);
    } catch (error) {
      const duration = (Date.now() - start) / 1000;
      metrics.databaseOperationDuration.observe(
        { operation: 'create', status: 'error' },
        duration
      );
      metrics.databaseErrors.inc({ operation: 'create', error_type: error.name });
      metrics.applicationErrors.inc({ error_type: error.name, endpoint: '/tasks' });
      res.status(500).json({ error: 'Internal server error' });
    }
  },

  getTask: async (req, res) => {
    const start = Date.now();
    try {
      const t = dbModule.getTask(req.params.id);
      
      const duration = (Date.now() - start) / 1000;
      metrics.databaseOperationDuration.observe(
        { operation: 'get', status: t ? 'success' : 'not_found' },
        duration
      );
      
      if (!t) {
        return res.status(404).json({ error: 'Not found' });
      }
      
      res.json(t);
    } catch (error) {
      const duration = (Date.now() - start) / 1000;
      metrics.databaseOperationDuration.observe(
        { operation: 'get', status: 'error' },
        duration
      );
      metrics.databaseErrors.inc({ operation: 'get', error_type: error.name });
      metrics.applicationErrors.inc({ error_type: error.name, endpoint: '/tasks/:id' });
      res.status(500).json({ error: 'Internal server error' });
    }
  },

  updateTask: async (req, res) => {
    const start = Date.now();
    try {
      const updated = dbModule.updateTask(req.params.id, req.body);
      
      const duration = (Date.now() - start) / 1000;
      metrics.databaseOperationDuration.observe(
        { operation: 'update', status: updated ? 'success' : 'not_found' },
        duration
      );
      
      if (!updated) {
        return res.status(404).json({ error: 'Not found' });
      }
      
      metrics.tasksUpdated.inc();
      updateTaskStatistics();
      
      res.json(updated);
    } catch (error) {
      const duration = (Date.now() - start) / 1000;
      metrics.databaseOperationDuration.observe(
        { operation: 'update', status: 'error' },
        duration
      );
      metrics.databaseErrors.inc({ operation: 'update', error_type: error.name });
      metrics.applicationErrors.inc({ error_type: error.name, endpoint: '/tasks/:id' });
      res.status(500).json({ error: 'Internal server error' });
    }
  },

  deleteTask: async (req, res) => {
    const start = Date.now();
    try {
      const ok = dbModule.deleteTask(req.params.id);
      
      const duration = (Date.now() - start) / 1000;
      metrics.databaseOperationDuration.observe(
        { operation: 'delete', status: ok ? 'success' : 'not_found' },
        duration
      );
      
      if (!ok) {
        return res.status(404).json({ error: 'Not found' });
      }
      
      metrics.tasksDeleted.inc();
      updateTaskStatistics();
      
      res.json({ deleted: true });
    } catch (error) {
      const duration = (Date.now() - start) / 1000;
      metrics.databaseOperationDuration.observe(
        { operation: 'delete', status: 'error' },
        duration
      );
      metrics.databaseErrors.inc({ operation: 'delete', error_type: error.name });
      metrics.applicationErrors.inc({ error_type: error.name, endpoint: '/tasks/:id' });
      res.status(500).json({ error: 'Internal server error' });
    }
  }
};
