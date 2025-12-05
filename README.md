# Proyecto 1 — To-Do API

Pequeña API REST para gestionar tareas. Incluye CI/CD (GitHub Actions), Docker, Terraform (despliegue local), SBOM, Snyk, Prometheus y Grafana.

## Ejecutar localmente (dev)

1. Instalar dependencias:
   ```bash
   npm ci
   ```
2. Levantar en modo dev:
   ```bash
   npm run dev
   ```

## Ejecutar con docker-compose (prometheus + grafana)

```bash
docker-compose up --build
```

La API quedará en `http://localhost:3000`.
Prometheus: `http://localhost:9090`
Grafana: `http://localhost:3001` (usuario por defecto: admin/admin)

## CI/CD
- El workflow está en `.github/workflows/ci-cd.yml`.
- Ejecuta lint, tests, Snyk, genera SBOM, construye la imagen y hace deploy (solo en `main` y `release/*`).

## Terraform (local)
Desde la carpeta `terraform`:
```bash
terraform init
terraform apply -auto-approve
```
Esto usa el provider `docker` para construir la imagen y levantar el contenedor localmente.

## SBOM
Se genera con `npm run sbom` (CycloneDX) y se sube como artefacto en CI.

## Observabilidad
Metrics en `/metrics` para que Prometheus scrappee.
