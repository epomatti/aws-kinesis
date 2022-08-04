terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.24.0"
    }
  }
  backend "local" {
    path = "./.workspace/terraform.tfstate"
  }
}

provider "aws" {
  region = local.region
}

### Variables ###

variable "account_id" {
  type = number
}

variable "kinesis_key_id" {
  type = string
}

locals {
  region = "sa-east-1"
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
  bucket = "bucket-kinesis-data-stream-817234"
}

resource "aws_s3_bucket_acl" "default" {
  bucket = aws_s3_bucket.bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "app" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
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

### Firehose ###

resource "aws_cloudwatch_log_stream" "firehose" {
  name           = "firehose"
  log_group_name = aws_cloudwatch_log_group.default.name
}

# module "firehose_s3_permissions" {
#   source = "./firehose_s3_policy"

#   region          = local.region
#   account_id      = var.account_id
#   bucket_name     = aws_s3_bucket.bucket.bucket
#   stream_name     = aws_kinesis_stream.default.name
#   kinesis_key_id  = var.kinesis_key_id
#   log_group_name  = aws_cloudwatch_log_group.default.name
#   log_stream_name = aws_cloudwatch_log_stream.firehose.name
# }

resource "aws_kinesis_firehose_delivery_stream" "stream" {
  name        = "kds-s3"
  destination = "extended_s3"

  # kinesis_source_configuration {
  #   kinesis_stream_arn = aws_kinesis_stream.default.arn
  #   role_arn           = aws_iam_role.firehose.arn
  # }

  extended_s3_configuration {
    bucket_arn = aws_s3_bucket.bucket.arn
    role_arn   = aws_iam_role.firehose.arn
  }
}

### Firehose from Kinesis Data Stream source ###
# resource "aws_kinesis_firehose_delivery_stream" "data_stream" {
#   name        = "from_data_stream"
#   destination = "extended_s3"

#   kinesis_source_configuration {
#     kinesis_stream_arn = aws_kinesis_stream.default.arn
#   }

#   extended_s3_configuration {
#     role_arn   = aws_iam_role.default.arn
#     bucket_arn = aws_s3_bucket.bucket.arn
#   }

#   // TODO: Add Role
# }

# resource "aws_kinesis_analytics_application" "test_application" {
#   name = "kinesis-analytics-application-test"

#   inputs {
#     name_prefix = "test_prefix"

#     kinesis_stream {
#       resource_arn = aws_kinesis_stream.default.arn

#       // TODO: Add role
#       # role_arn     = aws_iam_role.test.arn
#     }

#     parallelism {
#       count = 1
#     }
#   }
# }
