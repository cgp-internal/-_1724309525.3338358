resource "aws_lambda_function" "this" {
  filename      = "lambda_function_payload.zip"
  function_name = "AuthorizerLambdaFunction"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  role          = aws_iam_role.this.arn
  environment {
    variables = {}
  }
}

output "LambdaFunction" {
  value = aws_lambda_function.this
}

resource "aws_lambda_permission" "this" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.arn
  principal     = "apigateway.amazonaws.com"
}

resource "aws_iam_role" "this" {
  name = "AuthorizerLambdaRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Effect = "Allow"
      }
    ]
  })
}

output "LambdaRole" {
  value = aws_iam_role.this
}

resource "aws_iam_policy" "this" {
  name        = "AuthorizerLambdaPolicy"
  description = "Policy for Authorizer Lambda function"

  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "kafka:Send"
        Resource = "*"
        Effect = "Allow"
      },
      {
        Action = "logs:CreateLogGroup"
        Resource = "arn:aws:logs:*:*:*"
        Effect = "Allow"
      },
      {
        Action = "logs:CreateLogStream"
        Resource = "arn:aws:logs:*:*:*"
        Effect = "Allow"
      },
      {
        Action = "logs:PutLogEvents"
        Resource = "arn:aws:logs:*:*:*"
        Effect = "Allow"
      }
    ]
  })
}

output "LambdaPolicy" {
  value = aws_iam_policy.this
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}

data "archive_file" "lambda_function_payload" {
  type        = "zip"
  source_file = "lambda_function.py"
  output_path = "lambda_function_payload.zip"
}