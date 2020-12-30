resource aws_vpc default {
  cidr_block           = var.cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = var.tags
}

#
# Public Resources
#
resource aws_subnet public {
  for_each          = var.subnets.public
  vpc_id            = aws_vpc.default.id
  availability_zone = each.key
  cidr_block        = each.value

  tags = merge(var.tags, {
    Tier = "public"
    Name = "${var.prefix}public-${each.key}${var.suffix}"
  })
}

resource aws_internet_gateway default {
  vpc_id = aws_vpc.default.id

  tags = merge(var.tags, {
    Name = "${var.prefix}igw${var.suffix}"
  })
}

resource aws_route_table public {
  vpc_id = aws_vpc.default.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default.id
  }

  tags = merge(var.tags, {
    "Tier" = "public"
    "Name" = "${var.prefix}public${var.suffix}"
  })
}

resource aws_route_table_association public {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

#
# Private Resources
#
resource aws_subnet private {
  for_each          = var.subnets.private
  vpc_id            = aws_vpc.default.id
  availability_zone = each.key
  cidr_block        = each.value

  tags = merge(var.tags, {
    "Tier" = "private"
    "Name" = "${var.prefix}private-${each.key}${var.suffix}"
  })
}

resource aws_eip private {
  for_each = var.enable_nat_gateway ? var.subnets.private : {}
  vpc      = true

  tags = merge(var.tags, {
    "Name" = "${var.prefix}natgw-${each.key}${var.suffix}"
  })
}

resource aws_nat_gateway default {
  for_each      = var.enable_nat_gateway ? aws_subnet.private : {}
  allocation_id = aws_eip.private[each.key].id
  subnet_id     = each.value.id

  tags = merge(var.tags, {
    "Name" = "${var.prefix}${each.key}${var.suffix}"
  })
}

resource aws_route_table private {
  vpc_id   = aws_vpc.default.id

  dynamic route {
    for_each = aws_nat_gateway.default
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = route.value.id
    }
  }

  tags = merge(var.tags, {
    "Tier" = "private"
    "Name" = "${var.prefix}private${var.suffix}"
  })
}

resource aws_route_table_association private {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}
