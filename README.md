# Enterprise AI Platform – AWS DevOps Project

An end-to-end DevOps project demonstrating cloud infrastructure automation, containerization, CI/CD pipeline implementation, container image management, and Kubernetes deployment on Amazon Web Services (AWS).

The project uses a Python FastAPI application and integrates Docker, Amazon ECR, Amazon EKS, Terraform, GitHub Actions, and Jenkins to demonstrate automated application delivery.

---

## 1. Project Overview

This project demonstrates the complete application delivery lifecycle:

1. Develop and test a Python FastAPI application.
2. Containerize the application using Docker.
3. Provision cloud infrastructure using Terraform.
4. Store Docker images in Amazon Elastic Container Registry (ECR).
5. Automate CI/CD using GitHub Actions.
6. Implement a second CI/CD pipeline using Jenkins.
7. Configure secure AWS authentication for CI/CD pipelines.
8. Deploy containerized applications to Amazon Elastic Kubernetes Service (EKS).
9. Verify Kubernetes deployments and application rollout status.

### Project Objectives

- Implement Infrastructure as Code (IaC) using Terraform.
- Build and manage Docker containers.
- Automate application testing and delivery.
- Configure Jenkins and GitHub Actions CI/CD pipelines.
- Implement AWS IAM-based access control.
- Configure GitHub Actions authentication using OpenID Connect (OIDC).
- Integrate Jenkins with Amazon ECR and Amazon EKS.
- Deploy and manage applications using Kubernetes.
- Develop practical Linux and cloud infrastructure administration skills.

---

## 2. Technology Stack

| Category | Technologies |
|---|---|
| Operating System | Red Hat Enterprise Linux 10 |
| Programming Language | Python 3.12 |
| Backend Framework | FastAPI |
| Java Runtime | Amazon Corretto OpenJDK 21 |
| Containerization | Docker |
| Cloud Platform | Amazon Web Services (AWS) |
| Infrastructure as Code | Terraform |
| Container Registry | Amazon ECR |
| Container Orchestration | Kubernetes |
| Managed Kubernetes | Amazon EKS |
| CI/CD Automation | Jenkins, GitHub Actions |
| CI/CD Pipeline Definition | Jenkinsfile, YAML |
| AWS Authentication | IAM, OIDC, AWS CLI |
| Kubernetes Management | kubectl |
| Version Control | Git and GitHub |
| Automation Runner | GitHub Actions Self-hosted Runner |

### Additional DevOps Tools

- Jenkins Pipeline
- Docker CLI
- AWS CLI v2
- Terraform CLI
- Kubernetes command-line tools
- Linux shell scripting
- pytest

---

## 3. System Architecture

The project uses two CI/CD automation workflows to demonstrate different approaches to application delivery.

### GitHub Actions Workflow

```text
Developer
    |
    v
GitHub Repository
    |
    v
GitHub Actions
    |
    +--------------------+
    |                    |
    v                    v
Python Tests         AWS OIDC Login
    |                    |
    v                    v
Docker Build       Assume IAM Role
    |                    |
    +---------+----------+
              |
              v
          Amazon ECR
              |
              v
          Amazon EKS
              |
              v
      Kubernetes Deployment
              |
              v
       FastAPI Application
```

### Jenkins Workflow

```text
Developer
    |
    v
GitHub Repository
    |
    v
Jenkins Pipeline
    |
    v
Checkout Source Code
    |
    v
Install Dependencies
    |
    v
Run pytest Tests
    |
    v
Build Docker Image
    |
    v
Authenticate with Amazon ECR
    |
    v
Push Docker Image to ECR
    |
    v
Authenticate with Amazon EKS
    |
    v
Apply Kubernetes Manifests
    |
    v
Deploy Application
    |
    v
Verify Deployment Rollout
```

---

## 4. AWS Infrastructure

AWS infrastructure is provisioned and managed using Terraform.

