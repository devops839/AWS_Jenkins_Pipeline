#!/bin/bash

AWS_REGION="us-west-2"  # Change this to your desired AWS region
CLUSTER_NAME="my-cluster"  # Name of your EKS cluster
ECR_REPO_NAME="my-repo"  # Name of your ECR repository
NODEGROUP_NAME="my-nodegroup"  # Name of the EKS nodegroup
NODE_TYPE="t3.medium"  # Instance type for the nodegroup
NODE_COUNT=3  # Number of nodes in the nodegroup

# Create EKS cluster using eksctl
echo "Creating EKS cluster..."
eksctl create cluster \
  --region $AWS_REGION \
  --name $CLUSTER_NAME \
  --nodegroup-name $NODEGROUP_NAME \
  --node-type $NODE_TYPE \
  --nodes $NODE_COUNT \
  --nodes-min 1 \
  --nodes-max 4 \
  --managed

# Wait for the cluster to be created
echo "Waiting for EKS cluster to be created..."
eksctl utils wait-for-cluster --name $CLUSTER_NAME --region $AWS_REGION

# Set up kubeconfig to interact with the cluster
echo "Configuring kubeconfig for kubectl..."
aws eks --region $AWS_REGION update-kubeconfig --name $CLUSTER_NAME

# Create ECR repository using AWS CLI
echo "Creating ECR repository..."
aws ecr create-repository \
  --repository-name $ECR_REPO_NAME \
  --region $AWS_REGION

# Create IAM identity mapping for the role to access Kubernetes
echo "Creating IAM identity mapping for CodeBuildKubectlRole..."
eksctl create iamidentitymapping \
  --cluster $CLUSTER_NAME \
  --region $AWS_REGION \
  --arn arn:aws:iam::123456:role/CodeBuildKubectlRole \
  --group system:masters \
  --username CodeBuildKubectlRole

# Output the details
echo "EKS Cluster, ECR Repository, and IAM Identity Mapping created successfully!"
echo "EKS Cluster: $CLUSTER_NAME"
echo "ECR Repository: $ECR_REPO_NAME"
echo "IAM Identity Mapping for CodeBuildKubectlRole created."
