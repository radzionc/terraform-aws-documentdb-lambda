resource "aws_api_gateway_rest_api" "service" {
  name        = "tf-${var.name}"
}

resource "aws_api_gateway_method" "service_root" {
  rest_api_id   = "${aws_api_gateway_rest_api.service.id}"
  resource_id   = "${aws_api_gateway_rest_api.service.root_resource_id}"
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "service_root" {
  rest_api_id   = "${aws_api_gateway_rest_api.service.id}"
  resource_id   = "${aws_api_gateway_rest_api.service.root_resource_id}"
  http_method = "${aws_api_gateway_method.service_root.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.service.invoke_arn}"
}

resource "aws_api_gateway_resource" "service" {
  rest_api_id = "${aws_api_gateway_rest_api.service.id}"
  parent_id   = "${aws_api_gateway_rest_api.service.root_resource_id}"
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "service" {
  rest_api_id   = "${aws_api_gateway_rest_api.service.id}"
  resource_id   = "${aws_api_gateway_resource.service.id}"
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "service" {
  rest_api_id = "${aws_api_gateway_rest_api.service.id}"
  resource_id = "${aws_api_gateway_method.service.resource_id}"
  http_method = "${aws_api_gateway_method.service.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.service.invoke_arn}"
}

data "aws_caller_identity" "current" {}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.service.arn}"
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.service.id}/*/*"
}

module "cors" {
  source = "github.com/carrot/terraform-api-gateway-cors-module"
  resource_id = "${aws_api_gateway_resource.service.id}"
  rest_api_id = "${aws_api_gateway_rest_api.service.id}"
}

resource "aws_api_gateway_deployment" "service" {
  depends_on = ["module.cors", "aws_api_gateway_integration.service"]
  rest_api_id = "${aws_api_gateway_rest_api.service.id}"
  stage_name  = "${var.name}"
}
