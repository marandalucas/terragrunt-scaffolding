locals {
  account_name                 = "ms-non-live"
  account_id                   = "841022695938" # AWS account ID
  infrastructure_provider_role = "InfraProviderRole"
  provider_assume_role_arn     = "arn:aws:iam::${local.account_id}:role/${local.infrastructure_provider_role}"
  aws_profile                  = "ms-non-live"
}