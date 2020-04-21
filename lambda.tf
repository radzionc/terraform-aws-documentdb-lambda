data "archive_file" "local_zipped_lambda" {
  type        = "zip"
  source_dir = "${path.module}/lambda"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_s3_bucket_object" "zipped_lambda" {
  bucket = "${aws_s3_bucket.lambda_storage.bucket}"
  key    = "lambda.zip"
  source = "${data.archive_file.local_zipped_lambda.output_path}"
}

resource "aws_s3_bucket" "lambda_storage" {
  bucket = "tf-${var.name}-storage"
}

resource "aws_lambda_function" "service" {
  function_name = "tf-${var.name}"

  s3_bucket = "${aws_s3_bucket.lambda_storage.bucket}"
  s3_key    = "${aws_s3_bucket_object.zipped_lambda.key}"

  handler     = "src/lambda.handler"
  runtime     = "nodejs8.10"
  role        = "${aws_iam_role.service.arn}"

  vpc_config {
    subnet_ids = ["${module.vpc.private_subnets}"]
    security_group_ids = ["${aws_security_group.service.id}"]
  }

  environment {
    variables = {
      DB_CONNECTION_STRING = "mongodb://${aws_docdb_cluster.service.master_username}:${aws_docdb_cluster.service.master_password}@${aws_docdb_cluster.service.endpoint}:${aws_docdb_cluster.service.port}"
    }
  }
}

resource "aws_iam_role" "service" {
  name = "tf-${var.name}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "service" {
  name = "tf-${var.name}"
  role = "${aws_iam_role.service.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*",
        "ec2:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "service" {
  name = "tf-${var.name}"
  path = "/"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "service" {
  role       = "${aws_iam_role.service.name}"
  policy_arn = "${aws_iam_policy.service.arn}"
}
