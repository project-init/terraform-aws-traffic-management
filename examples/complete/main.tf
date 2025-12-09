module "account_context" {
  source = "project-init/account-context/aws"
  # Project Init recommends pinning every module to a specific version
  # version = "vX.X.X"

  # Wherever you create your vpc/ecs cluster/traffic management/etc... you can populate the values for the variables to
  # make them accessible to other services. Anything not given a value will not be populated.
  vpc_id            = "vpc-id"
  public_subnet_ids = ["subnet-1", "subnet-2"]
}
