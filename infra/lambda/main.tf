resource "aws_iam_role" "iam_for_lambda" {
  name = "Kinesis-S3-Lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Effect = "Allow"
        Sid    = ""
      }
    ]
  })
}

resource "aws_lambda_function" "json_transform" {
  # If the file is not in the current working directory you will need to include a 
  # path.module in the filename.
  # filename      = "lambda_function_payload.zip"
  function_name = "kinesis-s3-json-transform"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "index.lambdaHandler"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"

  # source_code_hash = filebase64sha256("lambda_function_payload.zip")

  runtime = "nodejs16.x"

}

output "function_name" {
  value = aws_lambda_function.json_transform.function_name
}
