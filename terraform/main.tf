terraform {
  required_version = ">= 1.6.0, < 2.0.0"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 6.0" }
  }
}
provider "aws" {
  region  = "ap-southeast-2"
  profile = "server-security-lab"
  default_tags {
    tags = { Project = "cloud-server-security-controls", Environment = "disposable-lab", ManagedBy = "Terraform" }
  }
}
variable "ami_id" {
  description = "Verified Sydney Amazon Linux 2023 x86_64 AMI with current SSM Agent. Pin after preflight."
  type        = string
  validation {
    condition     = can(regex("^ami-[0-9a-f]+$", var.ami_id))
    error_message = "Provide a verified AMI ID."
  }
}
variable "availability_zone" {
  description = "Verified available Sydney AZ; one AZ reduces endpoint costs."
  type        = string
  validation {
    condition     = can(regex("^ap-southeast-2[a-z]$", var.availability_zone))
    error_message = "Use an available Sydney AZ."
  }
}
resource "aws_vpc" "lab" {
  cidr_block           = "10.42.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = "server-controls-lab" }
}
resource "aws_subnet" "tier" {
  for_each                = { app = "10.42.10.0/24", data = "10.42.20.0/24", probe = "10.42.30.0/24", manager = "10.42.40.0/24" }
  vpc_id                  = aws_vpc.lab.id
  cidr_block              = each.value
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = false
  tags                    = { Name = "server-controls-${each.key}" }
}
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.lab.id
  tags   = { Name = "server-controls-private" }
}
resource "aws_route_table_association" "tier" {
  for_each       = aws_subnet.tier
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}
resource "aws_security_group" "tier" {
  for_each    = aws_subnet.tier
  name_prefix = "server-controls-${each.key}-"
  description = "Explicit rules only for ${each.key} tier"
  vpc_id      = aws_vpc.lab.id
}
resource "aws_security_group" "management" {
  name_prefix = "server-controls-management-"
  description = "Private Systems Manager endpoints"
  vpc_id      = aws_vpc.lab.id
}
resource "aws_vpc_security_group_ingress_rule" "management" {
  for_each                     = aws_security_group.tier
  security_group_id            = aws_security_group.management.id
  referenced_security_group_id = each.value.id
  ip_protocol                  = "tcp"
  from_port                    = 443
  to_port                      = 443
}
resource "aws_vpc_security_group_egress_rule" "management" {
  for_each                     = aws_security_group.tier
  security_group_id            = each.value.id
  referenced_security_group_id = aws_security_group.management.id
  ip_protocol                  = "tcp"
  from_port                    = 443
  to_port                      = 443
}
resource "aws_vpc_security_group_ingress_rule" "data_from_app" {
  security_group_id            = aws_security_group.tier["data"].id
  referenced_security_group_id = aws_security_group.tier["app"].id
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
}
resource "aws_vpc_security_group_egress_rule" "app_to_data" {
  security_group_id            = aws_security_group.tier["app"].id
  referenced_security_group_id = aws_security_group.tier["data"].id
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
}
# The probe is permitted to attempt connections; the destination must reject it.
resource "aws_vpc_security_group_egress_rule" "probe_to_data" {
  security_group_id            = aws_security_group.tier["probe"].id
  referenced_security_group_id = aws_security_group.tier["data"].id
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
}
resource "aws_vpc_endpoint" "management" {
  for_each            = toset(["ssm", "ssmmessages"])
  vpc_id              = aws_vpc.lab.id
  service_name        = "com.amazonaws.ap-southeast-2.${each.key}"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.tier["app"].id]
  security_group_ids  = [aws_security_group.management.id]
  private_dns_enabled = true
}
resource "aws_iam_role" "node" {
  name_prefix        = "server-controls-node-"
  assume_role_policy = jsonencode({ Version = "2012-10-17", Statement = [{ Effect = "Allow", Principal = { Service = "ec2.amazonaws.com" }, Action = "sts:AssumeRole" }] })
}
resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
resource "aws_iam_instance_profile" "node" {
  name_prefix = "server-controls-node-"
  role        = aws_iam_role.node.name
}
resource "aws_instance" "node" {
  for_each                    = aws_subnet.tier
  ami                         = var.ami_id
  instance_type               = each.key == "manager" ? "t3.small" : "t3.micro"
  subnet_id                   = each.value.id
  associate_public_ip_address = false
  vpc_security_group_ids      = [aws_security_group.tier[each.key].id]
  iam_instance_profile        = aws_iam_instance_profile.node.name
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }
  credit_specification { cpu_credits = "standard" }
  root_block_device {
    encrypted             = true
    volume_type           = "gp3"
    volume_size           = each.key == "manager" ? 20 : 8
    delete_on_termination = true
  }
  depends_on = [aws_vpc_endpoint.management, aws_iam_role_policy_attachment.ssm, aws_vpc_security_group_ingress_rule.management, aws_vpc_security_group_egress_rule.management]
  tags       = { Name = "server-controls-${each.key}", Tier = each.key }
}
output "nodes" {
  value = { for tier, node in aws_instance.node : tier => { id = node.id, private_ip = node.private_ip, security_group = aws_security_group.tier[tier].id } }
}
output "vpc_id" { value = aws_vpc.lab.id }
