locals {
  agents      = toset(["app", "data", "probe"])
  agent_ports = { for pair in setproduct(local.agents, [1514]) : "${pair[0]}-${pair[1]}" => { tier = pair[0], port = pair[1] } }
}
resource "aws_vpc_security_group_ingress_rule" "telemetry" {
  for_each                     = local.agent_ports
  security_group_id            = aws_security_group.tier["manager"].id
  referenced_security_group_id = aws_security_group.tier[each.value.tier].id
  ip_protocol                  = "tcp"
  from_port                    = each.value.port
  to_port                      = each.value.port
}
resource "aws_vpc_security_group_egress_rule" "telemetry" {
  for_each                     = local.agent_ports
  security_group_id            = aws_security_group.tier[each.value.tier].id
  referenced_security_group_id = aws_security_group.tier["manager"].id
  ip_protocol                  = "tcp"
  from_port                    = each.value.port
  to_port                      = each.value.port
}
resource "aws_s3_bucket" "packages" {
  bucket_prefix = "server-controls-packages-"
  force_destroy = false
}
resource "aws_s3_bucket_public_access_block" "packages" {
  bucket                  = aws_s3_bucket.packages.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
resource "aws_s3_bucket_server_side_encryption_configuration" "packages" {
  bucket = aws_s3_bucket.packages.id
  rule {
    apply_server_side_encryption_by_default { sse_algorithm = "AES256" }
  }
}
resource "aws_s3_bucket_policy" "packages" {
  bucket = aws_s3_bucket.packages.id
  policy = jsonencode({ Version = "2012-10-17", Statement = [{ Sid = "DenyInsecureTransport", Effect = "Deny", Principal = "*", Action = "s3:*", Resource = [aws_s3_bucket.packages.arn, "${aws_s3_bucket.packages.arn}/*"], Condition = { Bool = { "aws:SecureTransport" = "false" } } }] })
}
resource "aws_vpc_endpoint" "packages" {
  vpc_id            = aws_vpc.lab.id
  service_name      = "com.amazonaws.ap-southeast-2.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private.id]
  policy            = jsonencode({ Version = "2012-10-17", Statement = [{ Effect = "Allow", Principal = "*", Action = "s3:GetObject", Resource = "${aws_s3_bucket.packages.arn}/packages/*" }] })
}
resource "aws_vpc_security_group_egress_rule" "packages" {
  for_each          = aws_security_group.tier
  security_group_id = each.value.id
  prefix_list_id    = aws_vpc_endpoint.packages.prefix_list_id
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
}
output "package_bucket" { value = aws_s3_bucket.packages.id }
