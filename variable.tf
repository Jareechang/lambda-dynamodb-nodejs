variable "aws_region" {
    default = "us-east-1"
}

variable "lambda_func_name" {
    default = "dynamo_db_lambda_test"
}

variable "dynamodb_billing_mode" {
    default = "PROVISIONED"
}

variable "dynamodb_write_cap" {
    default = 5
}

variable "dynamodb_read_cap" {
    default = 5
}

variable "dynamodb_common_gsi_read_cap" {
    default = 5
}

variable "dynamodb_common_gsi_write_cap" {
    default = 5
}

variable "dynamodb_common_gsi_projection_type" {
    default = "ALL"
}
