
resource "aws_security_group" "vpn" {
  name        = var.md_metadata.name_prefix
  description = "Control traffic from VPN clients"
  vpc_id      = local.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "all" {
  security_group_id = aws_security_group.vpn.id
  ip_protocol       = "-1"
  #checkov:skip=CKV_AWS_24,CKV_AWS_25,CKV_AWS_260,CKV_AWS_277:Allowing all traffic since its over VPN. This can be customized if more strict rules are preferred/required.
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.vpn.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}