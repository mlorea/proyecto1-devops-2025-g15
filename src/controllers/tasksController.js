const dbModule = require('../db/sqlite');
const { nanoid } = require('nanoid');
const metrics = require('../metrics/metrics');

module.exports = {
  listTasks: async (req, res) => {
    const tasks = dbModule.listTasks();
    res.json(tasks);
  },

  createTask: async (req, res) => {
    const task = {
      id: nanoid(8),
      title: req.body.title || 'Untitled',
      completed: false,
      createdAt: new Date().toISOString()
    };
    dbModule.createTask(task);
    res.status(201).json(task);
  },

  getTask: async (req, res) => {
    const t = dbModule.getTask(req.params.id);
    if (!t) return res.status(404).json({ error: 'Not found' });
    res.json(t);
  },

  updateTask: async (req, res) => {
    const updated = dbModule.updateTask(req.params.id, req.body);
    if (!updated) return res.status(404).json({ error: 'Not found' });
    res.json(updated);
  },

  deleteTask: async (req, res) => {
    const ok = dbModule.deleteTask(req.params.id);
    if (!ok) return res.status(404).json({ error: 'Not found' });
    res.json({ deleted: true });
  }
};
