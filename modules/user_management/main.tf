
module "cognito" {
  source = "./modules/cognito"
  admin_role_arn                     = module.iam.admin_role_arn
  user_role_arn                      = module.iam.user_role_arn
  user_pool_name                     = "user-management-pool"
  user_pool_client_name              = "user-management-client"
  password_minimum_length            = 8
  require_lowercase                  = true
  require_numbers                    = true
  require_symbols                    = true
  require_uppercase                  = true
  auto_verified_attributes           = ["email"]
  explicit_auth_flows                = ["ALLOW_USER_SRP_AUTH", "ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_USER_PASSWORD_AUTH", "ALLOW_ADMIN_USER_PASSWORD_AUTH", "ALLOW_CUSTOM_AUTH"]
  allowed_oauth_flows                = ["code"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes               = ["phone", "email", "openid", "profile", "aws.cognito.signin.user.admin"]
  callback_urls                      = var.callback_urls
  post_confirmation_arn       = module.lambda.post_confirmation_arn
  google_client_id              = var.google_client_id
  google_client_secret          = var.google_client_secret
  tags = var.tags
}

module "dynamodb" {
  source = "./modules/dynamodb"
  users_table_name       = "Equilux_Users_Prosumers"
  billing_mode     = "PAY_PER_REQUEST"
  hash_key         = "user_id"
  hash_key_type    = "S"
  server_side_encryption_enabled = true
  tags = var.tags
}

module "iam" {
  source = "./modules/iam"

  region                             = "eu-west-1"
  aws_api_gateway_rest_api_id        = module.apigateway.aws_api_gateway_rest_api_id
  user_dynamodb_table_name           = module.dynamodb.user_table_name
  user_pool_arn                      = module.cognito.user_pool_arn
  user_pool_id                       = module.cognito.user_pool_id
  post_confirmation_arn              = module.lambda.post_confirmation_arn
  delete_user_arn                    = module.lambda.delete_user_arn
  create_user_arn                    = module.lambda.create_user_arn
  get_user_arn                       = module.lambda.get_user_arn
  update_user_arn                    = module.lambda.update_user_arn
  list_all_users_arn                 = module.lambda.list_all_users_arn
  assign_admin_role_arn              = module.lambda.assign_admin_role_arn
  revoke_admin_role_arn              = module.lambda.revoke_admin_role_arn
  admin_get_user_arn                 = module.lambda.admin_get_user_arn
  admin_update_user_arn              = module.lambda.admin_update_user_arn
  admin_delete_user_arn              = module.lambda.admin_delete_user_arn
  tags = var.tags
}

module "lambda" {
  source = "./modules/lambda"

  function_prefix                             = "user-management"
  handler                                     = "index.handler"
  runtime                                     = "nodejs18.x"
  user_management_role_arn                                    = module.iam.lambda_execution_role_arn
  create_user_filename                        = "${path.module}/lambda_functions/user/create_user.zip"
  get_user_filename                           = "${path.module}/lambda_functions/user/get_user.zip"
  update_user_filename                        = "${path.module}/lambda_functions/user/update_user.zip"
  delete_user_filename                        = "${path.module}/lambda_functions/user/delete_user.zip"
  post_confirmation_filename                  = "${path.module}/lambda_functions/user/post_confirmation.zip"
  list_all_users_filename                     = "${path.module}/lambda_functions/admin/admin_list_all_users.zip"
  assign_admin_role_filename                  = "${path.module}/lambda_functions/admin/admin_assign_admin_role.zip"
  revoke_admin_role_filename                  = "${path.module}/lambda_functions/admin/admin_revoke_admin_role.zip"
  admin_get_user_filename                     = "${path.module}/lambda_functions/admin/admin_get_user.zip"
  admin_update_user_filename                  = "${path.module}/lambda_functions/admin/admin_update_user.zip"
  admin_delete_user_filename                  = "${path.module}/lambda_functions/admin/admin_delete_user.zip"
  user_pool_id                                = module.cognito.user_pool_id
  environment_variables   = {
    TABLE_NAME = module.dynamodb.user_table_name
    USER_POOL_ID = module.cognito.user_pool_id
  }
  tags = var.tags
}

module "apigateway" {
  source = "./modules/apigateway"
  api_gateway_admin_role_arn = module.iam.api_gateway_admin_role_arn
  api_gateway_user_role_arn = module.iam.api_gateway_user_role_arn
  user_management_lambda_functions = {
    create_user         = module.lambda.create_user_arn
    get_user            = module.lambda.get_user_arn
    update_user         = module.lambda.update_user_arn
    delete_user         = module.lambda.delete_user_arn
    list_all_users      = module.lambda.list_all_users_arn
    grant_admin         = module.lambda.assign_admin_role_arn
    revoke_admin        = module.lambda.revoke_admin_role_arn
    admin_get_user      = module.lambda.admin_get_user_arn
    admin_update_user   = module.lambda.admin_update_user_arn
    admin_delete_user   = module.lambda.admin_delete_user_arn
  }
  region = "eu-west-1"
  cognito_user_pool_arn = module.cognito.user_pool_arn
}


# module "waf" {
#   source      = "./modules/waf"
#   name        = "UserManagementAPI-WAF"
#   metric_name = "UserManagementAPIWAF"
#   aws_api_gateway_deployment_arn = module.apigateway.aws_api_gateway_deployment_arn
# }
