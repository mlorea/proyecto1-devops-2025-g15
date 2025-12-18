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
  region = var.aws_region  # ← Usa la variable, pero NO la declares aquí
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
  description = "Allow HTTP to todo app"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 3000
    to_port     = 3000
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
  cpu                      = "256"
  memory                   = "512"

  execution_role_arn = aws_iam_role.task_execution.arn

  container_definitions = jsonencode([
    {
      name      = "todo-app"
      image     = var.image  # ← Usa la variable
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

# IMPORTANTE: se registra en Cloud Map (definido en monitoring.tf)
resource "aws_ecs_service" "todo" {
  name            = "proyecto1-todo-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.todo.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  # Registro DNS interno: todo.internal
  service_registries {
    registry_arn = aws_service_discovery_service.todo.arn
  }

  network_configuration {
    subnets          = data.aws_subnets.default.ids
    security_groups  = [aws_security_group.todo_sg.id]
    assign_public_ip = true
  }
}

output "ecs_service_name" {
  value = aws_ecs_service.todo.name
}