| Resource | Configuration |
|---|---|
| AWS Region | ap-southeast-1 |
| VPC CIDR | 10.0.0.0/16 |
| Public Subnet 1 | 10.0.1.0/24 |
| Public Subnet 2 | 10.0.2.0/24 |
| EKS Cluster | enterprise-ai-eks |
| EKS Node Group | enterprise-ai-eks-nodes |
| Worker Instance Type | t3.medium |
| ECR Repository | enterprise-ai-platform |

### AWS Services

- Amazon VPC
- Internet Gateway
- Public Subnets
- Route Tables
- AWS IAM
- Amazon Elastic Container Registry (ECR)
- Amazon Elastic Kubernetes Service (EKS)
- EKS Managed Node Group
- IAM Roles and Policies
- GitHub Actions OIDC Identity Provider

---

## 5. Project Structure

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
├── Jenkinsfile
├── requirements.txt
├── .gitignore
└── README.md
```

---

## 6. Application API

The application is developed using Python and FastAPI.

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

The prediction endpoint currently provides a sample prediction response and can be extended with a machine learning model.

---

## 7. Docker Containerization

Docker is used to package the FastAPI application and its dependencies into a portable container image.

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

### Verify Container

```bash
docker ps

docker logs ai-platform
```

### Test Application

```bash
curl http://localhost:8000/health
```

---

## 8. Amazon ECR – Container Image Management

Amazon ECR is used to store and manage Docker images.

### Authenticate with Amazon ECR

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

The Jenkins pipeline also publishes versioned images using Jenkins build numbers, together with a `latest` tag.

Example:

```text
803109508817.dkr.ecr.ap-southeast-1.amazonaws.com/enterprise-ai-platform:8
```

---

## 9. Infrastructure as Code – Terraform

Terraform is used to provision and manage AWS infrastructure.

### Configure AWS SSO

```bash
aws configure sso --profile enterprise-ai-admin
```

Authenticate:

```bash
aws sso login --profile enterprise-ai-admin
```

Verify AWS identity:

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

### Apply Infrastructure Changes

```bash
terraform apply
```

Always review the Terraform execution plan before approving infrastructure changes.

---

## 10. Amazon EKS – Kubernetes Deployment

Amazon EKS provides the managed Kubernetes control plane for deploying the application.

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

### Deploy Kubernetes Resources

```bash
kubectl apply -f k8s/deployment.yaml

kubectl apply -f k8s/service.yaml
```

### Verify Deployment

```bash
kubectl get deployments

kubectl get pods -o wide

