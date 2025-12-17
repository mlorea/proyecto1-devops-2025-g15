import React, { useEffect, useState } from "react";
import { getHealth, listTasks, createTask, toggleTask, deleteTask } from "./api.js";

export default function App() {
  const [health, setHealth] = useState(null);
  const [tasks, setTasks] = useState([]);
  const [title, setTitle] = useState("");
  const [err, setErr] = useState("");

  async function refresh() {
    setErr("");
    const [h, t] = await Promise.all([getHealth(), listTasks()]);
    setHealth(h);
    setTasks(Array.isArray(t) ? t : (t.tasks ?? []));
  }

  useEffect(() => {
    refresh().catch((e) => setErr(e.message));
  }, []);

  async function onAdd(e) {
    e.preventDefault();
    if (!title.trim()) return;
    try {
      await createTask(title.trim());
      setTitle("");
      await refresh();
    } catch (e) {
      setErr(e.message);
    }
  }

  return (
    <div style={{ fontFamily: "system-ui", maxWidth: 900, margin: "40px auto", padding: 16 }}>
      <h1>Proyecto 1 – ToDo</h1>

      <div style={{ padding: 12, border: "1px solid #ddd", borderRadius: 8, marginBottom: 16 }}>
        <strong>Health:</strong>{" "}
        {health ? <code>{JSON.stringify(health)}</code> : "cargando..."}
      </div>

      {err && (
        <div style={{ padding: 12, border: "1px solid #f99", background: "#fee", borderRadius: 8, marginBottom: 16 }}>
          <strong>Error:</strong> {err}
        </div>
      )}

      <form onSubmit={onAdd} style={{ display: "flex", gap: 8, marginBottom: 16 }}>
        <input
          value={title}
          onChange={(e) => setTitle(e.target.value)}
          placeholder="Nueva tarea..."
          style={{ flex: 1, padding: 10 }}
        />
        <button style={{ padding: "10px 14px" }}>Agregar</button>
        <button type="button" onClick={() => refresh()} style={{ padding: "10px 14px" }}>
          Refrescar
        </button>
      </form>

      <div style={{ display: "grid", gap: 10 }}>
        {tasks.map((t) => (
          <div key={t.id ?? t.taskId ?? JSON.stringify(t)} style={{ padding: 12, border: "1px solid #ddd", borderRadius: 8 }}>
            <div style={{ display: "flex", justifyContent: "space-between", gap: 12 }}>
              <div>
                <strong>{t.title ?? t.name ?? "Sin título"}</strong>
                <div style={{ opacity: 0.8 }}>
                  Estado: <code>{String(t.done ?? t.completed ?? t.status ?? "unknown")}</code>
                </div>
              </div>

              <div style={{ display: "flex", gap: 8 }}>
                <button onClick={() => toggleTask(t.id ?? t.taskId).then(refresh).catch(e => setErr(e.message))}>
                  Toggle
                </button>
                <button onClick={() => deleteTask(t.id ?? t.taskId).then(refresh).catch(e => setErr(e.message))}>
                  Borrar
                </button>
              </div>
            </div>
          </div>
        ))}
        {!tasks.length && <div>No hay tareas todavía.</div>}
      </div>

      <hr style={{ margin: "24px 0" }} />

      <div>
        <div><strong>Links útiles:</strong></div>
        <ul>
          <li><a href="/health" target="_blank">/health</a></li>
          <li><a href="/api/tasks" target="_blank">/api/tasks</a></li>
          <li><a href="/metrics" target="_blank">/metrics</a></li>
        </ul>
      </div>
    </div>
  );
}
