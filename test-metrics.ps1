# Test script to generate metrics data
Write-Host "Generando datos de prueba para el monitoreo..." -ForegroundColor Cyan

$baseUrl = "http://localhost:3000"

# Test 1: Create some tasks
Write-Host "`nCreando tareas..." -ForegroundColor Yellow
$tasks = @(
    @{ title = "Implementar CI/CD" },
    @{ title = "Configurar Terraform" },
    @{ title = "Setup de Docker" },
    @{ title = "Implementar monitoreo" },
    @{ title = "Revisar seguridad" }
)

$createdIds = @()
foreach ($task in $tasks) {
    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/tasks" -Method Post -Body ($task | ConvertTo-Json) -ContentType "application/json" -UseBasicParsing
        Write-Host "  [OK] Tarea creada: $($response.title) (ID: $($response.id))" -ForegroundColor Green
        $createdIds += $response.id
    }
    catch {
        Write-Host "  [ERROR] Error creando tarea: $_" -ForegroundColor Red
    }
}

Start-Sleep -Seconds 1

# Test 2: List all tasks
Write-Host "`nListando todas las tareas..." -ForegroundColor Yellow
try {
    $allTasks = Invoke-RestMethod -Uri "$baseUrl/tasks" -Method Get -UseBasicParsing
    Write-Host "  [OK] Total de tareas: $($allTasks.Count)" -ForegroundColor Green
}
catch {
    Write-Host "  [ERROR] Error listando tareas: $_" -ForegroundColor Red
}

Start-Sleep -Seconds 1

# Test 3: Update some tasks
Write-Host "`nActualizando tareas..." -ForegroundColor Yellow
if ($createdIds.Count -gt 0) {
    $updateData = @{ completed = $true }
    for ($i = 0; $i -lt [Math]::Min(2, $createdIds.Count); $i++) {
        try {
            $response = Invoke-RestMethod -Uri "$baseUrl/tasks/$($createdIds[$i])" -Method Put -Body ($updateData | ConvertTo-Json) -ContentType "application/json" -UseBasicParsing
            Write-Host "  [OK] Tarea actualizada: $($response.title)" -ForegroundColor Green
        }
        catch {
            Write-Host "  [ERROR] Error actualizando tarea: $_" -ForegroundColor Red
        }
    }
}

Start-Sleep -Seconds 1

# Test 4: Get individual tasks
Write-Host "`nObteniendo tareas individuales..." -ForegroundColor Yellow
foreach ($id in $createdIds | Select-Object -First 3) {
    try {
        $task = Invoke-RestMethod -Uri "$baseUrl/tasks/$id" -Method Get -UseBasicParsing
        Write-Host "  [OK] Tarea obtenida: $($task.title)" -ForegroundColor Green
    }
    catch {
        Write-Host "  [ERROR] Error obteniendo tarea: $_" -ForegroundColor Red
    }
}

Start-Sleep -Seconds 1

# Test 5: Delete a task
Write-Host "`nEliminando una tarea..." -ForegroundColor Yellow
if ($createdIds.Count -gt 0) {
    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/tasks/$($createdIds[-1])" -Method Delete -UseBasicParsing
        Write-Host "  [OK] Tarea eliminada" -ForegroundColor Green
    }
    catch {
        Write-Host "  [ERROR] Error eliminando tarea: $_" -ForegroundColor Red
    }
}

Start-Sleep -Seconds 1

# Test 6: Test 404 error
Write-Host "`nProbando error 404..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/tasks/nonexistent" -Method Get -UseBasicParsing
}
catch {
    Write-Host "  [OK] Error 404 capturado correctamente" -ForegroundColor Green
}

Start-Sleep -Seconds 1

# Test 7: Generate some load
Write-Host "`nGenerando carga de requests..." -ForegroundColor Yellow
for ($i = 1; $i -le 10; $i++) {
    try {
        Invoke-RestMethod -Uri "$baseUrl/tasks" -Method Get -UseBasicParsing | Out-Null
        Write-Host "  [OK] Request $i/10 completado" -ForegroundColor Green
    }
    catch {
        Write-Host "  [ERROR] Request $i/10 fallo" -ForegroundColor Red
    }
    Start-Sleep -Milliseconds 100
}

# Summary
Write-Host "`nResumen de pruebas completado!" -ForegroundColor Cyan
Write-Host "`nAhora puedes verificar:" -ForegroundColor White
Write-Host "  - Metricas: http://localhost:3000/metrics" -ForegroundColor Gray
Write-Host "  - Prometheus: http://localhost:9090" -ForegroundColor Gray
Write-Host "  - Grafana: http://localhost:3001 (admin/admin)" -ForegroundColor Gray
Write-Host "  - AlertManager: http://localhost:9093" -ForegroundColor Gray
Write-Host "`nEjemplos de consultas en Prometheus:" -ForegroundColor White
Write-Host "  - rate(http_requests_total[5m])" -ForegroundColor Gray
Write-Host "  - tasks_total" -ForegroundColor Gray
Write-Host "  - http_request_duration_seconds_bucket" -ForegroundColor Gray
