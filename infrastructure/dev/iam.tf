data "aws_iam_policy_document" "lambda" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}
############## IAM ROLES ##############
#######################################
resource "aws_iam_role" "lambda_dev_scaling" {
  name               = "Lambda-dev-Scaling"
  assume_role_policy = data.aws_iam_policy_document.lambda.json
}
############## IAM POLICIES ##############
##########################################
resource "aws_iam_policy" "lambda_dev_scaling" {
  name        = "Lambda-dev-Scaling"
  description = "Policy to allwo Lambda to scale Dev infrastructure"
  policy      = <<EOF
{
    "Statement": [
        {
            "Sid": "Logs",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:CreateLogGroup",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        },
        {
          "Sid": "ECSSpecific",
          "Effect": "Allow",
          "Action": [
            "ecs:UpdateService",
            "ecs:ListTagsForResource",
            "ecs:ListAttributes",
            "ecs:DescribeServices",
            "ecs:ListContainerInstances",
            "ecs:DescribeClusters"
          ],
          "Resource": [
            "arn:aws:ecs:*:*:service/dev-cluster/*",
            "arn:aws:ecs:*:*:cluster/dev-cluster"
            
          ]
        },
        {
          "Sid": "RDSStopStart",
          "Effect": "Allow",
          "Action": [
            "rds:StopDBInstance",
            "rds:StartDBInstance"            
          ],
          "Resource": "*"
        },         
        {
          "Sid": "EC2StopStart",
          "Effect": "Allow",
          "Action": [
            "ec2:StopInstances",
            "ec2:StartInstances"            
          ],
          "Resource": "*"
        },         
        {
          "Sid": "ECSGeneric",
          "Effect": "Allow",
          "Action": [
            "ecs:List*",
            "ecs:Describe*",
            "application-autoscaling:TagResource",
            "application-autoscaling:RegisterScalableTarget",
            "application-autoscaling:UntagResource",                        
          ],
          "Resource": "*"
        }              
    ],
    "Version": "2012-10-17"
}
EOF

}

############## IAM POLICIES ATTACHMENTS ##############
######################################################
resource "aws_iam_role_policy_attachment" "lambda_scaling" {
  role       = aws_iam_role.lambda_dev_scaling.name
  policy_arn = aws_iam_policy.lambda_dev_scaling.arn
}