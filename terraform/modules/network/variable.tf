variable prefix {
  description = "The prefix for the resource name. Default value is empty."
  default     = ""
}

variable suffix {
  description = "The suffix for the resource name. Default value is empty."
  default     = ""
}

variable tags {
  type    = map(string)
  default = {}
}

variable cidr {
  description = "The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overridden"
  type        = string
  default     = "0.0.0.0/0"
}

variable subnets {
  description = "The CIDR block by subnet and Availability Zone"
  default     = {}
}

variable allow_cidrs_waf {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable allow_cidrs_lb {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable allow_cidrs_db {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable allow_cidrs_ssh {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable enable_nat_gateway {
  default = false
}

variable private_zone_name {}

locals {
  tags = {
    public = merge(var.tags, {
      Tier = "public"
      Name = "${var.prefix}public${var.suffix}"
    })
    private = merge(var.tags, {
      Tier = "private",
      Name = "${var.prefix}private${var.suffix}"
    })
  }
}

data aws_region current {}
