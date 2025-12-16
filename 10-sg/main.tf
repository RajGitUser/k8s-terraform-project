resource "aws_security_group" "sg" {
    count  = length(var.sg_names)
    name = var.sg_names[count.index]
    vpc_id = local.vpc_id

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    
  }
}