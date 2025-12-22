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
    description    = "App port (temporary direct access)"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = var.app_port
  }

  ingress {
    protocol       = "TCP"
    description    = "HTTP to ALB"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  egress {
    protocol       = "ANY"
    description    = "Allow all egress"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}
