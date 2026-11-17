
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

        stage('Checkout') {
            steps {
                checkout scm
                echo 'Source code checked out successfully.'
            }
        }

        stage('Install Dependencies and Test') {
            steps {
                sh '''
                    python3 -m venv .venv
                    .venv/bin/python -m pip install --upgrade pip
                    .venv/bin/pip install -r requirements.txt pytest
                    .venv/bin/pytest -v
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    docker build \
                      -t "$IMAGE_URI:$BUILD_NUMBER" \
                      -t "$IMAGE_URI:latest" .
                '''
            }
        }

        stage('Push Image to Amazon ECR') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-jenkins-ecr'
                ]]) {
                    sh '''
                        set -e

                        echo "Checking AWS identity..."
                        aws sts get-caller-identity

                        echo "Logging in to Amazon ECR..."
                        aws ecr get-login-password \
                          --region "$AWS_REGION" |
                          docker login \
                            --username AWS \
                            --password-stdin "$ECR_REGISTRY"

                        echo "Pushing versioned image..."
                        docker push "$IMAGE_URI:$BUILD_NUMBER"

                        echo "Pushing latest image..."
                        docker push "$IMAGE_URI:latest"
                    '''
                }
            }
        }
       
stage('Verify EKS Access') {
    steps {
        withCredentials([[
            $class: 'AmazonWebServicesCredentialsBinding',
            credentialsId: 'aws-jenkins-ecr'
        ]]) {
            sh '''
                set -e

                export AWS_DEFAULT_REGION=ap-southeast-1
                export AWS_REGION=ap-southeast-1
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

                echo "===== Inspect Existing Application ====="
                kubectl get deployments -n default
                kubectl get pods -n default
                kubectl get services -n default

                echo "EKS access verification completed."
            '''
        }
    }


stage('Deploy to Amazon EKS') {
    steps {
        withCredentials([[
            $class: 'AmazonWebServicesCredentialsBinding',
            credentialsId: 'aws-jenkins-ecr'
        ]]) {
            sh '''
                set -e

                export AWS_DEFAULT_REGION=ap-southeast-1
                export AWS_REGION=ap-southeast-1
                export KUBECONFIG="$WORKSPACE/.kube/config"

                ECR_IMAGE="803109508817.dkr.ecr.ap-southeast-1.amazonaws.com/enterprise-ai-platform:${BUILD_NUMBER}"

                echo "===== Connect to Amazon EKS ====="

                mkdir -p "$WORKSPACE/.kube"

                aws eks update-kubeconfig \
                  --region "$AWS_REGION" \
                  --name enterprise-ai-eks

                echo "===== Apply Kubernetes Deployment ====="

                kubectl apply -f k8s/deployment.yaml

                echo "===== Apply Kubernetes Service ====="

                kubectl apply -f k8s/service.yaml

                echo "===== Update Application Image ====="

                kubectl set image deployment/ai-platform \
                  ai-api="$ECR_IMAGE" \
                  -n default

                echo "===== Wait for Deployment Rollout ====="

                kubectl rollout status deployment/ai-platform \
                  -n default \
                  --timeout=300s

                echo "===== Verify Application Pods ====="

                kubectl get pods -n default -o wide

                echo "===== Verify Kubernetes Service ====="

                kubectl get service ai-platform-service -n default

                echo "===== Verify Deployment Image ====="

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
 
    }

    post {
        success {
            echo 'SUCCESS: Tests passed and Docker image pushed to ECR.'
        }

        failure {
            echo 'FAILED: Check the Jenkins console output.'
        }

        always {
            echo 'Jenkins pipeline execution completed.'
        }
    }
}
