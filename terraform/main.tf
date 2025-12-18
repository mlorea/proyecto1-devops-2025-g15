#############################
# TERRAFORM Y PROVIDERS
#############################

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

#############################
# RED: VPC POR DEFECTO + SUBNETS
#############################

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_security_group" "todo_sg" {
  name        = "todo-app-sg"
  description = "Allow HTTP to todo app and monitoring"
  vpc_id      = data.aws_vpc.default.id

  # Puerto de la app
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Puerto de Prometheus
  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Puerto de Grafana
  ingress {
    from_port   = 3001
    to_port     = 3001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Puerto de Alertmanager
  ingress {
    from_port   = 9093
    to_port     = 9093
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#############################
# ECS FARGATE
#############################

resource "aws_ecs_cluster" "this" {
  name = "proyecto1-todo-cluster"
}

resource "aws_iam_role" "task_execution" {
  name = "todo-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "task_execution" {
  role       = aws_iam_role.task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "todo" {
  family                   = "proyecto1-todo-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "1024"
  memory                   = "2048"

  execution_role_arn = aws_iam_role.task_execution.arn

  container_definitions = jsonencode([
    # Container 1: Tu App
    {
      name      = "todo-app"
      image     = var.image
      essential = true
      portMappings = [
        {
          containerPort = 3000
          protocol      = "tcp"
        }
      ]
      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:3000/health || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/proyecto1-todo"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    },

    # Container 2: Prometheus
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
      dependsOn = [
        {
          containerName = "todo-app"
          condition     = "HEALTHY"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/proyecto1-prometheus"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    },

    # Container 3: Alertmanager
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
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/proyecto1-alertmanager"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    },

    # Container 4: Grafana
    {
      name      = "grafana"
      image     = var.grafana_image
      essential = true
      portMappings = [
        {
          containerPort = 3001
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "GF_SERVER_HTTP_PORT"
          value = "3001"
        },
        {
          name  = "GF_SECURITY_ADMIN_PASSWORD"
          value = "admin"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/proyecto1-grafana"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

# Servicio ECS (Cloud Map deshabilitado para evitar referencia inexistente)
resource "aws_ecs_service" "todo" {
  name            = "proyecto1-todo-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.todo.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  # 👉 DESHABILITAR CLOUD MAP:
  # service_registries {
  #   registry_arn = aws_service_discovery_service.todo.arn
  # }

  network_configuration {
    subnets          = data.aws_subnets.default.ids
    security_groups  = [aws_security_group.todo_sg.id]
    assign_public_ip = true
  }
}

# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "todo_app" {
  name              = "/ecs/proyecto1-todo"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "prometheus" {
  name              = "/ecs/proyecto1-prometheus"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "alertmanager" {
  name              = "/ecs/proyecto1-alertmanager"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "grafana" {
  name              = "/ecs/proyecto1-grafana"
  retention_in_days = 7
}

# Outputs útiles y seguros
output "ecs_service_name" {
  description = "Nombre del servicio ECS"
  value       = aws_ecs_service.todo.name
}

output "ecs_cluster_name" {
  description = "Nombre del cluster ECS"
  value       = aws_ecs_cluster.this.name
}

output "cloudwatch_log_groups" {
  description = "Grupos de logs de CloudWatch para monitoreo"
  value = {
    app          = aws_cloudwatch_log_group.todo_app.name
    prometheus   = aws_cloudwatch_log_group.prometheus.name
    alertmanager = aws_cloudwatch_log_group.alertmanager.name
    grafana      = aws_cloudwatch_log_group.grafana.name
  }
}
