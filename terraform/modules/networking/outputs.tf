output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "public_subnet_ids" {
  description = "List of IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "List of IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "public_subnet_cidrs" {
  description = "List of CIDR blocks of the public subnets"
  value       = aws_subnet.public[*].cidr_block
}

output "private_subnet_cidrs" {
  description = "List of CIDR blocks of the private subnets"
  value       = aws_subnet.private[*].cidr_block
}

output "nat_gateway_ids" {
  description = "List of IDs of the NAT Gateways"
  value       = aws_nat_gateway.main[*].id
}

output "nat_gateway_public_ips" {
  description = "List of public Elastic IPs associated with NAT Gateways"
  value       = aws_eip.nat[*].public_ip
}
