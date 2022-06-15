terraform {
  source = "github.com/marandalucas/terraform-aws-vpc.git//.?ref=v0.2.0"
}

include {
  path           = find_in_parent_folders()
  expose         = true
  merge_strategy = "deep"
}

locals {
  create  = true
  purpose = "fargate"
  name    = format("%s-%s-%s-%s-vpc-%s", include.locals.area_code, include.locals.account_name, include.locals.environment_short_name, include.locals.region_name, local.purpose)

  cidr            = "10.2.0.0/19" # 8190 reserved Host/Nets. # HostMin 10.2.0.1 to HostMax 10.2.31.254
  azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  public_subnets  = ["10.2.28.0/25", "10.2.29.0/25", "10.2.30.0/25"] # 126 reserved Host/Net by subnets.
  private_subnets = ["10.2.0.0/22", "10.2.4.0/22", "10.2.8.0/22"]    # 1022 reserved Host/Net by subnets. # HostMin 10.2.0.1 to HostMax 10.2.11.254

  ## Single NAT Gateway
  enable_nat_gateway      = true
  single_nat_gateway      = true
  one_nat_gateway_per_az  = false
  map_public_ip_on_launch = false

  ## Internet Gateway
  create_igw = true

  ## Other properties
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = false

  tags = {
    Terraform   = "true"
    Area        = include.locals.area_code
    Account     = include.locals.account_name
    Environment = include.locals.environment_name
    Region      = include.locals.region_name
  }
}

inputs = {

  create = local.create
  name   = local.name

  cidr            = local.cidr
  azs             = local.azs
  public_subnets  = local.public_subnets
  private_subnets = local.private_subnets

  ## Single NAT Gateway
  enable_nat_gateway      = local.enable_nat_gateway
  single_nat_gateway      = local.single_nat_gateway
  one_nat_gateway_per_az  = local.one_nat_gateway_per_az
  map_public_ip_on_launch = local.map_public_ip_on_launch

  ## Internet Gateway
  create_igw = local.create_igw

  ## Other properties
  instance_tenancy     = local.instance_tenancy
  enable_dns_support   = local.enable_dns_support
  enable_dns_hostnames = local.enable_dns_hostnames

  tags = local.tags
}