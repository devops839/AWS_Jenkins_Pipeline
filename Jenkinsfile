pipeline {
    agent any  // This defines the agent where the pipeline will run.
    
    tools {
        jdk 'jdk17'  // Specifies the JDK to be used for the build (from the Eclipse Temurin plugin).
        maven 'maven3'  // Specifies the Maven installation to be used.
    }

    environment {
        SCANNER_HOME = tool 'sonar-scanner'  // Defines the location of SonarQube Scanner.
        EMAIL_RECIPIENTS = 'your-email@example.com'
        AWS_REGION = 'us-east-1'  // Your AWS region
        ECR_REPO_URI = '123456789012.dkr.ecr.us-east-1.amazonaws.com/boardshack'  // ECR Repository URI
        EKS_CLUSTER_NAME = 'your-eks-cluster'  // EKS Cluster name
    }
    stages {
        // Git Checkout Stage
        stage('Git Checkout') {
            steps {
                git branch: 'main', credentialsId: 'git-cred', url: 'https://github.com/jaiswaladi246/Boardgame.git'
            }
        }
        // Compile Stage (Using Maven)
        stage('Compile') {
            steps {
                sh "mvn compile"
            }
        }
        // Test Stage (Using Maven)
        stage('Test') {
            steps {
                sh "mvn test"
            }
        }
        // File System Scan using Trivy
        stage('File System Scan') {
            steps {
                sh "trivy fs --format table -o trivy-fs-report.html ."
            }
        }
        // SonarQube Analysis Stage
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonar') {
                    sh '''$SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=BoardGame -Dsonar.projectKey=BoardGame -Dsonar.java.binaries=.'''
                }
            }
        }
        // Quality Gate Stage (Wait for the SonarQube analysis result)
        stage('Quality Gate') {
            steps {
                script {
                    waitForQualityGate abortPipeline: false, credentialsId: 'sonar-token'
                }
            }
        }
        // Build Stage (Create package with Maven)
        stage('Build') {
            steps {
                sh "mvn package -DskipTests"  // Skip tests if they're already run earlier
            }
        }
        // Publish to JFrog (Deploy Maven artifacts to a JFrog repository)
        stage('Publish To Artifactory') {
            steps {
                script {
                    // Ensure that the Artifactory server is configured in Jenkins (as described in Step 2)
                    def server = Artifactory.server 'artifactory-server-id'  // Use the Artifactory server ID configured in Jenkins
                    def buildInfo = Artifactory.newBuildInfo()

                    // Deploy the artifact to Artifactory using Maven
                    server.deployArtifacts buildInfo
                }
            }
        }
        // Docker Image Build & Tagging
        stage('Build & Tag Docker Image') {
            steps {
                script {
                    def dockerTag = "boardshack:${env.BUILD_NUMBER}"  // Tag with build number
                    sh "docker build -t ${dockerTag} ."
                }
            }
        }
        // Docker Image Scan with Trivy
        stage('Docker Image Scan') {
            steps {
                script {
                    def dockerTag = "adijaiswal/boardshack:${env.BUILD_NUMBER}"  // Use tagged image
                    sh "trivy image --format table -o trivy-image-report.html ${dockerTag}"
                }
            }
        }
        /* Push Docker Image to Docker Registry
        stage('Push Docker Image') {
            steps {
                script {
                    def dockerTag = "adijaiswal/boardshack:${env.BUILD_NUMBER}"  // Use tagged image
                    withDockerRegistry(credentialsId: 'docker-cred', toolName: 'docker') {
                        sh "docker push ${dockerTag}"
                    }
                }
            }
        }*/
        // Authenticate to AWS ECR
        stage('Authenticate to AWS ECR') {
            steps {
                script {
                    // Log in to ECR using AWS CLI (ensure AWS CLI is configured on Jenkins)
                    sh """
                    aws ecr get-login-password --region ${env.AWS_REGION} | docker login --username AWS --password-stdin ${env.ECR_REPO_URI}
                    """
                }
            }
        }
        // Push Docker Image to AWS ECR
        stage('Push Docker Image to ECR') {
            steps {
                script {
                    def dockerTag = "boardshack:${env.BUILD_NUMBER}"
                    sh "docker tag ${dockerTag} ${env.ECR_REPO_URI}:${dockerTag}"
                    sh "docker push ${env.ECR_REPO_URI}:${dockerTag}"
                }
            }
        }
        // Deploy to EKS
        stage('Deploy to EKS') {
            steps {
                script {
                    // Update Kubeconfig for EKS
                    sh """
                    aws eks update-kubeconfig --name ${env.EKS_CLUSTER_NAME} --region ${env.AWS_REGION}
                    """
                    // Deploy the application using kubectl (ensure the correct Kubeconfig is set in Jenkins)
                    sh """
                    kubectl set image deployment/boardshack boardshack=${env.ECR_REPO_URI}:${env.BUILD_NUMBER} -n webapps
                    kubectl rollout status deployment/boardshack -n webapps
                    """
                }
            }
        }
        // Verify Deployment on Kubernetes
        stage('Verify the Deployment') {
            steps {
                script {
                    // Check the Kubernetes resources
                    sh "kubectl get pods -n webapps"
                    sh "kubectl get svc -n webapps"
                }
            }
        }
    }
    
    post {
        always {
            script {
                def subject = ""
                def body = ""
                // Check the build result and customize the email content
                if (currentBuild.currentResult == 'SUCCESS') {
                    subject = "SUCCESS: Jenkins Build ${env.JOB_NAME} #${env.BUILD_NUMBER}"
                    body = """
                    <p>Build Result: SUCCESS</p>
                    <p>Job: ${env.JOB_NAME}</p>
                    <p>Build URL: <a href="${env.BUILD_URL}">${env.BUILD_URL}</a></p>
                    <p>Commit: ${env.GIT_COMMIT}</p>
                    """
                } else if (currentBuild.currentResult == 'FAILURE') {
                    subject = "FAILURE: Jenkins Build ${env.JOB_NAME} #${env.BUILD_NUMBER}"
                    body = """
                    <p>Build Result: FAILURE</p>
                    <p>Job: ${env.JOB_NAME}</p>
                    <p>Build URL: <a href="${env.BUILD_URL}">${env.BUILD_URL}</a></p>
                    <p>Commit: ${env.GIT_COMMIT}</p>
                    """
                }
                // Send the email
                emailext (
                    to: "${env.EMAIL_RECIPIENTS}",
                    subject: subject,
                    body: body
                )
            }
        }
    }
}