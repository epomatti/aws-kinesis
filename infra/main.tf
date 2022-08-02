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
  region = "sa-east-1"
}

### Kinesis Data Stream ###

resource "aws_kinesis_stream" "default" {
  name        = "device-datastream"
  shard_count = 1

  # Retention hours
  // Minimum: 24
  // Extended: 7 days
  // Long-term: 356 days
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

# resource "aws_iam_role" "default" {
#   name = "test-firehose"

#   assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Action": "sts:AssumeRole",
#       "Principal": {
#         "Service": "firehose.amazonaws.com"
#       },
#       "Effect": "Allow",
#       "Sid": ""
#     }
#   ]
# }
# EOF
# }

# resource "aws_s3_bucket" "bucket" {
#   bucket = "bucket-kinesis-data-stream-999"
# }

# resource "aws_s3_bucket_acl" "default" {
#   bucket = aws_s3_bucket.bucket.id
#   acl    = "private"
# }


### Firehose from put source ###
# resource "aws_kinesis_firehose_delivery_stream" "put_stream" {
#   name        = "terraform-kinesis-firehose-extended-s3-test-stream"
#   destination = "extended_s3"

#   extended_s3_configuration {
#     role_arn   = aws_iam_role.default.arn
#     bucket_arn = aws_s3_bucket.bucket.arn
#   }
# }

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
