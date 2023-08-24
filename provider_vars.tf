variable "environment" {
  type = string
  description = "Environment in which to deploy application"
}

variable "project" {
  type = string
  description = "Project that infrastructure is attached to"
}

variable "region" {
  type = string
  description = "AWS deployment region"
}

variable "availability_zone" {
  type = string
  description = "AWS availability zone"
}
