output "app_container_name" {
  description = "Nombre del servicio ECS"
  value       = aws_ecs_service.todo.name
}

output "ecs_cluster_name" {
  description = "Nombre del cluster ECS"
  value       = aws_ecs_cluster.this.name
}

# URLs de acceso (si configuras un Load Balancer después)
output "app_endpoint" {
  description = "Endpoint de la aplicación"
  value       = "http://${aws_ecs_service.todo.name}.local:3000"
}

output "prometheus_endpoint" {
  description = "Endpoint de Prometheus"
  value       = "http://${aws_ecs_service.todo.name}.local:9090"
}

output "grafana_endpoint" {
  description = "Endpoint de Grafana"
  value       = "http://${aws_ecs_service.todo.name}.local:3001"
}

output "alertmanager_endpoint" {
  description = "Endpoint de Alertmanager"
  value       = "http://${aws_ecs_service.todo.name}.local:9093"
}