kubectl get services
```

### Verify Rollout

```bash
kubectl rollout status deployment/ai-platform
```

### Access Application Locally

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

## 11. GitHub Actions CI/CD

GitHub Actions automates application testing, Docker image building, publishing to Amazon ECR, and Kubernetes deployment.

Workflow file:

```text
.github/workflows/aws-cicd.yml
```

### Pipeline Stages

| Stage | Description |
|---|---|
| Checkout | Retrieves source code |
| Setup Python | Configures Python environment |
| Install Dependencies | Installs application dependencies |
| Run Tests | Executes pytest |
| AWS Authentication | Authenticates through GitHub OIDC |
| ECR Login | Authenticates Docker with Amazon ECR |
| Docker Build | Builds application image |
| Docker Push | Publishes image to ECR |
| Update kubeconfig | Connects to Amazon EKS |
| Deploy Image | Updates Kubernetes deployment |
| Rollout Verification | Checks deployment availability |
| Health Verification | Tests the application health endpoint |

### GitHub Actions Authentication

The workflow uses AWS IAM roles and OpenID Connect (OIDC) for authentication.

This avoids storing long-lived AWS access keys in GitHub Actions.

The GitHub repository configuration includes variables such as:

| Variable | Value |
|---|---|
| AWS_REGION | ap-southeast-1 |
| AWS_ACCOUNT_ID | 803109508817 |
| ECR_REPOSITORY | enterprise-ai-platform |
| EKS_CLUSTER_NAME | enterprise-ai-eks |
| AWS_ROLE_ARN | GitHub Actions IAM role ARN |

Workflow triggers include pushes to the `main` branch and manual execution through `workflow_dispatch`.

---

## 12. Jenkins CI/CD Pipeline

Jenkins provides an additional CI/CD implementation for automating application delivery to Amazon EKS.

### Jenkins Environment

| Configuration | Details |
|---|---|
| Operating System | RHEL 10 |
| Jenkins Version | 2.580.2 |
| Java Runtime | Amazon Corretto OpenJDK 21 |
| AWS CLI | AWS CLI v2 |
| Kubernetes CLI | kubectl |
| Container Runtime | Docker |
| Pipeline Definition | Jenkinsfile |
| AWS Region | ap-southeast-1 |
| EKS Cluster | enterprise-ai-eks |
| ECR Repository | enterprise-ai-platform |

### Jenkins Pipeline Stages

| Stage | Description |
|---|---|
| Checkout | Retrieves source code from GitHub |
| Install Dependencies and Test | Installs Python dependencies and runs pytest |
| Build Docker Image | Builds versioned and latest Docker images |
| Push Image to Amazon ECR | Authenticates and pushes images to ECR |
| Verify EKS Access | Verifies AWS identity and Kubernetes permissions |
| Deploy to Amazon EKS | Applies Kubernetes deployment and service manifests |
| Deployment Rollout | Waits for Kubernetes deployment readiness |

### Jenkins AWS Authentication

Jenkins uses a dedicated AWS IAM user for pipeline authentication.

The AWS credentials are stored in Jenkins Credentials and accessed through the credential ID:

```text
aws-jenkins-ecr
```

The Jenkins IAM user has permissions for ECR image publishing and the required EKS access.

An EKS access entry and the AmazonEKSEditPolicy association provide Kubernetes access within the `default` namespace.

AWS credentials are not stored directly in the Jenkinsfile.

### Jenkins Deployment Process

The pipeline performs the following operations:

1. Retrieves the latest source code.
2. Runs automated Python tests.
3. Builds the Docker image.
4. Authenticates with Amazon ECR.
5. Pushes the versioned image to ECR.
6. Configures Kubernetes access using `aws eks update-kubeconfig`.
7. Applies the Kubernetes deployment manifest.
8. Applies the Kubernetes service manifest.
9. Deploys the image corresponding to the Jenkins build number.
10. Waits for the Kubernetes rollout to complete.
11. Verifies deployments, pods, services, and deployed image.

### Jenkins Pipeline Configuration

The pipeline is defined in:

```text
Jenkinsfile
```

The image tag is generated dynamically using:

```groovy
ECR_IMAGE="$IMAGE_URI:$BUILD_NUMBER"
```

The deployment uses:

```bash
kubectl rollout status deployment/ai-platform \
  -n default \
  --timeout=300s
