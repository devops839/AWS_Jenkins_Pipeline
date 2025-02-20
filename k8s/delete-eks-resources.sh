#!/bin/bash
# Set your variables
AWS_REGION="us-west-2"  # Change this to your desired AWS region
CLUSTER_NAME="my-cluster"  # Name of your EKS cluster
ECR_REPO_NAME="my-repo"  # Name of your ECR repository
NODEGROUP_NAME="my-nodegroup"  # Name of the EKS nodegroup

# Delete the EKS cluster using eksctl
echo "Deleting EKS cluster..."
eksctl delete cluster --region $AWS_REGION --name $CLUSTER_NAME

# Delete the ECR repository using AWS CLI
echo "Deleting ECR repository..."
aws ecr delete-repository --repository-name $ECR_REPO_NAME --region $AWS_REGION --force

# Output the status
echo "EKS cluster, node group, and ECR repository have been deleted successfully."
