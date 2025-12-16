## aws VPC Creation
resource "aws_vpc" "main" {
  cidr_block       = var.cidr_block
  instance_tenancy = "default"
  enable_dns_hostnames = true

  tags = merge (
    local.common_tags,
    {
        Name = "${var.project_name}-${var.environment}-vpc"
    }
  )
}

## Creation of internet gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge (
    local.common_tags,
    {
        Name = var.ig_tags
    }
  )
}

## creation of private aws subnet
resource "aws_subnet" "private" {
  count = length(var.subnet_private_cidrs)
  cidr_block = var.subnet_private_cidrs[count.index]
  vpc_id     = aws_vpc.main.id
  availability_zone = local.az_names[count.index]

  tags = merge (
    local.common_tags,
    {
        Name = "${var.project_name}-${var.environment}-private"
    }
  )
}

## creation of public aws subnet
resource "aws_subnet" "public" {
  count = length(var.subnet_public_cidrs)
  cidr_block = var.subnet_public_cidrs[count.index]
  vpc_id     = aws_vpc.main.id
  availability_zone = local.az_names[count.index]

  tags = merge (
    local.common_tags,
    {
        Name = "${var.project_name}-${var.environment}-public"
    }
  )
}

## creation of database aws subnet
resource "aws_subnet" "database" {
  count = length(var.subnet_database_cidrs)
  cidr_block = var.subnet_database_cidrs[count.index]
  vpc_id     = aws_vpc.main.id
  availability_zone = local.az_names[count.index]

  tags = merge (
    local.common_tags,
    {
        Name = "${var.project_name}-${var.environment}-database"
    }
  )
}

## aws route table for private
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge (
    var.private_route_table_tags,
    local.common_tags,
    {
        Name = "${var.project_name}-${var.environment}-private"
    }
  )
}

## aws route table for public
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge (
    var.public_route_table_tags,
    local.common_tags,
    {
        Name = "${var.project_name}-${var.environment}-public"
    }
  )
}

## aws route table for database
resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

  tags = merge (
    var.database_route_table_tags,
    local.common_tags,
    {
        Name = "${var.project_name}-${var.environment}-database"
    }
  )
}

## Public Route
resource "aws_route" "public" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.main.id
}

## Elastic IP Creation
resource "aws_eip" "nat" {
  domain   = "vpc"

  tags = merge (
    local.common_tags,
    {
        Name = "${var.project_name}-${var.environment}-eip"
    }
  )
}

## NAT Gateway this will depend on internet gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge (
    local.common_tags,
    {
        Name = "${var.project_name}-${var.environment}-nat-gateway"
    }
  )

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.main]
}

## Private Route
resource "aws_route" "private" {
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat.id
}

## Database Route
resource "aws_route" "database" {
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat.id
}

## Route Table Association
resource "aws_route_table_association" "public" {
  count = length(var.subnet_public_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(var.subnet_private_cidrs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "database" {
  count = length(var.subnet_database_cidrs)
  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database.id
}