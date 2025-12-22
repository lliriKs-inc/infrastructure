variable "cloud_id" {
  type = string
}

variable "folder_id" {
  type = string
}

variable "zone" {
  type    = string
  default = "ru-central1-a"
}

variable "network_name" {
  type    = string
  default = "vet-net"
}

variable "subnet_name" {
  type    = string
  default = "vet-subnet-a"
}

variable "subnet_cidr" {
  type    = string
  default = "10.10.0.0/24"
}

variable "vm_user" {
  type    = string
  default = "ubuntu"
}

variable "ssh_public_key" {
  type        = string
  description = "Public SSH key"
}

variable "ig_size" {
  type    = number
  default = 2
}

variable "app_port" {
  type    = number
  default = 8084
}

variable "health_path" {
  type    = string
  default = "/health"
}

variable "repo_url" {
  type    = string
  default = "https://github.com/lliriKs-inc/vet-yandex-proj/"
}
