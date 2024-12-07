# AWS DevSecOps Pipeline for Voting App

This repository contains the **DevSecOps pipeline** implementation for the **Voting App**. The pipeline is designed to automate the process of building, testing, scanning, and deploying the application to **AWS Elastic Kubernetes Service (EKS)**. It leverages **Jenkins** for continuous integration and **AWS** services for container management.

## 🚀 **Pipeline Stages Overview**

### 1. **Git Checkout**
   - **Description**: The latest code is fetched from the GitHub repository. This ensures the pipeline operates on the most recent version of the application in the **main** branch.
   - **Goal**: Retrieve the latest version of the source code from the repository.

### 2. **Compile**
   - **Description**: The application’s source code is compiled using **Maven**. This step resolves any dependencies and prepares the code for testing and packaging.
   - **Goal**: Compile the Java code and ensure all dependencies are resolved.

### 3. **Test**
   - **Description**: Maven runs unit tests on the application to verify that the code behaves as expected. If any tests fail, the pipeline stops, and the build is marked as failed.
   - **Goal**: Validate the functionality of the application through unit tests.

### 4. **SonarQube Analysis**
   - **Description**: The **SonarQube** tool is used for static code analysis to identify bugs, code smells, and security vulnerabilities in the codebase. A detailed report is generated for review.
   - **Goal**: Analyze the code quality and ensure it meets the required standards.

### 5. **Quality Gate**
   - **Description**: This stage waits for the SonarQube Quality Gate to check if the code quality is acceptable. If the analysis finds critical or major issues, the pipeline will be aborted.
   - **Goal**: Ensure that the code quality meets predefined standards before proceeding to the build and deployment stages.

### 6. **Build**
   - **Description**: This stage packages the application into a **JAR file** using Maven. Tests are skipped since they were already executed in a previous step.
   - **Goal**: Build the deployable artifact (e.g., a JAR file) for the application.

### 7. **Publish to Artifactory**
   - **Description**: The generated JAR file is uploaded to **JFrog Artifactory**, which acts as a version-controlled repository for the application artifacts.
   - **Goal**: Store the application artifact in Artifactory for future deployments or as a dependency.

### 8. **Build & Tag Docker Image**
   - **Description**: A **Docker image** is built for the Voting App, and it is tagged with the Jenkins build number. This ensures each image has a unique identifier tied to the build.
   - **Goal**: Containerize the application by building a Docker image.

### 9. **Trivy Docker Image Scan**
   - **Description**: The **Trivy** tool is used to scan the Docker image for security vulnerabilities, focusing on **high** and **critical** severity issues. The scan results are stored for review.
   - **Goal**: Ensure that the Docker image does not contain known security vulnerabilities, particularly high and critical ones.

### 10. **Authenticate & Push Docker Image to ECR**
   - **Description**: The Docker image is pushed to **AWS Elastic Container Registry (ECR)**. The pipeline authenticates to ECR using the AWS CLI, tags the image with the ECR repository URI, and then uploads the image.
   - **Goal**: Store the Docker image securely in **AWS ECR** for use in deployment to **Amazon EKS**.

### 11. **Kubernetes Deployment to EKS**
   - **Description**: The **Docker image** is deployed to **AWS Elastic Kubernetes Service (EKS)**. The Kubernetes deployment YAML file is dynamically updated with the build number, and then it is applied using **kubectl**.
   - **Goal**: Deploy the containerized application to the **EKS** cluster in AWS.

---

## 🛠 **Setup and Configuration**

### **Prerequisites**
Before setting up this pipeline, ensure the following tools and services are available:

- **Jenkins**: Jenkins server must be running and connected to your GitHub repository.
- **SonarQube**: SonarQube server must be available for code quality analysis.
- **AWS Account**: You should have an active **AWS account** with services like **ECR**, **EKS**, and **IAM** configured.
- **Docker**: Ensure Docker is installed and running to build and push Docker images.
- **Maven**: Maven must be installed for building the application.
- **Trivy**: Trivy should be installed for scanning Docker images for vulnerabilities.

### **AWS Configuration**
- **ECR**: Set up an AWS Elastic Container Registry (ECR) to store the Docker images.
- **EKS**: Set up an AWS Elastic Kubernetes Service (EKS) cluster to run the application.

### **GitHub Integration**
- **GitHub Repository**: The source code should be hosted in a GitHub repository, and Jenkins should be configured to access it using the appropriate credentials.

### **Environment Variables**
Here are the environment variables that should be configured:

- `SCANNER_HOME`: Location of the SonarQube scanner tool.
- `EMAIL_RECIPIENTS`: Email address for notifications.
- `AWS_REGION`: AWS region (e.g., `us-west-2`).
- `ECR_REPO_URI`: The URI for your **AWS ECR** repository.
- `EKS_CLUSTER_NAME`: The name of your **EKS cluster**.
- `IMAGE_TAG`: The Docker image tag (typically set to the Jenkins build number).

---

## 💬 **Notifications and Alerts**
The pipeline sends notifications on build status to the specified email address (`EMAIL_RECIPIENTS`). It is recommended to integrate **Slack** or other notification tools to receive alerts on successful/failed builds.

---

## 📝 **Contributing**

We welcome contributions! If you'd like to help improve the Voting App or the pipeline, please follow these steps:

1. Fork the repository.
2. Create a new branch for your feature or fix.
3. Make your changes and commit them.
4. Push your changes to your forked repository.
5. Create a pull request for review.

---

