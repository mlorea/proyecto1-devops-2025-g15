############################################
# VARIABLES (imágenes + acceso UI)
############################################

variable "prometheus_image" {
  type        = string
  description = "ECR image URI for Prometheus"
}

variable "alertmanager_image" {
  type        = string
  description = "ECR image URI for Alertmanager"
}

variable "grafana_image" {
  type        = string
  description = "ECR image URI for Grafana"
}

variable "frontend_image" {
  type        = string
  description = "ECR image URI for Frontend (nginx + vite build)"
}

# Para lab: podés dejar 0.0.0.0/0, pero ideal es tu IP pública /32
variable "ui_allowed_cidr" {
  type        = string
  description = "CIDR allowed to access Grafana/Prometheus/Alertmanager/Frontend UIs"
  default     = "0.0.0.0/0"
}

############################################
# CLOUD MAP (namespace interno)
############################################

resource "aws_service_discovery_private_dns_namespace" "internal" {
  name = "internal"
  vpc  = data.aws_vpc.default.id
}

# API: todo.internal
resource "aws_service_discovery_service" "todo" {
  name = "todo"

  dns_config {
    namespace_id   = aws_service_discovery_private_dns_namespace.internal.id
    routing_policy = "MULTIVALUE"

    dns_records {
      type = "A"
      ttl  = 10
    }
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

# Alertmanager: alertmanager.internal
resource "aws_service_discovery_service" "alertmanager" {
  name = "alertmanager"

  dns_config {
    namespace_id   = aws_service_discovery_private_dns_namespace.internal.id
    routing_policy = "MULTIVALUE"

    dns_records {
      type = "A"
      ttl  = 10
    }
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

# Prometheus: prometheus.internal
resource "aws_service_discovery_service" "prometheus" {
  name = "prometheus"

  dns_config {
    namespace_id   = aws_service_discovery_private_dns_namespace.internal.id
    routing_policy = "MULTIVALUE"

    dns_records {
      type = "A"
      ttl  = 10
    }
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

############################################
# SECURITY GROUPS (UIs públicas)
############################################

resource "aws_security_group" "prometheus_sg" {
  name        = "prometheus-ui-sg"
  description = "Allow access to Prometheus UI"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = [var.ui_allowed_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "alertmanager_sg" {
  name        = "alertmanager-ui-sg"
  description = "Allow access to Alertmanager UI"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 9093
    to_port     = 9093
    protocol    = "tcp"
    cidr_blocks = [var.ui_allowed_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "grafana_sg" {
  name        = "grafana-ui-sg"
  description = "Allow access to Grafana UI"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = [var.ui_allowed_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "frontend_sg" {
  name        = "frontend-ui-sg"
  description = "Allow access to Frontend UI (HTTP 80)"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.ui_allowed_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

############################################
# TASK DEFINITIONS
############################################

resource "aws_ecs_task_definition" "prometheus" {
  family                   = "proyecto1-prometheus"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.task_execution.arn

  container_definitions = jsonencode([
    {
      name      = "prometheus"
      image     = var.prometheus_image
      essential = true
      portMappings = [
        {
          containerPort = 9090
          protocol      = "tcp"
        }
      ]
    }
  ])
}

resource "aws_ecs_task_definition" "alertmanager" {
  family                   = "proyecto1-alertmanager"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.task_execution.arn

  container_definitions = jsonencode([
    {
      name      = "alertmanager"
      image     = var.alertmanager_image
      essential = true
      portMappings = [
        {
          containerPort = 9093
          protocol      = "tcp"
        }
      ]
    }
  ])
}

resource "aws_ecs_task_definition" "grafana" {
  family                   = "proyecto1-grafana"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.task_execution.arn

  container_definitions = jsonencode([
    {
      name      = "grafana"
      image     = var.grafana_image
      essential = true
      portMappings = [
        {
          containerPort = 3000
          protocol      = "tcp"
        }
      ]
    }
  ])
}

resource "aws_ecs_task_definition" "frontend" {
  family                   = "proyecto1-frontend"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.task_execution.arn

  container_definitions = jsonencode([
    {
      name      = "frontend"
      image     = var.frontend_image
      essential = true
      portMappings = [
        {
          containerPort = 80
          protocol      = "tcp"
        }
      ]
    }
  ])
}

############################################
# ECS SERVICES (con IP pública)
############################################

resource "aws_ecs_service" "prometheus" {
  name            = "proyecto1-prometheus"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.prometheus.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  service_registries {
    registry_arn = aws_service_discovery_service.prometheus.arn
  }

  network_configuration {
    subnets          = data.aws_subnets.default.ids
    security_groups  = [aws_security_group.prometheus_sg.id]
    assign_public_ip = true
  }
}

resource "aws_ecs_service" "alertmanager" {
  name            = "proyecto1-alertmanager"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.alertmanager.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  service_registries {
    registry_arn = aws_service_discovery_service.alertmanager.arn
  }

  network_configuration {
    subnets          = data.aws_subnets.default.ids
    security_groups  = [aws_security_group.alertmanager_sg.id]
    assign_public_ip = true
  }
}

resource "aws_ecs_service" "grafana" {
  name            = "proyecto1-grafana"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.grafana.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = data.aws_subnets.default.ids
    security_groups  = [aws_security_group.grafana_sg.id]
    assign_public_ip = true
  }
}

resource "aws_ecs_service" "frontend" {
  name            = "proyecto1-frontend"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.frontend.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = data.aws_subnets.default.ids
    security_groups  = [aws_security_group.frontend_sg.id]
    assign_public_ip = true
  }
}

############################################
# OUTPUTS
############################################

output "monitoring_service_names" {
  value = {
    prometheus   = aws_ecs_service.prometheus.name
    alertmanager = aws_ecs_service.alertmanager.name
    grafana      = aws_ecs_service.grafana.name
    frontend     = aws_ecs_service.frontend.name
  }
}
