variable "cidr_block" {
    default = "10.0.0.0/16"
}
variable "project_name" {
    default = "roboshop"
}

variable "environment" {
    default = "dev"
}

variable "ig_tags" {
    default = "roboshop-ig"
}

variable "subnet_private_cidrs" {
    default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "subnet_public_cidrs" {
    default = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "subnet_database_cidrs" {
    default = ["10.0.21.0/24", "10.0.22.0/24"]
}

variable "private_route_table_tags" {
    default = {}
  
}

variable "public_route_table_tags" {
    default = {}
  
}

variable "database_route_table_tags" {
    default = {}
  
}