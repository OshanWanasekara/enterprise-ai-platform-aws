
pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
    }

    environment {
        AWS_REGION = 'ap-southeast-1'
        AWS_ACCOUNT_ID = '803109508817'
        ECR_REPOSITORY = 'enterprise-ai-platform'
        ECR_REGISTRY = '803109508817.dkr.ecr.ap-southeast-1.amazonaws.com'
        IMAGE_URI = '803109508817.dkr.ecr.ap-southeast-1.amazonaws.com/enterprise-ai-platform'
    }

    stages {

        // 1. Checkout source code
        stage('Checkout') {
            steps {
                checkout scm
                echo 'Source code checked out successfully.'
            }
        }

        // 2. Install dependencies and run tests
        stage('Install Dependencies and Test') {
            steps {
                sh '''
                    set -e

                    python3 -m venv .venv
                    .venv/bin/python -m pip install --upgrade pip
                    .venv/bin/pip install -r requirements.txt pytest

                    .venv/bin/pytest -v
                '''
            }
        }

        // 3. Build Docker image
        stage('Build Docker Image') {
            steps {
                sh '''
                    set -e

                    docker build \
                      -t "$IMAGE_URI:$BUILD_NUMBER" \
                      -t "$IMAGE_URI:latest" .
                '''
            }
        }

        // 4. Push Docker image to Amazon ECR
        stage('Push Image to Amazon ECR') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-jenkins-ecr'
                ]]) {
                    sh '''
                        set -e

                        echo "===== Checking AWS Identity ====="
                        aws sts get-caller-identity

                        echo "===== Logging in to Amazon ECR ====="

                        aws ecr get-login-password \
                          --region "$AWS_REGION" |
                          docker login \
                            --username AWS \
                            --password-stdin "$ECR_REGISTRY"

                        echo "===== Pushing Versioned Image ====="
                        docker push "$IMAGE_URI:$BUILD_NUMBER"

                        echo "===== Pushing Latest Image ====="
                        docker push "$IMAGE_URI:latest"

                        echo "Docker image pushed successfully."
                    '''
                }
            }
        }

        // 5. Verify Jenkins access to Amazon EKS
        stage('Verify EKS Access') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-jenkins-ecr'
                ]]) {
                    sh '''
                        set -e

                        export AWS_DEFAULT_REGION="$AWS_REGION"
                        export KUBECONFIG="$WORKSPACE/.kube/config"

                        mkdir -p "$WORKSPACE/.kube"

                        echo "===== Verify Jenkins AWS Identity ====="
                        aws sts get-caller-identity

                        echo "===== Connect to Amazon EKS ====="

                        aws eks update-kubeconfig \
                          --region "$AWS_REGION" \
                          --name enterprise-ai-eks

                        echo "===== Check Kubernetes Permissions ====="

                        kubectl auth can-i get deployments -n default
                        kubectl auth can-i patch deployments -n default
                        kubectl auth can-i create services -n default
                        kubectl auth can-i get pods -n default

                        echo "===== Existing Kubernetes Deployments ====="
                        kubectl get deployments -n default

                        echo "===== Existing Kubernetes Pods ====="
                        kubectl get pods -n default

                        echo "===== Existing Kubernetes Services ====="
                        kubectl get services -n default

                        echo "EKS access verification completed."
                    '''
                }
            }
        }

        // 6. Deploy application to Amazon EKS
        stage('Deploy to Amazon EKS') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-jenkins-ecr'
                ]]) {
                    sh '''
                        set -e

                        export AWS_DEFAULT_REGION="$AWS_REGION"
                        export KUBECONFIG="$WORKSPACE/.kube/config"

                        ECR_IMAGE="$IMAGE_URI:$BUILD_NUMBER"

                        echo "===== Connect to Amazon EKS ====="

                        mkdir -p "$WORKSPACE/.kube"

                        aws eks update-kubeconfig \
                          --region "$AWS_REGION" \
                          --name enterprise-ai-eks

                        echo "===== Prepare Deployment Manifest ====="

                        sed -E \
                          "s|^([[:space:]]*image: ).*$|\\1${ECR_IMAGE}|" \
                          k8s/deployment.yaml \
                          > "$WORKSPACE/deployment-rendered.yaml"

                        echo "===== Apply Kubernetes Deployment ====="

                        kubectl apply \
                          -f "$WORKSPACE/deployment-rendered.yaml"

                        echo "===== Apply Kubernetes Service ====="

                        kubectl apply -f k8s/service.yaml

                        echo "===== Wait for Deployment Rollout ====="

                        kubectl rollout status deployment/ai-platform \
                          -n default \
                          --timeout=300s

                        echo "===== Verify Deployment ====="

                        kubectl get deployment ai-platform -n default

                        echo "===== Verify Application Pods ====="

                        kubectl get pods -n default -o wide

                        echo "===== Verify Kubernetes Service ====="

                        kubectl get service ai-platform-service -n default

                        echo "===== Verify Deployed Docker Image ====="

                        kubectl get deployment ai-platform \
                          -n default \
                          -o jsonpath='{.spec.template.spec.containers[?(@.name=="ai-api")].image}'

                        echo

                        echo "SUCCESS: Application deployed to Amazon EKS."
                    '''
                }
            }
        }
    }

    post {
        success {
            echo 'SUCCESS: Jenkins pipeline completed successfully.'
            echo 'Application tests, Docker build, ECR push and EKS deployment completed.'
        }

        failure {
            echo 'FAILURE: Jenkins pipeline failed. Check the stage logs above.'
        }

        always {
            echo 'Jenkins pipeline execution finished.'
        }
    }
}

