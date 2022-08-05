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

resource "aws_iam_role_policy_attachment" "lambda_basic_exec" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "json_transform" {
  filename      = "${path.module}/csv2json.zip"
  function_name = "kinesis-s3-json-transform"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "index.lambdaHandler"
  runtime       = "nodejs16.x"
}

output "function_name" {
  value = aws_lambda_function.json_transform.function_name
}

output "arn" {
  value = aws_lambda_function.json_transform.arn
}
