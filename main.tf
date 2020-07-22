provider "aws" {
  version = "~> 2.0"
  region  = "${var.aws_region}"
}

resource "aws_s3_bucket" "lambda_bucket" {
    bucket  = "lambda-test2222"
    acl     = "private"
    region  = "${var.aws_region}"

    tags = {
        Name        = "Dev Bucket"
        Environment = "Dev"
    }
}

locals {
    package_json = jsondecode(file("./package.json"))
    build_folder = "dist"
}

resource "aws_s3_bucket_object" "lambda_dynamodb_test" {
    bucket = "${aws_s3_bucket.lambda_bucket.id}"
    key = "main-${local.package_json.version}"
    source = "${local.build_folder}/main-${local.package_json.version}.zip"
    etag = "${filemd5("./${local.build_folder}/main-${local.package_json.version}.zip")}"
}

resource "aws_dynamodb_table" "book_table" {
    name = "Book"
    billing_mode = var.dynamodb_billing_mode
    read_capacity = var.dynamodb_read_cap
    write_capacity = var.dynamodb_write_cap

    hash_key = "Id"

    attribute {
        name = "Id"
        type = "S"
    }

    attribute {
        name = "Genre"
        type = "S"
    }

    global_secondary_index {
        name = "BookGenreIndex"
        hash_key = "Genre"
        read_capacity = var.dynamodb_common_gsi_read_cap
        write_capacity = var.dynamodb_common_gsi_write_cap
        projection_type = var.dynamodb_common_gsi_projection_type
    }

    tags = {
        Name = "dynamo-table-book"
        Environment = "dev"
    }
}


resource "aws_iam_role" "iam_for_lambda" {
    name = "iam_for_lambda"
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

resource "aws_lambda_function" "test_lambda" {
    function_name = var.lambda_func_name
    s3_bucket = "${aws_s3_bucket.lambda_bucket.id}"
    s3_key = "${aws_s3_bucket_object.lambda_dynamodb_test.id}"
    handler = "src/index.handler"
    role = "${aws_iam_role.iam_for_lambda.arn}"
    timeout = 300

    source_code_hash = "${filebase64sha256("dist/${aws_s3_bucket_object.lambda_dynamodb_test.id}.zip")}"

    runtime = "nodejs12.x"
    depends_on = [
        "aws_iam_role_policy_attachment.lambda_logs",
        "aws_cloudwatch_log_group.sample_log_group"
    ]
}

resource "aws_cloudwatch_log_group" "sample_log_group" {
    name = "/aws/lambda/${var.lambda_func_name}"
    retention_in_days = 1
}

data "aws_iam_policy_document" "lambda_cw_log_policy" {
    version = "2012-10-17"
    statement {
        actions = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
        ]
        effect = "Allow"
        resources = ["arn:aws:logs:*:*:*"]
    }
}

resource "aws_iam_policy" "lambda_logging" {
    name = "lambda_logging"
    path = "/"
    description = "IAM Policy for logging from a lambda"

    policy = data.aws_iam_policy_document.lambda_cw_log_policy.json
}

data "aws_iam_policy_document" "lambda_data_dynamodb_policy" {
    version = "2012-10-17"
    statement {
        sid = "LambdaAccessDynamoDBCustom" 
        effect = "Allow"

        actions = [
            "dynamodb:GetItem",
            "dynamodb:PutItem",
            "dynamodb:UpdateItem",
            "dynamodb:DeleteItem",
            "dynamodb:Query",
            "dynamodb:Scan",
            "dynamodb:ListTables",
            "dynamodb:DescribeTable"
        ]

        resources = ["${aws_dynamodb_table.book_table.arn}"]
    }
}

resource "aws_iam_policy" "lambda_data_dynamodb" {
    name = "lambda_data_dynamodb"
    path = "/"
    description = "Custom IAM Policy for Acessing Dyanmodb from a lambda"
    policy = data.aws_iam_policy_document.lambda_data_dynamodb_policy.json
}

resource "aws_iam_role_policy_attachment" "lambda_data_ddb" {
    role = "${aws_iam_role.iam_for_lambda.name}"
    policy_arn = "${aws_iam_policy.lambda_data_dynamodb.arn}"
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
    role = "${aws_iam_role.iam_for_lambda.name}"
    policy_arn = "${aws_iam_policy.lambda_logging.arn}"
}
