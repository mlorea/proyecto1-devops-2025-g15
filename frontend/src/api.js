const base = "/api";

export async function getHealth() {
  const r = await fetch("/health");
  return r.json();
}

export async function listTasks() {
  const r = await fetch(`${base}/tasks`);
  if (!r.ok) throw new Error("No pude listar tareas");
  return r.json();
}

export async function createTask(title) {
  const r = await fetch(`${base}/tasks`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ title })
  });
  if (!r.ok) throw new Error("No pude crear tarea");
  return r.json();
}

export async function toggleTask(id) {
  const r = await fetch(`${base}/tasks/${id}/toggle`, { method: "POST" });
  if (!r.ok) throw new Error("No pude togglear tarea");
  return r.json();
}

export async function deleteTask(id) {
  const r = await fetch(`${base}/tasks/${id}`, { method: "DELETE" });
  if (!r.ok) throw new Error("No pude borrar tarea");
  return r.json();
}
