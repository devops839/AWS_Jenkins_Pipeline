#!/usr/bin/env bash
# Define the Trust policy for CodeBuild
TRUST='{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "Service": "codebuild.amazonaws.com" },
      "Action": "sts:AssumeRole"
    }
  ]
}'
# Create the IAM role with assume role policy
echo "Creating IAM role CodeBuildKubectlRole..."
ROLE_ARN=$(aws iam create-role --role-name CodeBuildKubectlRole \
  --assume-role-policy-document "$TRUST" \
  --output text --query 'Role.Arn')

echo "Created IAM role with ARN: $ROLE_ARN"

# Create policy for eks:Describe*
echo "Creating policy for eks:Describe* permissions..."
echo '{ "Version": "2012-10-17", "Statement": [ { "Effect": "Allow", "Action": "eks:Describe*", "Resource": "*" } ] }' > /tmp/iam-role-policy

# Attach policy for eks:Describe*
aws iam put-role-policy --role-name CodeBuildKubectlRole \
  --policy-name eks-describe \
  --policy-document file:///tmp/iam-role-policy
# Attach necessary AWS managed policies
echo "Attaching AWS managed policies..."
aws iam attach-role-policy --role-name CodeBuildKubectlRole --policy-arn arn:aws:iam::aws:policy/CloudWatchLogsFullAccess
aws iam attach-role-policy --role-name CodeBuildKubectlRole --policy-arn arn:aws:iam::aws:policy/AWSCodeBuildAdminAccess
aws iam attach-role-policy --role-name CodeBuildKubectlRole --policy-arn arn:aws:iam::aws:policy/AWSCodeCommitFullAccess
aws iam attach-role-policy --role-name CodeBuildKubectlRole --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess
aws iam attach-role-policy --role-name CodeBuildKubectlRole --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess

echo "IAM role 'CodeBuildKubectlRole' created and policies attached successfully."
