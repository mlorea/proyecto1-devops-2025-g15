# Proyecto 1 – Grupo 15
## CI/CD con GitHub Actions + Terraform + Docker + Security Pipeline

Este proyecto implementa un flujo completo de integración y despliegue continuo (CI/CD) utilizando GitHub Actions, Docker, Terraform, **pipeline de seguridad automatizado**, y monitoreo con Prometheus + Grafana. La aplicación consiste en una API Node.js simple con métricas internas para observabilidad.

## 🔐 Pipeline de Seguridad

Este proyecto incluye un **pipeline completo de validación de seguridad** para contenedores Docker:

### Herramientas Integradas
- ✅ **Hadolint** - Validación de Dockerfile
- ✅ **npm audit** - Escaneo de dependencias
- ✅ **Trivy** - Escaneo de imágenes Docker
- ✅ **SonarQube** - Análisis de calidad de código

### Inicio Rápido - Seguridad

```powershell
# 1. Instalar herramientas
./install-security-tools.ps1

# 2. Ejecutar pipeline de seguridad
./security-pipeline.ps1

# 3. Interpretar resultados
./interpret-security-reports.ps1
```

**📚 Documentación Completa**: Ver [SECURITY-GUIDE.md](SECURITY-GUIDE.md)

---

## 📁 Estructura del Proyecto
```
Proyecto1_Grupo15/
├── src/
│ ├── app.js
│ ├── index.js
│ ├── db.js
│ ├── controllers/
│ │ └── tasksController.js
│ ├── routes/
│ │ └── tasks.js
│ ├── metrics/
│ │ └── metrics.js
│ └── utils/
│ └── logger.js
│
├── tests/
│ └── tasks.test.js
│
├── terraform/
│ ├── main.tf
│ ├── variables.tf
│ ├── outputs.tf
│ └── provider.tf
│
├── .github/
│ └── workflows/
│ ├── ci-cd.yml
│ └── security.yml (🔐 NEW)
│
├── 🔐 Security Files (NEW)
├── .hadolint.yaml
├── .trivyignore
├── .npmauditrc
├── trivy.yaml
├── sonar-project.properties
├── security-pipeline.ps1
├── install-security-tools.ps1
├── interpret-security-reports.ps1
├── SECURITY-GUIDE.md
├── SECURITY-POLICY.md
├── README-SECURITY.md
├── REPORT-EXAMPLES.md
├── IMPLEMENTATION-SUMMARY.md
├── Dockerfile.secure
│
├── .dockerignore
├── .gitignore
├── Dockerfile
├── docker-compose.yml (Updated with SonarQube)
├── package.json (Updated with security scripts)
├── package-lock.json
├── sbom.json
├── README.md
└── LICENSE
```
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
| Seguridad      | Hadolint, npm audit, Trivy, SonarQube |
| SBOM           | CycloneDX                           |
| Monitoreo      | Prometheus + Grafana                |
| Lenguaje       | Node.js                              |


---

## 🔐 Seguridad - Guía Detallada

### Pipeline de Seguridad Implementado

Este proyecto incluye un pipeline completo que valida la seguridad en múltiples capas:

#### 🛡️ 1. Validación de Dockerfile (Hadolint)
```powershell
hadolint Dockerfile --config .hadolint.yaml
```
**Valida**: Mejores prácticas, optimizaciones, seguridad

#### 📦 2. Escaneo de Dependencias (npm audit)
```powershell
npm audit --audit-level=moderate
```
**Detecta**: Vulnerabilidades conocidas en packages de Node.js

#### 🔍 3. Escaneo de Imagen (Trivy)
```powershell
trivy image proyecto1-todo-api:latest
```
**Analiza**: OS packages + librerías de aplicación

#### 📊 4. Análisis de Código (SonarQube)
```powershell
sonar-scanner
```
**Mide**: Bugs, vulnerabilidades, code smells, coverage

### Comandos Rápidos

```powershell
# Pipeline completo (recomendado)
npm run security:pipeline

# Comandos individuales
npm run docker:build          # Construir imagen
npm run docker:scan           # Escanear con Trivy
npm run security:report       # Interpretar reportes
npm run sbom                  # Generar SBOM
```

### Documentación de Seguridad

| Documento | Descripción |
|-----------|-------------|
| [SECURITY-GUIDE.md](SECURITY-GUIDE.md) | 📖 Guía completa y didáctica (6000+ palabras) |
| [SECURITY-POLICY.md](SECURITY-POLICY.md) | 📋 Política de seguridad formal |
| [README-SECURITY.md](README-SECURITY.md) | ⚡ Guía rápida de inicio |
| [REPORT-EXAMPLES.md](REPORT-EXAMPLES.md) | 📊 Ejemplos visuales de reportes |
| [IMPLEMENTATION-SUMMARY.md](IMPLEMENTATION-SUMMARY.md) | ✅ Resumen de implementación |

### Criterios de Aprobación

**Desarrollo:**
- 🔴 0 CRITICAL
- 🟠 Max 5 HIGH
- 🟡 MEDIUM/LOW: aceptable

**Producción:**
- 🔴 0 CRITICAL
- 🟠 0 HIGH
- 🟡 Max 10 MEDIUM

### Servicios de Seguridad

```powershell
# Iniciar SonarQube
docker-compose up -d sonarqube

# Acceder a:
# SonarQube: http://localhost:9000 (admin/admin)
# Prometheus: http://localhost:9090
# Grafana: http://localhost:3001 (admin/admin)
```

---

Alumnos:

