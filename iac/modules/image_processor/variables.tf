variable "environment" {
  description = "Ambiente de despliegue (dev, qa, prod)"
  type        = string
}

variable "region" {
  description = "Región de AWS"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block para la VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# NAT Gateway genera costo conectar si es necesario
variable "enable_nat_gateway" {
  description = "Habilitar NAT Gateway"
  type        = bool
  default     = false
}
