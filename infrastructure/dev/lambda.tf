data "archive_file" "scaling_down" {
  type        = "zip"
  source_file = "${path.module}/codes/dev-scaling-down.py"
  output_path = "${path.module}/codes/dev-scaling-down.zip"
}

module "lambda_scaling_down" {
  source = "../../modules/lambda/uptime-automation"

  cron        = "cron(0 18 ? * MON-FRI *)"   # The cron time in UTC
  description = "Dev environment scaling down to 0 at 18 UTC"

  lambda_code      = "../infrastructure/dev/codes/dev-scaling-down.zip"
  lambda_code_hash = data.archive_file.scaling_down.output_base64sha256
  handler          = "dev-scaling-down.lambda_handler"
  name             = "dev-Cluster-Scaling-Down"
  role_arn         = aws_iam_role.lambda_dev_scaling.arn
  runtime          = "python3.12"
  lambda_variables = {
     CLUSTER_NAME = "dev-cluster"
     RDS_IDS      = ["dev-db1", "dev-db2"]
   }
}