resource "null_resource" "lambda_cloudformation_hook_dependencies" {
  triggers = {
    dependencies_versions = filemd5("${path.module}/lambda_cloudformation_hook/package.json")
    source_versions       = filemd5("${path.module}/lambda_cloudformation_hook/index.js")
  }
  provisioner "local-exec" {
    command = "cd ${path.module}/lambda_cloudformation_hook && npm install --production"
  }
}

// Archive the Lambda function code
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_cloudformation_hook"
  output_path = "${path.module}/files/lambda_cloudformation_hook.zip"
  depends_on  = [null_resource.lambda_cloudformation_hook_dependencies]
}

// IAM role for the Lambda function
resource "aws_iam_role" "iam_lambda_cloudformation_hook" {
  name = "iam_lambda_cloudformation_hook"
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
  role = aws_iam_role.iam_lambda_cloudformation_hook.id
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
resource "aws_iam_role_policy" "iam_lambda_cloudformation_hook_policy" {
  name = "iam_lambda_cloudformation_hook_policy"
  role = aws_iam_role.iam_lambda_cloudformation_hook.id

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
resource "aws_cloudwatch_log_group" "lambda_cloudformation_hook" {
  name              = "/aws/lambda/cloudformation_hook"
  retention_in_days = 7
}

// CloudWatch Event Rule
resource "aws_cloudwatch_event_rule" "cloudformation_hook_create_complete" {
  name        = "cloudformation_hook_create_complete"
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
resource "aws_cloudwatch_event_target" "cloudformation_hook_event_target" {
  rule      = aws_cloudwatch_event_rule.cloudformation_hook_create_complete.name
  target_id = "ProcessResourceCreation"
  arn       = aws_lambda_function.cloudformation_hook_handler.arn
}

// Lambda permission for EventBridge
resource "aws_lambda_permission" "cloudformation_hook_allow_eventbridge" {
  statement_id  = "AllowEventBridgeInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cloudformation_hook_handler.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.cloudformation_hook_create_complete.arn
}

// Lambda function
resource "aws_lambda_function" "cloudformation_hook_handler" {
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  function_name    = "cloudformation_hook_handler"
  role             = aws_iam_role.iam_lambda_cloudformation_hook.arn
  handler          = "index.handler"
  runtime          = "nodejs18.x"
  timeout          = 60

  environment {
    variables = {
      POLICY_ARN = aws_iam_policy.copilot_policy.arn
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.lambda_cloudformation_hook,
    aws_iam_role_policy.lambda_logging,
    null_resource.lambda_cloudformation_hook_dependencies
  ]
}
