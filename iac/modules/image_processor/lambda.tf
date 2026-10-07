data "archive_file" "upload_lambda" {
  type        = "zip"
  source_dir  = "${path.module}/../../../src/upload-lambda"
  output_path = "${path.module}/upload-lambda.zip"
}

resource "aws_lambda_function" "upload" {
  filename         = data.archive_file.upload_lambda.output_path
  function_name    = "upload-lambda-${var.environment}"
  role             = aws_iam_role.upload_lambda.arn
  handler          = "index.handler"
  source_code_hash = data.archive_file.upload_lambda.output_base64sha256
  runtime          = "nodejs20.x"
  memory_size      = 256
  timeout          = 30

  vpc_config {
    subnet_ids         = aws_subnet.private[*].id
    security_group_ids = [aws_security_group.lambda_upload.id]
  }

  environment {
    variables = {
      S3_BUCKET     = aws_s3_bucket.main.id
      UPLOAD_PREFIX = "uploads/"
    }
  }

  tags = {
    Environment = var.environment
  }
}

data "archive_file" "crop_lambda" {
  type        = "zip"
  source_dir  = "${path.module}/../../../src/crop-lambda"
  output_path = "${path.module}/crop-lambda.zip"
}

resource "aws_lambda_function" "crop" {
  filename         = data.archive_file.crop_lambda.output_path
  function_name    = "crop-lambda-${var.environment}"
  role             = aws_iam_role.crop_lambda.arn
  handler          = "index.handler"
  source_code_hash = data.archive_file.crop_lambda.output_base64sha256
  runtime          = "nodejs20.x"
  memory_size      = 512
  timeout          = 60

  vpc_config {
    subnet_ids         = aws_subnet.private[*].id
    security_group_ids = [aws_security_group.lambda_crop.id]
  }

  environment {
    variables = {
      S3_BUCKET        = aws_s3_bucket.main.id
      PROCESSED_PREFIX = "processed/"
    }
  }

  tags = {
    Environment = var.environment
  }
}

resource "aws_lambda_event_source_mapping" "sqs_crop" {
  event_source_arn = aws_sqs_queue.main.arn
  function_name    = aws_lambda_function.crop.arn
  batch_size       = 5
}

# SGs for Lambdas
resource "aws_security_group" "lambda_upload" {
  name        = "upload-lambda-sg-${var.environment}"
  description = "Security group for upload lambda"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "upload-lambda-sg-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_security_group" "lambda_crop" {
  name        = "crop-lambda-sg-${var.environment}"
  description = "Security group for crop lambda"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "crop-lambda-sg-${var.environment}"
    Environment = var.environment
  }
}
