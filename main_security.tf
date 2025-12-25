resource "yandex_vpc_security_group" "sg" {
  name       = "vet-sg"
  network_id = yandex_vpc_network.net.id


  ingress {
    protocol       = "TCP"
    description    = "SSH"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

  ingress {
    protocol       = "TCP"
    description    = "Application port from ALB and health checks"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = var.app_port
  }

  ingress {
    protocol       = "TCP"
    description    = "HTTP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }


  egress {
    protocol       = "TCP"
    description    = "PostgreSQL access"
    v4_cidr_blocks = [var.subnet_cidr]
    port           = 5432
  }

  egress {
    protocol       = "TCP"
    description    = "HTTPS for S3, Docker Hub, GitHub"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
  }

  egress {
    protocol       = "TCP"
    description    = "HTTP for package updates"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  egress {
    protocol       = "TCP"
    description    = "DNS"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 53
  }

  egress {
    protocol       = "UDP"
    description    = "DNS"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 53
  }
}

resource "yandex_vpc_security_group" "postgres_sg" {
  name       = "postgres-sg"
  network_id = yandex_vpc_network.net.id

  ingress {
    protocol       = "TCP"
    description    = "PostgreSQL from Instance Group"
    v4_cidr_blocks = [var.subnet_cidr]
    port           = 5432
  }

  ingress {
    protocol       = "TCP"
    description    = "SSH for maintenance"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

  egress {
    protocol       = "ANY"
    description    = "Allow all egress for updates and external connections"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

output "security_group_id" {
  value       = yandex_vpc_security_group.sg.id
  description = "Security Group ID for Instance Group"
}

output "postgres_security_group_id" {
  value       = yandex_vpc_security_group.postgres_sg.id
  description = "Security Group ID for PostgreSQL VM"
}
