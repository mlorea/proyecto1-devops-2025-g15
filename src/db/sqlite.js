const Database = require('better-sqlite3');
const path = require('path');
const fs = require('fs');

const file = path.join(__dirname, '../../data/todo.db');
if (!fs.existsSync(path.dirname(file))) fs.mkdirSync(path.dirname(file), { recursive: true });

const db = new Database(file);
db.pragma('journal_mode = WAL');

db.prepare(`CREATE TABLE IF NOT EXISTS tasks (
  id TEXT PRIMARY KEY,
  title TEXT,
  completed INTEGER,
  createdAt TEXT
)`).run();

module.exports = {
  db,
  createTask(task) {
    return db.prepare('INSERT INTO tasks (id, title, completed, createdAt) VALUES (?, ?, ?, ?)')
      .run(task.id, task.title, task.completed ? 1 : 0, task.createdAt);
  },
  listTasks() {
    return db.prepare('SELECT id, title, completed, createdAt FROM tasks').all()
      .map(r => ({ ...r, completed: r.completed ? true : false }));
  },
  getTask(id) {
    const r = db.prepare('SELECT id, title, completed, createdAt FROM tasks WHERE id = ?').get(id);
    return r ? ({ ...r, completed: r.completed ? true : false }) : null;
  },
  updateTask(id, data) {
    const existing = this.getTask(id);
    if (!existing) return null;
    const title = data.title !== undefined ? data.title : existing.title;
    const completed = data.completed !== undefined ? (data.completed ? 1 : 0) : (existing.completed ? 1 : 0);
    db.prepare('UPDATE tasks SET title = ?, completed = ? WHERE id = ?').run(title, completed, id);
    return this.getTask(id);
  },
  deleteTask(id) {
    const info = db.prepare('DELETE FROM tasks WHERE id = ?').run(id);
    return info.changes > 0;
  },
  close() { db.close(); }
};
