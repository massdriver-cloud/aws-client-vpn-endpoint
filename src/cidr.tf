locals {
  cidr = var.network.automatic ? utility_available_cidr.cidr[0].result : var.network.cidr
  peered_vpc_cidrs = flatten([
    for connection in data.aws_vpc_peering_connections.peers.ids : [
      data.aws_vpc_peering_connection.peer_cidr_block[connection].cidr_block
    ]
  ])
}

data "aws_vpc_peering_connections" "peers" {
  filter {
    name   = "requester-vpc-info.vpc-id"
    values = [local.vpc_id]
  }
}

data "aws_vpc_peering_connection" "peer_cidr_block" {
  for_each = toset(data.aws_vpc_peering_connections.peers.ids)
  id       = each.key
}

resource "utility_available_cidr" "cidr" {
  count      = var.network.automatic ? 1 : 0
  from_cidrs = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  used_cidrs = concat([data.aws_vpc.lookup.cidr_block], local.peered_vpc_cidrs)
  mask       = var.network.mask
}
