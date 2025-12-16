#!/usr/bin/env pwsh
# Script de Pipeline de Seguridad para Contenedores Docker
# Este script ejecuta todas las validaciones de seguridad necesarias

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "PIPELINE DE SEGURIDAD DOCKER" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# Variables de configuración
$IMAGE_NAME = "proyecto1-todo-api"
$IMAGE_TAG = "security-scan"
$REPORT_DIR = "security-reports"
$EXIT_CODE = 0

# Crear directorio de reportes
Write-Host "[INFO] Creando directorio de reportes..." -ForegroundColor Blue
New-Item -ItemType Directory -Force -Path $REPORT_DIR | Out-Null

# ===================================================================
# PASO 1: VALIDACIÓN DE DOCKERFILE CON HADOLINT
# ===================================================================
Write-Host ""
Write-Host "======================================" -ForegroundColor Yellow
Write-Host "PASO 1: Validando Dockerfile con Hadolint" -ForegroundColor Yellow
Write-Host "======================================" -ForegroundColor Yellow

Write-Host "[INFO] Hadolint es un linter que valida mejores prácticas en Dockerfiles" -ForegroundColor Blue
Write-Host "[INFO] Verifica: seguridad, mantenibilidad, y optimización" -ForegroundColor Blue

if (Get-Command hadolint -ErrorAction SilentlyContinue) {
    Write-Host "[OK] Hadolint está instalado" -ForegroundColor Green
    
    # Ejecutar Hadolint
    Write-Host "[INFO] Ejecutando análisis..." -ForegroundColor Blue
    hadolint Dockerfile --config .hadolint.yaml | Tee-Object -FilePath "$REPORT_DIR/hadolint-report.txt"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[✓] Dockerfile aprobado - Sin problemas detectados" -ForegroundColor Green
    } else {
        Write-Host "[!] Se encontraron problemas en el Dockerfile" -ForegroundColor Red
        Write-Host "[!] Revisa el reporte en: $REPORT_DIR/hadolint-report.txt" -ForegroundColor Red
        $EXIT_CODE = 1
    }
} else {
    Write-Host "[WARNING] Hadolint no está instalado" -ForegroundColor Yellow
    Write-Host "[INFO] Instalar con: " -ForegroundColor Blue
    Write-Host "       Windows: choco install hadolint" -ForegroundColor Cyan
    Write-Host "       O descargar desde: https://github.com/hadolint/hadolint/releases" -ForegroundColor Cyan
    $EXIT_CODE = 1
}

# ===================================================================
# PASO 2: ESCANEO DE DEPENDENCIAS CON NPM AUDIT
# ===================================================================
Write-Host ""
Write-Host "======================================" -ForegroundColor Yellow
Write-Host "PASO 2: Escaneando dependencias con npm audit" -ForegroundColor Yellow
Write-Host "======================================" -ForegroundColor Yellow

Write-Host "[INFO] npm audit analiza vulnerabilidades conocidas en dependencias" -ForegroundColor Blue
Write-Host "[INFO] Consulta la base de datos de vulnerabilidades de npm" -ForegroundColor Blue

# Ejecutar npm audit
Write-Host "[INFO] Ejecutando análisis de dependencias..." -ForegroundColor Blue
npm audit --json | Out-File -FilePath "$REPORT_DIR/npm-audit-report.json" -Encoding utf8
npm audit | Tee-Object -FilePath "$REPORT_DIR/npm-audit-report.txt"

if ($LASTEXITCODE -eq 0) {
    Write-Host "[✓] Sin vulnerabilidades críticas en dependencias" -ForegroundColor Green
} else {
    Write-Host "[!] Se encontraron vulnerabilidades en dependencias" -ForegroundColor Yellow
    Write-Host "[INFO] Ejecuta 'npm audit fix' para intentar corregir automáticamente" -ForegroundColor Blue
    Write-Host "[INFO] Revisa el reporte detallado en: $REPORT_DIR/npm-audit-report.json" -ForegroundColor Blue
}

# ===================================================================
# PASO 3: CONSTRUCCIÓN DE IMAGEN DOCKER
# ===================================================================
Write-Host ""
Write-Host "======================================" -ForegroundColor Yellow
Write-Host "PASO 3: Construyendo imagen Docker" -ForegroundColor Yellow
Write-Host "======================================" -ForegroundColor Yellow

Write-Host "[INFO] Construyendo imagen: ${IMAGE_NAME}:${IMAGE_TAG}" -ForegroundColor Blue
docker build -t "${IMAGE_NAME}:${IMAGE_TAG}" .

if ($LASTEXITCODE -eq 0) {
    Write-Host "[✓] Imagen construida exitosamente" -ForegroundColor Green
} else {
    Write-Host "[✗] Error al construir la imagen" -ForegroundColor Red
    exit 1
}

# ===================================================================
# PASO 4: ESCANEO DE IMAGEN CON TRIVY
# ===================================================================
Write-Host ""
Write-Host "======================================" -ForegroundColor Yellow
Write-Host "PASO 4: Escaneando imagen con Trivy" -ForegroundColor Yellow
Write-Host "======================================" -ForegroundColor Yellow

