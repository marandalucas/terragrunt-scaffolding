remote_state {
  backend = "s3"
  config = {
    encrypt        = true
    bucket         = "master-645263094817-state"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "master-645263094817-locks"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}
