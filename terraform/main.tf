terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
      version = "~> 2.20"
    }
  }
}

provider "docker" {}

resource "docker_image" "todo_image" {
  name = "proyecto1-todo-api:latest"
  build {
    context = ".."
  }
}

resource "docker_container" "todo_app" {
  name  = "proyecto1_todo_app"
  image = docker_image.todo_image.latest
  ports {
    internal = 3000
    external = 3000
  }
}
