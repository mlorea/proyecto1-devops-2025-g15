# Proyecto 1 – Grupo 15
## CI/CD con GitHub Actions + Terraform + Docker

Este proyecto implementa un flujo completo de integración y despliegue continuo (CI/CD) utilizando GitHub Actions, Docker, Terraform, herramientas de seguridad, y monitoreo con Prometheus + Grafana. La aplicación consiste en una API Node.js simple con métricas internas para observabilidad.

## 📁 Estructura del Proyecto

Proyecto1_Grupo15/

│
├── src/

│   ├── app.js

│   ├── index.js

│   ├── db.js

│   ├── controllers/

│   │   └── tasksController.js

│   ├── routes/

│   │   └── tasks.js

│   ├── metrics/

│   │   └── metrics.js

│   └── utils/

│       └── logger.js

│

├── tests/

│   └── tasks.test.js

│

├── terraform/

│   ├── main.tf

│   ├── variables.tf

│   ├── outputs.tf

│   └── provider.tf

│

├── .github/

│   └── workflows/

│       └── ci-cd.yml

│

├── .dockerignore

├── .gitignore

├── Dockerfile

├── docker-compose.yml

├── package.json

├── package-lock.json

├── sbom.json              # generado automáticamente en CI

├── README.md

└── LICENSE

## 🚀 Objetivo

Construir un pipeline que:

- Compile y testee la aplicación.
- Genere una imagen Docker.
- Ejecute análisis de seguridad.
- Genere un SBOM (CycloneDX).
- Despliegue infraestructura con Terraform (local o AWS).
- Exponga métricas para monitoreo con Prometheus.

## 🛠️ Tecnologías Utilizadas

| Área           | Herramienta                          |
|----------------|--------------------------------------|
| CI/CD          | GitHub Actions                       |
| Contenedores    | Docker                               |
| IaC            | Terraform                            |
| Seguridad      | Snyk / Trivy + SBOM CycloneDX      |
| Monitoreo      | Prometheus + Grafana                |
| Lenguaje       | Node.js                              |


Alumnos
