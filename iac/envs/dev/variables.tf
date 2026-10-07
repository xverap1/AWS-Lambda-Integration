variable "environment" {
  description = "Ambiente de despliegue"
  type        = string
}

variable "region" {
  description = "Región de AWS"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block para la VPC"
  type        = string
}

variable "enable_nat_gateway" {
  description = "Habilitar NAT Gateway"
  type        = bool
  default     = false
}
