#!/usr/bin/env pwsh
# Script para interpretar reportes de vulnerabilidades
# Este script analiza los reportes generados y proporciona un resumen ejecutivo

param(
    [string]$ReportDir = "security-reports"
)

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "INTERPRETACIÓN DE REPORTES DE SEGURIDAD" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

if (-not (Test-Path $ReportDir)) {
    Write-Host "[ERROR] El directorio de reportes no existe: $ReportDir" -ForegroundColor Red
    Write-Host "[INFO] Ejecuta primero: ./security-pipeline.ps1" -ForegroundColor Yellow
    exit 1
}

# ===================================================================
# ANÁLISIS DE REPORTE TRIVY
# ===================================================================
Write-Host "======================================" -ForegroundColor Yellow
Write-Host "ANÁLISIS DE VULNERABILIDADES (TRIVY)" -ForegroundColor Yellow
Write-Host "======================================" -ForegroundColor Yellow

$trivyJsonPath = Join-Path $ReportDir "trivy-report.json"
if (Test-Path $trivyJsonPath) {
    $trivyReport = Get-Content $trivyJsonPath | ConvertFrom-Json
    
    # Contar vulnerabilidades por severidad
    $vulnCount = @{
        CRITICAL = 0
        HIGH = 0
        MEDIUM = 0
        LOW = 0
        UNKNOWN = 0
    }
    
    foreach ($result in $trivyReport.Results) {
        if ($result.Vulnerabilities) {
            foreach ($vuln in $result.Vulnerabilities) {
                $vulnCount[$vuln.Severity]++
            }
        }
    }
    
    Write-Host ""
    Write-Host "Resumen de Vulnerabilidades:" -ForegroundColor White
    Write-Host "  CRITICAL: $($vulnCount.CRITICAL)" -ForegroundColor $(if($vulnCount.CRITICAL -gt 0){"Red"}else{"Green"})
    Write-Host "  HIGH:     $($vulnCount.HIGH)" -ForegroundColor $(if($vulnCount.HIGH -gt 0){"Red"}else{"Green"})
    Write-Host "  MEDIUM:   $($vulnCount.MEDIUM)" -ForegroundColor $(if($vulnCount.MEDIUM -gt 0){"Yellow"}else{"Green"})
    Write-Host "  LOW:      $($vulnCount.LOW)" -ForegroundColor $(if($vulnCount.LOW -gt 0){"Yellow"}else{"Green"})
    Write-Host "  UNKNOWN:  $($vulnCount.UNKNOWN)" -ForegroundColor Gray
    
    Write-Host ""
    Write-Host "Interpretación:" -ForegroundColor Cyan
    if ($vulnCount.CRITICAL -gt 0) {
        Write-Host "  [!] ACCIÓN INMEDIATA REQUERIDA" -ForegroundColor Red
        Write-Host "      Las vulnerabilidades CRÍTICAS deben corregirse antes de deployment" -ForegroundColor Red
    } elseif ($vulnCount.HIGH -gt 0) {
        Write-Host "  [!] ATENCIÓN NECESARIA" -ForegroundColor Yellow
        Write-Host "      Las vulnerabilidades HIGH deberían corregirse pronto" -ForegroundColor Yellow
    } else {
        Write-Host "  [✓] Estado aceptable para desarrollo" -ForegroundColor Green
    }
    
    # Top 5 vulnerabilidades más críticas
    Write-Host ""
    Write-Host "Top 5 Vulnerabilidades Críticas/High:" -ForegroundColor White
    $topVulns = @()
    foreach ($result in $trivyReport.Results) {
        if ($result.Vulnerabilities) {
            foreach ($vuln in $result.Vulnerabilities) {
                if ($vuln.Severity -in @("CRITICAL", "HIGH")) {
                    $topVulns += [PSCustomObject]@{
                        ID = $vuln.VulnerabilityID
                        Package = $vuln.PkgName
                        Version = $vuln.InstalledVersion
                        Fixed = $vuln.FixedVersion
                        Severity = $vuln.Severity
                        Title = $vuln.Title
                    }
                }
            }
        }
    }
    
    $topVulns | Select-Object -First 5 | ForEach-Object {
        Write-Host ""
        Write-Host "  CVE: $($_.ID)" -ForegroundColor $(if($_.Severity -eq "CRITICAL"){"Red"}else{"Yellow"})
        Write-Host "  Package: $($_.Package) ($($_.Version))" -ForegroundColor White
        Write-Host "  Fixed in: $($_.Fixed)" -ForegroundColor Green
        Write-Host "  Title: $($_.Title)" -ForegroundColor Gray
    }
    
} else {
    Write-Host "[!] No se encontró reporte de Trivy" -ForegroundColor Yellow
}

# ===================================================================
# ANÁLISIS DE NPM AUDIT
# ===================================================================
Write-Host ""
Write-Host "======================================" -ForegroundColor Yellow
Write-Host "ANÁLISIS DE DEPENDENCIAS (NPM AUDIT)" -ForegroundColor Yellow
Write-Host "======================================" -ForegroundColor Yellow

