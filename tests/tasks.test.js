const request = require('supertest');
const app = require('../src/app');
const fs = require('fs');
const path = require('path');

const dbFile = path.join(__dirname, '../data/todo.db');

beforeEach(() => {
  // limpiar DB
  if (fs.existsSync(dbFile)) fs.unlinkSync(dbFile);
});

describe('Tasks API', () => {
  test('create, list, get, update, delete', async () => {
    // create
    const create = await request(app).post('/tasks').send({ title: 'Test task' });
    expect(create.statusCode).toBe(201);
    expect(create.body.title).toBe('Test task');
    const id = create.body.id;

    // list
    const list = await request(app).get('/tasks');
    expect(list.statusCode).toBe(200);
    expect(Array.isArray(list.body)).toBeTruthy();

    // get
    const get = await request(app).get(`/tasks/${id}`);
    expect(get.statusCode).toBe(200);
    expect(get.body.id).toBe(id);

    // update
    const upd = await request(app).put(`/tasks/${id}`).send({ completed: true });
    expect(upd.statusCode).toBe(200);
    expect(upd.body.completed).toBe(true);

    // delete
    const del = await request(app).delete(`/tasks/${id}`);
    expect(del.statusCode).toBe(200);
    expect(del.body.deleted).toBeTruthy();
  }, 10000);
});
