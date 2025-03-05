locals {
  vpc_id           = split("/", var.vpc.data.infrastructure.arn)[1]
  public_subnet_id = split("/", var.vpc.data.infrastructure.public_subnets[0].arn)[1]
  public_subnet_ip = cidrhost(data.aws_subnet.public.cidr_block, 2)
}

data "aws_vpc" "lookup" {
  id = local.vpc_id
}

data "aws_subnet" "public" {
  id = local.public_subnet_id
}

resource "aws_ec2_client_vpn_endpoint" "vpn" {
  vpc_id                 = local.vpc_id
  client_cidr_block      = local.cidr
  server_certificate_arn = aws_acm_certificate.server.arn
  security_group_ids     = [aws_security_group.vpn.id]
  split_tunnel           = var.network.split_tunnel
  dns_servers            = [local.public_subnet_ip]

  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = aws_acm_certificate.ca.arn
  }
  connection_log_options {
    enabled               = var.logging.enable
    cloudwatch_log_group  = var.logging.enable ? aws_cloudwatch_log_group.vpn[0].name : null
    cloudwatch_log_stream = var.logging.enable ? aws_cloudwatch_log_stream.vpn[0].name : null
  }
}

resource "aws_ec2_client_vpn_network_association" "association" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn.id
  subnet_id              = local.public_subnet_id
}

resource "aws_ec2_client_vpn_authorization_rule" "rule" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn.id
  target_network_cidr    = data.aws_vpc.lookup.cidr_block
  authorize_all_groups   = true
}
