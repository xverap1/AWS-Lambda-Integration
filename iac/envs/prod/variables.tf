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
