# ============================================
# Provider Configuration
# ============================================

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      Project     = "lambda-layer-example"
      ManagedBy   = "terraform"
    }
  }
}

# ============================================
# Lambda Layer
# ============================================

module "python_dependencies_layer" {
  source = "../../lambda_layer"

  layer_name          = "${var.environment}-python-dependencies"
  description         = "Python dependencies layer with requests, boto3, and other common libraries"
  filename            = "${path.module}/layer/python-layer.zip"
  source_code_hash    = filebase64sha256("${path.module}/layer/python-layer.zip")
  compatible_runtimes = ["python3.11", "python3.12"]
  license_info        = "MIT"
}

# ============================================
# Lambda Function
# ============================================

module "data_processor_function" {
  source = "../../lambda_function"

  function_name = "${var.environment}-data-processor"
  description   = "Processes data using dependencies from Lambda layer"
  
  # Code configuration
  handler          = "app.handler"
  runtime          = "python3.11"
  filename         = "${path.module}/function/function.zip"
  source_code_hash = filebase64sha256("${path.module}/function/function.zip")
  
  # Attach the layer
  layers = [
    module.python_dependencies_layer.layer_arn
  ]
  
  # Performance configuration
  timeout     = 30
  memory_size = 512
  
  # Environment variables
  environment_variables = {
    ENVIRONMENT   = var.environment
    LAYER_VERSION = module.python_dependencies_layer.layer_version
    LOG_LEVEL     = "INFO"
  }
  
  # Logging configuration
  log_retention_days = var.log_retention_days
  
  # Enable X-Ray tracing
  tracing_mode = "Active"
  
  # Attach X-Ray permissions
  attach_policy_arns = [
    "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
  ]
  
  tags = {
    Function = "DataProcessor"
  }
}

# ============================================
# Optional: Lambda Function URL
# ============================================

module "api_function" {
  source = "../../lambda_function"

  function_name = "${var.environment}-api-handler"
  description   = "API handler with Function URL enabled"
  
  handler  = "api.handler"
  runtime  = "python3.11"
  filename = "${path.module}/function/function.zip"
  
  # Attach the same layer
  layers = [
    module.python_dependencies_layer.layer_arn
  ]
  
  # Enable Function URL for HTTP access
  create_function_url    = true
  function_url_auth_type = "NONE"  # Public access (use AWS_IAM for production)
  
  # CORS configuration
  function_url_cors_config = {
    allow_origins = ["*"]
    allow_methods = ["GET", "POST"]
    allow_headers = ["Content-Type"]
    max_age       = 300
  }
  
  timeout     = 30
  memory_size = 256
  
  environment_variables = {
    ENVIRONMENT = var.environment
  }
}
