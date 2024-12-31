
resource "aws_cloudwatch_log_group" "vpn" {
  count             = var.logging.enable ? 1 : 0
  name              = "/aws/vpn/${var.md_metadata.name_prefix}"
  retention_in_days = var.logging.enable ? var.logging.retention_days : 0
}

resource "aws_cloudwatch_log_stream" "vpn" {
  count          = var.logging.enable ? 1 : 0
  name           = "logs"
  log_group_name = aws_cloudwatch_log_group.vpn[0].name
}
