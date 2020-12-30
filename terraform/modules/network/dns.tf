resource aws_route53_zone local {
  name = var.private_zone_name
  tags = var.tags

  vpc {
    vpc_id     = aws_vpc.default.id
    vpc_region = data.aws_region.current.name
  }
}
