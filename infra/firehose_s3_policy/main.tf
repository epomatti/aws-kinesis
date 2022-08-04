variable "region" {
  type = string
}

variable "account_id" {
  type = number
}

variable "bucket_name" {
  type = string
}

variable "stream_name" {
  type = string
}

variable "kinesis_key_id" {
  type = string
}

variable "log_group_name" {
  type = string
}

variable "log_stream_name" {
  type = string
}

resource "aws_iam_policy" "policy" {
  name        = "FirehoseS3"
  description = "Allow various permissions for Kinesis Firehose with S3 destination."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:AbortMultipartUpload",
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
          "s3:PutObject"
        ]
        Resource = [
          "arn:aws:s3:::${var.bucket_name}",
          "arn:aws:s3:::${var.bucket_name}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kinesis:DescribeStream",
          "kinesis:GetShardIterator",
          "kinesis:GetRecords",
          "kinesis:ListShards"
        ]
        Resource = "arn:aws:kinesis:${var.region}:${var.account_id}:stream/${var.stream_name}"
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = [
          "arn:aws:kms:${var.region}:${var.account_id}:key/${var.kinesis_key_id}"
        ]
        Condition = {
          StringEquals = {
            "kms:ViaService" : "s3.${var.region}.amazonaws.com"
          }
          StringLike = {
            "kms:EncryptionContext:aws:s3:arn" : "arn:aws:s3:::${var.bucket_name}/prefix*"
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "logs:PutLogEvents"
        ]
        Resource = [
          "arn:aws:logs::${var.region}:${var.account_id}:log-group:${var.log_group_name}:log-stream:${var.log_stream_name}"
        ]
      },
      # {
      #   Effect = "Allow"
      #   Action = [
      #     "lambda:InvokeFunction",
      #     "lambda:GetFunctionConfiguration"
      #   ],
      #   Resource = [
      #     "arn:aws:lambda:region:account-id:function:function-name:function-version"
      #   ]
      # }
    ]
  })
}


output "arn" {
  value = aws_iam_policy.policy.arn
}
