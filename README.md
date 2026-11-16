# Enterprise AI Platform – AWS DevOps Project

An end-to-end DevOps implementation demonstrating containerization, Infrastructure as Code (IaC), CI/CD automation, container image management, and Kubernetes deployment on Amazon Web Services (AWS).

The project deploys a FastAPI-based Enterprise AI Platform using Docker, Amazon ECR, Amazon EKS, Terraform, and GitHub Actions.

---

## 1. Project Overview

This project demonstrates how to automate the complete application delivery lifecycle:

1. Develop and test a Python FastAPI application.
2. Containerize the application using Docker.
3. Provision AWS infrastructure using Terraform.
4. Store Docker images in Amazon Elastic Container Registry (ECR).
5. Automate CI/CD using GitHub Actions.
6. Authenticate GitHub Actions with AWS using OpenID Connect (OIDC).
7. Deploy the application to Amazon Elastic Kubernetes Service (EKS).
8. Verify Kubernetes deployment status and application health.

### Project Objectives

- Implement infrastructure automation using Terraform.
- Build and manage Docker containers.
- Deploy containerized applications to Kubernetes.
- Configure automated CI/CD pipelines.
- Implement secure AWS authentication using GitHub OIDC.
- Configure a self-hosted GitHub Actions runner on RHEL.
- Understand AWS cloud infrastructure and DevOps workflows.

---

## 2. Technology Stack

| Category | Technologies |
|---|---|
| Operating System | Red Hat Enterprise Linux 10 |
| Programming Language | Python 3.12 |
| Backend Framework | FastAPI |
| Containerization | Docker |
| Infrastructure as Code | Terraform |
| Cloud Platform | AWS |
| Container Registry | Amazon ECR |
| Kubernetes | Amazon EKS |
| CI/CD | GitHub Actions |
| Authentication | AWS IAM, OIDC |
| Kubernetes Management | kubectl |
| Version Control | Git and GitHub |
| Automation Runner | Self-hosted GitHub Actions Runner |

---

## 3. AWS Architecture

```text
                    Developer
                        |
                        v
                 GitHub Repository
                        |
                        v
                GitHub Actions CI/CD
                        |
              +---------+---------+
              |                   |
              v                   v
         Run Pytest          AWS OIDC Login
              |                   |
              v                   v
         Build Docker       Assume IAM Role
              |                   |
              +---------+---------+
                        |
                        v
                  Amazon ECR
                 Docker Images
                        |
                        v
                GitHub Actions
                Self-hosted Runner
                        |
                        v
                  Amazon EKS
                 Kubernetes Cluster
                        |
                        v
                  Deployment
                        |
                        v
                  Kubernetes Pod
                        |
                        v
                 FastAPI Application
                        |
                        v
                 Health Verification
```

### AWS Infrastructure

The infrastructure is provisioned using Terraform.

| Resource | Configuration |
|---|---|
| AWS Region | ap-southeast-1 |
| VPC | 10.0.0.0/16 |
| Public Subnet 1 | 10.0.1.0/24 |
| Public Subnet 2 | 10.0.2.0/24 |
| EKS Cluster | enterprise-ai-eks |
| EKS Node Group | enterprise-ai-eks-nodes |
| Worker Instance Type | t3.medium |
| ECR Repository | enterprise-ai-platform |

The infrastructure includes:

- Amazon VPC
- Internet Gateway
- Public subnets
- Route table
- IAM roles and policies
- Amazon EKS cluster
- EKS managed node group
- Amazon ECR repository
- GitHub Actions OIDC identity provider and IAM role

---

## 4. Application Structure

The FastAPI application provides sample API endpoints to demonstrate containerization and deployment.

```text
enterprise-ai-platform-aws/
│
├── app/
│   └── main.py
│
├── tests/
│   └── test_api.py
│
├── k8s/
│   ├── deployment.yaml
│   └── service.yaml
│
├── terraform-aws/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── providers.tf
│   └── github-oidc.tf
│
├── .github/
│   └── workflows/
│       └── aws-cicd.yml
│
├── Dockerfile
├── requirements.txt
├── .gitignore
└── README.md
```

---

## 5. Application API Endpoints

| Method | Endpoint | Description |
|---|---|---|
| GET | `/` | Application information |
| GET | `/health` | Application health status |
| POST | `/predict` | Sample prediction response |
| GET | `/docs` | Swagger API documentation |

Example health response:

```json
{
  "status": "healthy"
}
```

The prediction endpoint currently returns a sample response. It can be extended to integrate an actual machine learning model.

---

