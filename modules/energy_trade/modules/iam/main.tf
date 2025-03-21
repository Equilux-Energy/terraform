resource "aws_iam_role" "lambda_user_role" {
  name = "lambda_user_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Principal = { Service = "lambda.amazonaws.com" },
      Effect    = "Allow"
    }]
  })
}

resource "aws_iam_policy" "lambda_user_policy" {
  name = "lambda_user_policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect   = "Allow",
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Action   = "dynamodb:*",
        Effect   = "Allow",
        Resource = [
          var.aws_dynamodb_table_trades_arn,
          var.aws_dynamodb_table_ws_connections_arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_user_attach" {
  role       = aws_iam_role.lambda_user_role.name
  policy_arn = aws_iam_policy.lambda_user_policy.arn
}

# --- Admin Lambda (handles /admin/trades endpoints)
resource "aws_iam_role" "lambda_admin_role" {
  name = "lambda_admin_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Principal = { Service = "lambda.amazonaws.com" },
      Effect    = "Allow"
    }]
  })
}

resource "aws_iam_policy" "lambda_admin_policy" {
  name = "lambda_admin_policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect   = "Allow",
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Action   = "dynamodb:*",
        Effect   = "Allow",
        Resource = var.aws_dynamodb_table_trades_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_admin_attach" {
  role       = aws_iam_role.lambda_admin_role.name
  policy_arn = aws_iam_policy.lambda_admin_policy.arn
}

# --- WebSocket Lambda (handles $connect/$disconnect)
resource "aws_iam_role" "lambda_ws_role" {
  name = "lambda_ws_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Principal = { Service = "lambda.amazonaws.com" },
      Effect    = "Allow"
    }]
  })
}

resource "aws_iam_policy" "lambda_ws_policy" {
  name = "lambda_ws_policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect   = "Allow",
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Action   = "dynamodb:*",
        Effect   = "Allow",
        Resource = var.aws_dynamodb_table_ws_connections_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_ws_attach" {
  role       = aws_iam_role.lambda_ws_role.name
  policy_arn = aws_iam_policy.lambda_ws_policy.arn
}

# --- API Gateway Roles to Access lambda function
resource "aws_iam_role" "apigateway_user_role" {
  name = "apigateway_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Principal = { Service = "apigateway.amazonaws.com" },
      Effect    = "Allow"
    }]
  })
}

resource "aws_iam_policy" "apigateway_user_policy" {
  name = "apigateway_user_policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "lambda:InvokeFunction"
        ],
        Effect   = "Allow",
        Resource = [
          var.aws_lambda_function_trade_invoke_arn,
          var.aws_lambda_function_ws_handler_invoke_arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "apigateway_user_attach" {
  role       = aws_iam_role.apigateway_user_role.name
  policy_arn = aws_iam_policy.apigateway_user_policy.arn
}

resource "aws_iam_role" "apigateway_admin_role" {
  name = "apigateway_admin_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Principal = { Service = "apigateway.amazonaws.com" },
      Effect    = "Allow"
    }]
  })
}

resource "aws_iam_policy" "apigateway_admin_policy" {
  name = "apigateway_admin_policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "lambda:InvokeFunction"
        ],
        Effect   = "Allow",
        Resource = [
          var.aws_lambda_function_trade_admin_invoke_arn,
          var.aws_lambda_function_ws_handler_invoke_arn,
          var.aws_lambda_function_trade_invoke_arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "apigateway_admin_attach" {
  role       = aws_iam_role.apigateway_admin_role.name
  policy_arn = aws_iam_policy.apigateway_admin_policy.arn
}