```

---

## 13. GitHub Actions Self-hosted Runner

A self-hosted GitHub Actions runner is configured on the RHEL 10 environment.

| Configuration | Value |
|---|---|
| Operating System | RHEL 10 |
| Architecture | Linux x64 |
| Runner Name | localhost |
| Runner Labels | self-hosted, Linux, X64 |
| Installation Directory | `/opt/actions-runner` |
| Execution Mode | systemd service |

The runner executes GitHub Actions jobs using the local RHEL environment.

It is configured as a systemd service with the required SELinux permissions.

---

## 14. Security Implementation

The project implements several AWS and container security practices:

- AWS IAM roles and policies for access control.
- GitHub Actions authentication through OIDC.
- Dedicated IAM credentials for Jenkins.
- Jenkins credentials management instead of hardcoding AWS access keys.
- EKS access entries for CI/CD authentication.
- Restricted Kubernetes namespace access for Jenkins.
- Amazon ECR authentication using AWS authorization tokens.
- Non-root Docker container execution.
- Restricted EKS API endpoint access.

**Security reminder:** Never commit AWS access keys, secret keys, GitHub runner registration tokens, private keys, or other sensitive credentials to GitHub.

---

## 15. Testing and Verification

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

### CI/CD Verification

The Jenkins pipeline completed successfully in Build #8.

Verified pipeline activities include:

- GitHub source checkout.
- Python dependency installation and automated tests.
- Docker image build.
- Amazon ECR authentication and image publishing.
- Jenkins AWS identity verification.
- Amazon EKS connection.
- Kubernetes access verification.
- Kubernetes deployment and service application.
- Deployment rollout verification.

---

## 16. Troubleshooting

| Issue | Possible Solution |
|---|---|
| ECR authentication failure | Reauthenticate using `aws ecr get-login-password` |
| Docker image not found | Verify the image tag using `docker images` |
| Kubernetes authentication failure | Run `aws eks update-kubeconfig` |
| Pod ImagePullBackOff | Check the ECR image URI and node IAM permissions |
| Jenkins pipeline compilation failure | Check Jenkinsfile Declarative Pipeline braces and stage structure |
| Jenkins AWS authentication failure | Verify Jenkins credentials and IAM permissions |
| Jenkins EKS access denied | Check EKS access entry and associated access policy |
| Jenkins rollout timeout | Inspect pod status, events, and application logs |
| GitHub runner unavailable | Check runner status and workflow labels |
| Runner SELinux permission error | Check SELinux contexts and service logs |
| EKS endpoint timeout | Check network connectivity and authorized IP CIDR |
| Terraform validation failure | Run `terraform validate` and review configuration errors |

---

## 17. Future Improvements

Planned improvements include:

- Prometheus and Grafana monitoring.
- Centralized application and infrastructure logging.
- Kubernetes autoscaling.
- Ingress controller and AWS Load Balancer integration.
- HTTPS and TLS configuration.
- Terraform remote state management.
- Infrastructure security scanning.
- Docker image vulnerability scanning.
- Automated deployment rollback.
- Integration of a real machine learning prediction model.
- MLOps model training and deployment automation.
- Enhanced Jenkins pipeline notifications.
- Continuous deployment approval gates.

---

## 18. Cost Management and Infrastructure Cleanup

AWS services such as EKS, EC2 worker nodes, networking resources, and storage may generate charges while active.

Review AWS billing and resource usage regularly.

When the infrastructure is no longer required, review the Terraform destroy plan:

```bash
cd terraform-aws

terraform plan -destroy
```

Only after reviewing the plan and confirming that the resources can be removed:

```bash
terraform destroy
```

**Important:** Destroying infrastructure can make the application unavailable. Review all resources and dependencies before approving the operation.

---

## 19. Skills Demonstrated

This project demonstrates practical skills in:

- Linux system administration using RHEL.
- Python application testing.
- Docker image creation and container management.
- Terraform infrastructure provisioning.
- AWS IAM and cloud security.
- Amazon VPC and networking.
- Amazon ECR image management.
- Amazon EKS and Kubernetes deployment.
- Jenkins CI/CD pipeline development.
- GitHub Actions automation.
- AWS OIDC authentication.
- Jenkins credential management.
- Self-hosted runner configuration.
- Kubernetes rollout verification.
- Infrastructure troubleshooting.
- Automated application delivery.

---

## 20. Project Information

**Project:** Enterprise AI Platform – AWS DevOps Project

**GitHub Repository:**  
https://github.com/OshanWanasekara/enterprise-ai-platform-aws

**Cloud Provider:** Amazon Web Services

**AWS Region:** Asia Pacific (Singapore) – `ap-southeast-1`

**Kubernetes Cluster:** `enterprise-ai-eks`

**Container Registry:** Amazon ECR

**CI/CD Tools:** Jenkins and GitHub Actions

**Infrastructure as Code:** Terraform

**Project Status:** Jenkins CI/CD pipeline and Amazon EKS deployment successfully completed and verified through Build #8.

---

*This project was developed as a practical DevOps implementation to demonstrate automated application delivery, infrastructure management, containerization, and Kubernetes orchestration using AWS.*
