#!/usr/bin/env pwsh
# Script para instalar herramientas de seguridad en Windows
# Este script facilita la instalación de todas las herramientas necesarias

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "INSTALADOR DE HERRAMIENTAS DE SEGURIDAD" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# Verificar si Chocolatey está instalado
Write-Host "[INFO] Verificando Chocolatey..." -ForegroundColor Blue
if (Get-Command choco -ErrorAction SilentlyContinue) {
    Write-Host "[✓] Chocolatey está instalado" -ForegroundColor Green
} else {
    Write-Host "[!] Chocolatey no está instalado" -ForegroundColor Red
    Write-Host "[INFO] Instalando Chocolatey..." -ForegroundColor Blue
    Write-Host "[INFO] Necesitarás ejecutar PowerShell como Administrador" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Ejecuta este comando en PowerShell como Administrador:" -ForegroundColor Yellow
    Write-Host "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))" -ForegroundColor Cyan
    Write-Host ""
    Read-Host "Presiona Enter después de instalar Chocolatey"
}

Write-Host ""
Write-Host "======================================" -ForegroundColor Yellow
Write-Host "Instalando herramientas..." -ForegroundColor Yellow
Write-Host "======================================" -ForegroundColor Yellow

# Instalar Hadolint
Write-Host ""
Write-Host "[1/3] Instalando Hadolint..." -ForegroundColor Blue
if (Get-Command hadolint -ErrorAction SilentlyContinue) {
    Write-Host "[✓] Hadolint ya está instalado" -ForegroundColor Green
    hadolint --version
} else {
    Write-Host "[INFO] Instalando con Chocolatey..." -ForegroundColor Blue
    choco install hadolint -y
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[✓] Hadolint instalado correctamente" -ForegroundColor Green
    } else {
        Write-Host "[!] Error al instalar Hadolint" -ForegroundColor Red
        Write-Host "[INFO] Instala manualmente desde: https://github.com/hadolint/hadolint/releases" -ForegroundColor Yellow
    }
}

# Instalar Trivy
Write-Host ""
Write-Host "[2/3] Instalando Trivy..." -ForegroundColor Blue
if (Get-Command trivy -ErrorAction SilentlyContinue) {
    Write-Host "[✓] Trivy ya está instalado" -ForegroundColor Green
    trivy --version
} else {
    Write-Host "[INFO] Instalando con Chocolatey..." -ForegroundColor Blue
    choco install trivy -y
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[✓] Trivy instalado correctamente" -ForegroundColor Green
    } else {
        Write-Host "[!] Error al instalar Trivy" -ForegroundColor Red
        Write-Host "[INFO] Instala manualmente desde: https://github.com/aquasecurity/trivy/releases" -ForegroundColor Yellow
    }
}

# Instalar SonarScanner (opcional)
Write-Host ""
Write-Host "[3/3] Instalando SonarScanner (opcional)..." -ForegroundColor Blue
if (Get-Command sonar-scanner -ErrorAction SilentlyContinue) {
    Write-Host "[✓] SonarScanner ya está instalado" -ForegroundColor Green
    sonar-scanner --version
} else {
    Write-Host "[INFO] Instalando con Chocolatey..." -ForegroundColor Blue
    choco install sonarscanner -y
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[✓] SonarScanner instalado correctamente" -ForegroundColor Green
    } else {
        Write-Host "[!] Error al instalar SonarScanner" -ForegroundColor Red
        Write-Host "[INFO] Instala manualmente desde: https://docs.sonarqube.org/latest/analysis/scan/sonarscanner/" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "RESUMEN DE INSTALACIÓN" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# Verificar todas las herramientas
$tools = @("hadolint", "trivy", "docker", "node", "npm")
foreach ($tool in $tools) {
    if (Get-Command $tool -ErrorAction SilentlyContinue) {
        Write-Host "[✓] $tool - Instalado" -ForegroundColor Green
    } else {
        Write-Host "[✗] $tool - NO instalado" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "¡Instalación completada!" -ForegroundColor Green
Write-Host "Ahora puedes ejecutar: ./security-pipeline.ps1" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
