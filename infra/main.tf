terraform {
  required_version = ">= 1.9"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.74.0"
    }
  }
  backend "s3" {
    bucket = "pgr301-2024-terraform-state"  # S3 bucket for state storage
    key    = "terraform/state"
    region = "eu-west-1"
  }
}

provider "aws" {
  region = "eu-west-1"
}

# SQS Queue for Image Processing
resource "aws_sqs_queue" "image_processing_queue" {
  name = "image-processing-queue-k79"
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_sqs_role" {
  name = "lambda_sqs_role_k79"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = { Service = "lambda.amazonaws.com" },
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

# IAM Policy for SQS, S3, and Bedrock access
resource "aws_iam_policy" "lambda_sqs_policy" {
  name        = "lambda_sqs_policy_k79"
  description = "Permissions for Lambda to read from SQS, write to S3, and invoke Bedrock models"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"],
        Resource = aws_sqs_queue.image_processing_queue.arn
      },
      {
        Effect   = "Allow",
        Action   = ["s3:PutObject"],
        Resource = "arn:aws:s3:::pgr301-couch-explorers/*"
      },
      {
        Effect   = "Allow",
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"],
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect   = "Allow",
        Action   = ["bedrock:InvokeModel"],
        Resource = "arn:aws:bedrock:us-east-1::foundation-model/amazon.titan-image-generator-v1"
      }
    ]
  })
}

# Attach IAM Policy to the Role Managed by Terraform
resource "aws_iam_role_policy_attachment" "lambda_sqs_role_attach" {
  role       = aws_iam_role.lambda_sqs_role.name
  policy_arn = aws_iam_policy.lambda_sqs_policy.arn
}

# Lambda Function for Processing Messages from SQS
resource "aws_lambda_function" "image_processor_lambda" {
  function_name    = "image_processor_lambda_k79" # Updated with your ID
  role             = aws_iam_role.lambda_sqs_role.arn # Use Terraform-managed role
  handler          = "lambda_sqs.lambda_handler"  # Entry point for lambda_sqs.py
  runtime          = "python3.8"
  timeout          = 15
  filename         = "lambda_sqs.zip" # Specify the local ZIP file
  source_code_hash = filebase64sha256("lambda_sqs.zip")  # Replace with the actual path to lambda_sqs.zip

  environment {
    variables = {
      BUCKET_NAME = "pgr301-couch-explorers"  # Environment variable as expected in lambda_sqs.py
    }
  }
}

# Event Source Mapping to Trigger Lambda from SQS
resource "aws_lambda_event_source_mapping" "sqs_to_lambda" {
  event_source_arn = aws_sqs_queue.image_processing_queue.arn
  function_name    = aws_lambda_function.image_processor_lambda.arn
  batch_size       = 10
}

# Handing in task 2b.
# Adding another comment to test something