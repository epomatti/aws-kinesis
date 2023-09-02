terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
  backend "local" {
    path = "./.workspace/terraform.tfstate"
  }
}


provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

locals {
  aws_account_id = data.aws_caller_identity.current.account_id
}

### Cloud Watch ###
resource "aws_cloudwatch_log_group" "default" {
  name = "kinesis"
}

### Kinesis Data Stream ###
resource "aws_kinesis_stream" "default" {
  name        = "device-stream"
  shard_count = 1

  # Retention (in hours)
  retention_period = 24

  # Encryption
  encryption_type = "KMS"
  kms_key_id      = "alias/aws/kinesis"

  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]

  stream_mode_details {
    stream_mode = "PROVISIONED"
  }
}

### S3 ###
resource "aws_s3_bucket" "bucket" {
  bucket        = "bucket-kinesis-data-stream-817234"
  force_destroy = true
}

### Firehose ###
resource "aws_cloudwatch_log_stream" "firehose" {
  name           = "firehose"
  log_group_name = aws_cloudwatch_log_group.default.name
}

resource "aws_iam_role" "firehose" {
  name = "assume-role-firehose"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowFirehose"
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "firehose.amazonaws.com"
        }
      }
    ]
  })
}

module "lambda" {
  source = "./lambda"
}

module "firehose_s3_policy" {
  source = "./firehose_s3_policy"

  aws_region      = var.aws_region
  aws_account_id  = local.aws_account_id
  bucket_name     = aws_s3_bucket.bucket.bucket
  stream_name     = aws_kinesis_stream.default.name
  log_group_name  = aws_cloudwatch_log_group.default.name
  log_stream_name = aws_cloudwatch_log_stream.firehose.name
  function_name   = module.lambda.function_name
}

resource "aws_iam_role_policy_attachment" "firehose_s3_attach" {
  role       = aws_iam_role.firehose.name
  policy_arn = module.firehose_s3_policy.arn
}

resource "aws_cloudwatch_log_stream" "firehose_s3" {
  name           = "firehose_s3"
  log_group_name = aws_cloudwatch_log_group.default.name
}

resource "aws_kinesis_firehose_delivery_stream" "stream" {
  name        = "kds-s3"
  destination = "extended_s3"

  kinesis_source_configuration {
    kinesis_stream_arn = aws_kinesis_stream.default.arn
    role_arn           = aws_iam_role.firehose.arn
  }

  extended_s3_configuration {
    bucket_arn = aws_s3_bucket.bucket.arn
    role_arn   = aws_iam_role.firehose.arn

    processing_configuration {
      enabled = "true"

      processors {
        type = "Lambda"

        parameters {
          parameter_name  = "LambdaArn"
          parameter_value = "${module.lambda.arn}:$LATEST"
        }
      }
    }

    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = aws_cloudwatch_log_group.default.name
      log_stream_name = aws_cloudwatch_log_stream.firehose_s3.name
    }
  }
}

### New Code ###

module "firehose_direct_put" {
  source = "./firehose-put"
}

