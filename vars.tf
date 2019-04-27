variable "region" {
  default = "us-east-1"
}

variable "name" {
  default = "geek-api"
}

variable "docdb_instance_class" {
  default = "db.r4.large"
}

variable "docdb_password" {}

# optional
variable "certificate_arn" {}
variable "zone_id" {}
variable "main_domain" {}