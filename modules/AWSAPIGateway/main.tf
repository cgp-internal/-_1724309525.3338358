provider "aws" {
  region = var.region
}

variable "region" {
  type        = string
  default     = "us-west-2"
  description = "AWS region"
}

variable "lambda_function" {
  type = object({
    arn = string
  })
  description = "Lambda function object"
}

variable "kafka_cluster" {
  type = object({
    namespace = string
  })
  description = "Kafka cluster object"
}

resource "aws_api_gateway_rest_api" "this" {
  name        = "AuthorizerAPIGateway"
  description = "API Gateway for Authorizer"
}

resource "aws_api_gateway_authorizer" "this" {
  name        = "Authorizer"
  rest_api_id = aws_api_gateway_rest_api.this.id
  authorizer_uri = var.lambda_function.arn
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = "ANY"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.this.id
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.proxy.http_method
  integration_http_method = "POST"
  type        = "LAMBDA"
  uri         = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${var.lambda_function.arn}/invocations"
}

resource "aws_api_gateway_deployment" "this" {
  depends_on = [aws_api_gateway_integration.lambda]
  rest_api_id = aws_api_gateway_rest_api.this.id
  stage_name  = "prod"
}

output "AWSAPIGateway" {
  value = {
    id = aws_api_gateway_deployment.this.id
    execute_arn = aws_api_gateway_deployment.this.execute_arn
  }
}

output "APIGatewayID" {
  value = aws_api_gateway_rest_api.this.id
}

output "APIGatewayARN" {
  value = aws_api_gateway_rest_api.this.arn
}

output "APIGatewayExecutionARN" {
  value = aws_api_gateway_deployment.this.execute_arn
}