Write-Host "[INFO] Trivy es un escáner de vulnerabilidades para contenedores" -ForegroundColor Blue
Write-Host "[INFO] Analiza: OS packages, librerías, y archivos de aplicación" -ForegroundColor Blue

if (Get-Command trivy -ErrorAction SilentlyContinue) {
    Write-Host "[OK] Trivy está instalado" -ForegroundColor Green
    
    # Actualizar base de datos
    Write-Host "[INFO] Actualizando base de datos de vulnerabilidades..." -ForegroundColor Blue
    trivy image --download-db-only
    
    # Escaneo completo (todas las severidades)
    Write-Host "[INFO] Ejecutando escaneo completo..." -ForegroundColor Blue
    trivy image --format table --output "$REPORT_DIR/trivy-report.txt" "${IMAGE_NAME}:${IMAGE_TAG}"
    trivy image --format json --output "$REPORT_DIR/trivy-report.json" "${IMAGE_NAME}:${IMAGE_TAG}"
    
    # Mostrar resumen en consola
    trivy image --severity HIGH,CRITICAL "${IMAGE_NAME}:${IMAGE_TAG}"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[✓] Escaneo completado" -ForegroundColor Green
    } else {
        Write-Host "[!] Se encontraron vulnerabilidades" -ForegroundColor Yellow
        $EXIT_CODE = 1
    }
    
    # Escaneo solo de vulnerabilidades CRITICAL
    Write-Host "[INFO] Verificando vulnerabilidades CRÍTICAS..." -ForegroundColor Blue
    trivy image --severity CRITICAL --exit-code 1 "${IMAGE_NAME}:${IMAGE_TAG}"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[✓] Sin vulnerabilidades CRÍTICAS" -ForegroundColor Green
    } else {
        Write-Host "[!] ATENCIÓN: Se encontraron vulnerabilidades CRÍTICAS" -ForegroundColor Red
        Write-Host "[!] Revisa el reporte en: $REPORT_DIR/trivy-report.txt" -ForegroundColor Red
        $EXIT_CODE = 1
    }
} else {
    Write-Host "[WARNING] Trivy no está instalado" -ForegroundColor Yellow
    Write-Host "[INFO] Instalar con:" -ForegroundColor Blue
    Write-Host "       Windows: choco install trivy" -ForegroundColor Cyan
    Write-Host "       O descargar desde: https://github.com/aquasecurity/trivy/releases" -ForegroundColor Cyan
    $EXIT_CODE = 1
}

# ===================================================================
# PASO 5: ANÁLISIS DE CÓDIGO CON SONARQUBE (OPCIONAL)
# ===================================================================
Write-Host ""
Write-Host "======================================" -ForegroundColor Yellow
Write-Host "PASO 5: Preparando análisis de SonarQube" -ForegroundColor Yellow
Write-Host "======================================" -ForegroundColor Yellow

Write-Host "[INFO] SonarQube analiza calidad de código y vulnerabilidades" -ForegroundColor Blue
Write-Host "[INFO] Para ejecutar, necesitas un servidor SonarQube activo" -ForegroundColor Blue

if (Get-Command sonar-scanner -ErrorAction SilentlyContinue) {
    Write-Host "[OK] SonarScanner está instalado" -ForegroundColor Green
    Write-Host "[INFO] Para ejecutar el análisis:" -ForegroundColor Blue
    Write-Host "       sonar-scanner -Dsonar.host.url=http://localhost:9000 -Dsonar.login=YOUR_TOKEN" -ForegroundColor Cyan
} else {
    Write-Host "[INFO] SonarScanner no está instalado (opcional)" -ForegroundColor Blue
    Write-Host "[INFO] Instalar desde: https://docs.sonarqube.org/latest/analysis/scan/sonarscanner/" -ForegroundColor Cyan
}

# ===================================================================
# RESUMEN FINAL
# ===================================================================
Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "RESUMEN DEL PIPELINE DE SEGURIDAD" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

Write-Host ""
Write-Host "Reportes generados en: $REPORT_DIR/" -ForegroundColor Blue
Get-ChildItem -Path $REPORT_DIR | ForEach-Object {
    Write-Host "  - $($_.Name)" -ForegroundColor Cyan
}

Write-Host ""
if ($EXIT_CODE -eq 0) {
    Write-Host "[✓] PIPELINE COMPLETADO - Todos los checks pasaron" -ForegroundColor Green
} else {
    Write-Host "[!] PIPELINE COMPLETADO CON ADVERTENCIAS" -ForegroundColor Yellow
    Write-Host "[!] Revisa los reportes para más detalles" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "PRÓXIMOS PASOS:" -ForegroundColor Cyan
Write-Host "1. Revisa los reportes en $REPORT_DIR/" -ForegroundColor White
Write-Host "2. Corrige las vulnerabilidades encontradas" -ForegroundColor White
Write-Host "3. Ejecuta 'npm audit fix' para dependencias" -ForegroundColor White
Write-Host "4. Actualiza la imagen base si es necesario" -ForegroundColor White
Write-Host "5. Re-ejecuta este script para validar" -ForegroundColor White
Write-Host "======================================" -ForegroundColor Cyan

exit $EXIT_CODE