## 6. Docker Containerization

The application is containerized using Docker.

### Dockerfile

```dockerfile
FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY app/ ./app/

RUN useradd --create-home --uid 10001 appuser \
    && chown -R appuser:appuser /app

USER appuser

EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### Build Docker Image

```bash
docker build -t enterprise-ai-platform:latest .
```

### Run Docker Container

```bash
docker run -d \
  --name ai-platform \
  -p 8000:8000 \
  enterprise-ai-platform:latest
```

### Test the Application

```bash
curl http://localhost:8000/health
```

---

## 7. Amazon ECR Configuration

Amazon ECR is used to store and manage Docker images.

### Authenticate Docker with ECR

```bash
aws ecr get-login-password \
  --region ap-southeast-1 \
  --profile enterprise-ai-admin | \
docker login \
  --username AWS \
  --password-stdin 803109508817.dkr.ecr.ap-southeast-1.amazonaws.com
```

### Tag Docker Image

```bash
docker tag enterprise-ai-platform:latest \
803109508817.dkr.ecr.ap-southeast-1.amazonaws.com/enterprise-ai-platform:v1
```

### Push Docker Image

```bash
docker push \
803109508817.dkr.ecr.ap-southeast-1.amazonaws.com/enterprise-ai-platform:v1
```

---

## 8. Infrastructure Provisioning with Terraform

Terraform is used to provision and manage AWS infrastructure.

### Configure AWS Authentication

```bash
aws configure sso --profile enterprise-ai-admin
```

Authenticate:

```bash
aws sso login --profile enterprise-ai-admin
```

Verify the AWS identity:

```bash
aws sts get-caller-identity \
  --profile enterprise-ai-admin
```

### Initialize Terraform

```bash
cd terraform-aws

terraform init
```

### Validate Configuration

```bash
terraform validate
```

### Review Infrastructure Plan

```bash
terraform plan
```

### Provision Infrastructure

```bash
terraform apply
```

Review the Terraform plan carefully before approving infrastructure creation.

---

## 9. Amazon EKS and Kubernetes Deployment

Amazon EKS provides the managed Kubernetes control plane.

### Configure kubectl

```bash
aws eks update-kubeconfig \
  --region ap-southeast-1 \
  --name enterprise-ai-eks \
  --profile enterprise-ai-admin
```

### Verify Cluster Connection

```bash
kubectl get nodes -o wide
```

### Deploy the Application

```bash
kubectl apply -f k8s/deployment.yaml

kubectl apply -f k8s/service.yaml
```

### Verify Kubernetes Resources

```bash
kubectl get deployments

kubectl get pods -o wide

kubectl get services
```

### Verify Deployment Rollout

```bash
kubectl rollout status deployment/ai-platform
```

### Access the Application Locally

```bash
kubectl port-forward service/ai-platform-service 8000:8000
```

Test:

```bash
curl http://localhost:8000/

curl http://localhost:8000/health
```

Swagger documentation:

```text
http://localhost:8000/docs
```

---

## 10. GitHub Actions CI/CD Pipeline

The project uses GitHub Actions to automate application testing, Docker image building, image publishing, and Kubernetes deployment.

Workflow file:

```text
.github/workflows/aws-cicd.yml
```

### CI/CD Pipeline Stages

| Stage | Description |
|---|---|
| Checkout | Retrieves source code from GitHub |
| Setup Python | Configures Python 3.12 |
| Install Dependencies | Installs application requirements |
| Run Tests | Executes pytest test cases |
| AWS Authentication | Authenticates through GitHub OIDC |
| ECR Login | Logs Docker into Amazon ECR |
| Docker Build | Builds the application image |
| Docker Push | Publishes the image to Amazon ECR |
| Update kubeconfig | Connects to Amazon EKS |
| Deploy Image | Updates the Kubernetes deployment |
| Rollout Verification | Checks deployment availability |
| Health Verification | Tests the application health endpoint |

### GitHub Repository Variables

Configure the following repository variables under:

**Settings → Secrets and variables → Actions → Variables**

| Variable | Value |
|---|---|
| AWS_REGION | ap-southeast-1 |
| AWS_ACCOUNT_ID | 803109508817 |
| ECR_REPOSITORY | enterprise-ai-platform |
| EKS_CLUSTER_NAME | enterprise-ai-eks |
| AWS_ROLE_ARN | arn:aws:iam::803109508817:role/enterprise-ai-github-actions-role |

The AWS role is assumed through OIDC. Long-lived AWS access keys are not required by the workflow.

### Workflow Trigger

The pipeline runs when code is pushed to the `main` branch or when manually triggered using `workflow_dispatch`.

---

## 11. GitHub Actions Self-hosted Runner

A self-hosted GitHub Actions runner is configured on the RHEL 10 environment.

### Runner Configuration

| Configuration | Value |
|---|---|
| Operating System | RHEL 10 |
| Architecture | Linux x64 |
| Runner Name | localhost |
| Runner Labels | self-hosted, Linux, X64 |
| Installation Directory | /opt/actions-runner |
| Execution Mode | systemd service |

The runner is responsible for executing the deployment job that connects to Amazon EKS.

The runner uses a systemd service and has been configured with the appropriate SELinux file context to allow execution on RHEL.

---

## 12. AWS Security Implementation

The project uses several security mechanisms:

- IAM roles and policies for AWS resource access.
- GitHub Actions OIDC authentication.
- Restricted IAM permissions for CI/CD operations.
- EKS access entries for the GitHub Actions IAM role.
- ECR authentication using AWS authorization tokens.
- Non-root Docker container execution.
- Restricted EKS API endpoint access using an authorized public IP CIDR.

**Security note:** Never commit AWS credentials, GitHub runner registration tokens, private keys, or other sensitive information to the repository.

---

## 13. Testing and Verification

The project includes automated API tests using pytest.

### Run Tests Locally

```bash
pip install -r requirements.txt

