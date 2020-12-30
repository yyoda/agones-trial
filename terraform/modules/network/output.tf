output vpc {
  value = aws_vpc.default
}

output subnets {
  value = {
    public  = aws_subnet.public
    private = aws_subnet.private
  }
}

output security_groups {
  value = {
    lb     = aws_security_group.lb
    webapp = aws_security_group.webapp
    ssh    = aws_security_group.ssh
    
    eks = {
      worker_group_mgmt_one = aws_security_group.eks_worker_group_mgmt_one
    }
  }
}

output dns {
  value = {
    local = aws_route53_zone.local
  }
}
