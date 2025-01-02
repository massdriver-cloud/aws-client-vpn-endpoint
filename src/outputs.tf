locals {
  # Need to strip out the '*.' prefix because it is not used for setting up VPN config.
  sanitized_dns_name = trimprefix(aws_ec2_client_vpn_endpoint.vpn.dns_name, "*.")
}

output "artifact_endpoint" {
  sensitive = true
  value = {
    data = {
      infrastructure = {
        arn      = aws_ec2_client_vpn_endpoint.vpn.arn
        dns_name = local.sanitized_dns_name
      }
      authentication = {
        ca_private_key_pem = tls_private_key.ca.private_key_pem
        ca_certificate_pem = tls_self_signed_cert.ca.cert_pem
      }
    }
    specs = {
      aws = {
        region = var.vpc.specs.aws.region
      }
    }
  }
}