pytest -v
```

### Verify Docker Container

```bash
docker ps

docker logs ai-platform
```

### Verify Kubernetes Deployment

```bash
kubectl get pods

kubectl get deployments

kubectl rollout status deployment/ai-platform
```

### Verify Application Health

```bash
curl http://localhost:8000/health
```

The GitHub Actions workflow successfully completed both jobs:

1. Test, Build and Push to ECR.
2. Deploy to Amazon EKS.

The deployment job also completed Kubernetes rollout and application health verification.

---

## 14. Important Troubleshooting Notes

| Issue | Possible Solution |
|---|---|
| ECR authentication failure | Reauthenticate using `aws ecr get-login-password` |
| Docker image not found | Verify the image tag using `docker images` |
| Kubernetes authentication failure | Run `aws eks update-kubeconfig` |
| Pod ImagePullBackOff | Check the ECR image URI and node IAM permissions |
| GitHub runner unavailable | Check runner status and workflow labels |
| Runner SELinux permission error | Check SELinux contexts and service logs |
| EKS endpoint timeout | Check the authorized public IP CIDR and network connectivity |
| Terraform validation failure | Run `terraform validate` and review configuration errors |

---

## 15. Future Improvements

The following improvements are planned:

- Prometheus and Grafana monitoring.
- Centralized application and infrastructure logging.
- Kubernetes autoscaling.
- Ingress controller and AWS Load Balancer integration.
- HTTPS and TLS configuration.
- Terraform remote state management.
- Infrastructure security scanning.
- Docker image vulnerability scanning.
- Deployment rollback automation.
- Integration of a real machine learning prediction model.
- MLOps model training and deployment automation.

---

## 16. Cost Management and Infrastructure Cleanup

AWS resources such as EKS clusters, EC2 instances, networking resources, and storage may generate charges while active.

Before finishing the project, review the resources and costs in the AWS Console.

To remove Terraform-managed infrastructure when it is no longer needed:

```bash
cd terraform-aws

terraform plan -destroy

terraform destroy
```

**Important:** Review the destruction plan carefully. This removes Terraform-managed resources and can make the application unavailable. Ensure that no resources you want to keep depend on this infrastructure.

---

## 17. Skills Demonstrated

Through this project, the following practical DevOps skills were implemented:

- Linux administration using RHEL.
- Docker image creation and container management.
- Terraform infrastructure provisioning.
- AWS IAM and security configuration.
- Amazon VPC and networking.
- Amazon ECR image management.
- Amazon EKS and Kubernetes deployment.
- GitHub Actions CI/CD automation.
- OIDC-based cloud authentication.
- Self-hosted runner configuration.
- Application testing and deployment verification.
- Infrastructure troubleshooting.

---

## 18. Project Repository

**GitHub:** https://github.com/OshanWanasekara/enterprise-ai-platform-aws

**Cloud Provider:** Amazon Web Services (AWS)

**Region:** Asia Pacific (Singapore) – ap-southeast-1

**Status:** AWS CI/CD pipeline and Kubernetes deployment successfully verified.

---

*This project was developed as a practical DevOps learning and implementation project to demonstrate automated application delivery and cloud infrastructure management using AWS.*
