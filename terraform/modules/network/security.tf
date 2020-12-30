resource aws_default_network_acl default {
  default_network_acl_id = aws_vpc.default.default_network_acl_id

  subnet_ids = concat(
    [for subnet in aws_subnet.public  : subnet.id],
    [for subnet in aws_subnet.private : subnet.id]
  )

  egress {
    rule_no    = 100
    protocol   = "all"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    rule_no    = 100
    protocol   = "all"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = merge(var.tags, {
    "Name" = "${var.prefix}default${var.suffix}"
  })
}

resource aws_default_security_group default {
  vpc_id = aws_vpc.default.id

  ingress {
    protocol    = -1
    cidr_blocks = [var.cidr]
    from_port   = 0
    to_port     = 0
  }

  egress {
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
  }

  tags = merge(var.tags, {
    "Name" = "${var.prefix}default${var.suffix}"
  })
}

resource aws_security_group lb {
  name   = "${var.prefix}lb${var.suffix}"
  vpc_id = aws_vpc.default.id

  dynamic "ingress" {
    for_each = [80, 443]
    content {
      protocol    = "tcp"
      from_port   = ingress.value
      to_port     = ingress.value
      cidr_blocks = var.allow_cidrs_lb
    }
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    "Name" = "${var.prefix}lb${var.suffix}"
  })
}

resource aws_security_group webapp {
  name   = "${var.prefix}webapp${var.suffix}"
  vpc_id = aws_vpc.default.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.lb.id]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    "Name" = "${var.prefix}webapp${var.suffix}"
  })
}

resource aws_security_group ssh {
  name   = "${var.prefix}ssh${var.suffix}"
  vpc_id = aws_vpc.default.id

  ingress {
    protocol    = "tcp"
    cidr_blocks = var.allow_cidrs_ssh
    from_port   = 22
    to_port     = 22
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    "Name" = "${var.prefix}ssh${var.suffix}"
  })
}

resource aws_security_group eks_worker_group_mgmt_one {
  name   = "${var.prefix}eks-wk-grp-mg-one${var.suffix}"
  vpc_id = aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allow_cidrs_ssh
  }
  
  ingress {
    from_port   = 7000
    to_port     = 8000
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
