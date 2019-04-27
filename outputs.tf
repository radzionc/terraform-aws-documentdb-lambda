output "aws_instance_public_dns" {
  value = "${aws_instance.service.public_dns}"
}

output "url" {
  value = "${var.main_domain != "" ? "https://${var.name}.${var.main_domain}" : "${aws_api_gateway_deployment.service.invoke_url}"}"
}

output "docdb_endpoint" {
  value = "${aws_docdb_cluster.service.endpoint}"
}

output "bucket" {
  value = "${aws_s3_bucket.lambda_storage.bucket}"
}

output "bucket_key" {
  value = "${aws_s3_bucket_object.zipped_lambda.key}"
}

output "name" {
  value = "${var.name}"
}