$npmAuditPath = Join-Path $ReportDir "npm-audit-report.json"
if (Test-Path $npmAuditPath) {
    $npmReport = Get-Content $npmAuditPath | ConvertFrom-Json
    
    if ($npmReport.metadata) {
        $meta = $npmReport.metadata.vulnerabilities
        
        Write-Host ""
        Write-Host "Resumen de Dependencias:" -ForegroundColor White
        Write-Host "  Critical: $($meta.critical)" -ForegroundColor $(if($meta.critical -gt 0){"Red"}else{"Green"})
        Write-Host "  High:     $($meta.high)" -ForegroundColor $(if($meta.high -gt 0){"Red"}else{"Green"})
        Write-Host "  Moderate: $($meta.moderate)" -ForegroundColor $(if($meta.moderate -gt 0){"Yellow"}else{"Green"})
        Write-Host "  Low:      $($meta.low)" -ForegroundColor $(if($meta.low -gt 0){"Yellow"}else{"Green"})
        
        Write-Host ""
        Write-Host "Interpretación:" -ForegroundColor Cyan
        if ($meta.critical -gt 0 -or $meta.high -gt 0) {
            Write-Host "  [!] Ejecuta 'npm audit fix' para corregir automáticamente" -ForegroundColor Yellow
            Write-Host "  [!] Algunas vulnerabilidades pueden requerir actualización manual" -ForegroundColor Yellow
        } else {
            Write-Host "  [✓] Dependencias en buen estado" -ForegroundColor Green
        }
    }
} else {
    Write-Host "[!] No se encontró reporte de npm audit" -ForegroundColor Yellow
}

# ===================================================================
# ANÁLISIS DE HADOLINT
# ===================================================================
Write-Host ""
Write-Host "======================================" -ForegroundColor Yellow
Write-Host "ANÁLISIS DE DOCKERFILE (HADOLINT)" -ForegroundColor Yellow
Write-Host "======================================" -ForegroundColor Yellow

$hadolintPath = Join-Path $ReportDir "hadolint-report.txt"
if (Test-Path $hadolintPath) {
    $hadolintContent = Get-Content $hadolintPath
    
    if ($hadolintContent.Length -eq 0) {
        Write-Host ""
        Write-Host "[✓] Dockerfile cumple con todas las mejores prácticas" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "Se encontraron las siguientes mejoras recomendadas:" -ForegroundColor Yellow
        Write-Host ""
        $hadolintContent | ForEach-Object { Write-Host "  $_" -ForegroundColor White }
        
        Write-Host ""
        Write-Host "Interpretación:" -ForegroundColor Cyan
        Write-Host "  Las recomendaciones de Hadolint mejoran:" -ForegroundColor White
        Write-Host "    - Seguridad del contenedor" -ForegroundColor White
        Write-Host "    - Tamaño de la imagen" -ForegroundColor White
        Write-Host "    - Reproducibilidad del build" -ForegroundColor White
        Write-Host "    - Mantenibilidad del Dockerfile" -ForegroundColor White
    }
} else {
    Write-Host "[!] No se encontró reporte de Hadolint" -ForegroundColor Yellow
}

# ===================================================================
# RECOMENDACIONES GENERALES
# ===================================================================
Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "RECOMENDACIONES GENERALES" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "1. PRIORIZACIÓN DE CORRECCIONES:" -ForegroundColor Yellow
Write-Host "   a) Vulnerabilidades CRITICAL en imagen" -ForegroundColor White
Write-Host "   b) Vulnerabilidades CRITICAL en dependencias" -ForegroundColor White
Write-Host "   c) Vulnerabilidades HIGH" -ForegroundColor White
Write-Host "   d) Mejoras de Dockerfile" -ForegroundColor White
Write-Host "   e) Vulnerabilidades MEDIUM/LOW" -ForegroundColor White
Write-Host ""

Write-Host "2. ESTRATEGIAS DE MITIGACIÓN:" -ForegroundColor Yellow
Write-Host "   - Actualizar imagen base (node:18-alpine a versión más reciente)" -ForegroundColor White
Write-Host "   - Ejecutar 'npm audit fix' para dependencias" -ForegroundColor White
Write-Host "   - Actualizar dependencias manualmente si es necesario" -ForegroundColor White
Write-Host "   - Considerar imágenes base alternativas (distroless, slim)" -ForegroundColor White
Write-Host ""

Write-Host "3. AUTOMATIZACIÓN:" -ForegroundColor Yellow
Write-Host "   - Integra este pipeline en CI/CD (GitHub Actions, GitLab CI)" -ForegroundColor White
Write-Host "   - Configura escaneos periódicos (nightly builds)" -ForegroundColor White
Write-Host "   - Establece políticas de aceptación (ej: 0 CRITICAL)" -ForegroundColor White
Write-Host ""

Write-Host "4. MONITOREO CONTINUO:" -ForegroundColor Yellow
Write-Host "   - Revisa reportes después de cada cambio" -ForegroundColor White
Write-Host "   - Mantén base de datos de Trivy actualizada" -ForegroundColor White
Write-Host "   - Suscríbete a alertas de seguridad de dependencias" -ForegroundColor White
Write-Host ""

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Fin del análisis" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
