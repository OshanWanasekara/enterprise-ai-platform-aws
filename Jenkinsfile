
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
