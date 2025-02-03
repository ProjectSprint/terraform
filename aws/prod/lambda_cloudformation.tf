// main.tf
resource "null_resource" "lambda_dependencies" {
  triggers = {
    dependencies_versions = filemd5("${path.module}/lambda_cloudformation/package.json")
    source_versions       = filemd5("${path.module}/lambda_cloudformation/index.js") # Added source file tracking
  }
  provisioner "local-exec" {
    command = "cd ${path.module}/lambda_cloudformation && npm install --production" # Added --production flag
  }
}

// Archive the Lambda function code
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/files/iam_attach_hook.zip" # Changed path to avoid recursion
  depends_on  = [null_resource.lambda_dependencies]        # Added dependency
}

// IAM role for the Lambda function
resource "aws_iam_role" "iam_monitor_lambda_role" {
  name = "iam_monitor_lambda_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

// CloudWatch Logs policy for Lambda
resource "aws_iam_role_policy" "lambda_logging" {
  name = "lambda_logging"
  role = aws_iam_role.iam_monitor_lambda_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*" # Simplified resource format
      }
    ]
  })
}
// IAM policy for the Cloudformation function
resource "aws_iam_role_policy" "iam_monitor_lambda_policy" {
  name = "iam_monitor_lambda_policy"
  role = aws_iam_role.iam_monitor_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "iam:AttachRolePolicy",
          "iam:GetRole"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "cloudformation:DescribeStacks",
          "cloudformation:DescribeStackEvents",
          "cloudformation:DescribeStackResources",
          "cloudformation:ListStackResources",
          "cloudformation:GetTemplate"
        ]
        Resource = "*"
    }]
  })
}

// CloudWatch Log Group for Lambda
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/iam_monitor"
  retention_in_days = 7
}

// CloudWatch Event Rule
resource "aws_cloudwatch_event_rule" "cloudformation_create_complete" {
  name        = "capture-iam-events"
  description = "Capture Create Complete Cloudformation events"
  event_pattern = jsonencode({
    source = ["aws.cloudformation"]
    detail = {
      status-details = {
        status = ["CREATE_COMPLETE"]
      }
    }
  })
}

// CloudWatch Event Target
resource "aws_cloudwatch_event_target" "cloudformation_create_complete_event_target" {
  rule      = aws_cloudwatch_event_rule.cloudformation_create_complete.name
  target_id = "ProcessResourceCreation"
  arn       = aws_lambda_function.cloudformation_create_complete_handler.arn
}

// Lambda permission for EventBridge
resource "aws_lambda_permission" "cloudformation_create_complete_allow_eventbridge" {
  statement_id  = "AllowEventBridgeInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cloudformation_create_complete_handler.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.cloudformation_create_complete.arn
}

// Lambda function
resource "aws_lambda_function" "cloudformation_create_complete_handler" {
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  function_name    = "cloudformation_create_complete_handler"
  role             = aws_iam_role.iam_monitor_lambda_role.arn
  handler          = "index.handler"
  runtime          = "nodejs18.x"
  timeout          = 60

  environment {
    variables = {
      POLICY_ARN = aws_iam_policy.copilot_policy.arn
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.lambda_logs,
    aws_iam_role_policy.lambda_logging,
    null_resource.lambda_dependencies
  ]
}
