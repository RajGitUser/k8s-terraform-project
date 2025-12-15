locals {
    common_tags = {
        project_name = var.project_name
        environment = var.environment
        terraform = true
    }
    az_names = slice(data.aws_availability_zones.available.names, 0, 2 )
}