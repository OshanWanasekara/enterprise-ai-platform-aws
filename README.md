# Enterprise AI Platform

An AI-powered application platform built with **Python, FastAPI, Docker, and Microsoft Azure**, with an automated CI/CD workflow using **GitHub and Azure DevOps**.

The project demonstrates how to develop, test, containerize, publish, and prepare an application for cloud-native deployment using modern DevOps practices.

---

## Table of Contents

- [Project Overview](#project-overview)
- [Architecture](#architecture)
- [Technology Stack](#technology-stack)
- [Project Features](#project-features)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Run Locally](#run-locally)
- [Run with Docker](#run-with-docker)
- [Automated Testing](#automated-testing)
- [Azure Container Registry](#azure-container-registry)
- [CI/CD Pipeline](#cicd-pipeline)
- [Kubernetes and AKS Deployment](#kubernetes-and-aks-deployment)
- [Environment Variables](#environment-variables)
- [Troubleshooting](#troubleshooting)
- [Future Improvements](#future-improvements)
- [Author](#author)

---

## Project Overview

The Enterprise AI Platform is a containerized application developed using FastAPI and Python.

The main objective of this project is to implement a practical DevOps workflow that automates application testing, Docker image creation, and publishing container images to Azure Container Registry.

The project uses a self-hosted Red Hat Enterprise Linux (RHEL 10) agent to execute Azure DevOps pipeline tasks.

The deployment architecture is designed to extend into Kubernetes using Azure Kubernetes Service (AKS).

### Project Goals

- Develop and run a Python FastAPI application.
- Manage source code using Git and GitHub.
- Implement automated application testing with Pytest.
- Containerize the application using Docker.
- Configure a self-hosted Azure DevOps agent on RHEL 10.
- Build automated CI/CD pipelines using Azure DevOps.
- Publish Docker images to Azure Container Registry.
- Prepare Kubernetes manifests for application deployment.
- Extend the pipeline to support automated AKS deployments.

---

## Architecture

### Current CI/CD Architecture

```text
                 Developer
                     |
                     v
               GitHub Repository
                     |
                     v
               Azure DevOps
                     |
                     v
          RHEL 10 Self-Hosted Agent
                     |
             +-------+-------+
             |       |       |
             v       v       v
          Python  Pytest   Docker
          Setup   Testing   Build
                             |
                             v
                  Azure Container Registry
                             |
                             v
                   Docker Image Storage
```

### Planned Kubernetes Architecture

```text
              GitHub Repository
                     |
                     v
               Azure DevOps
                     |
                     v
             Automated CI/CD
                     |
                     v
          Azure Container Registry
                     |
                     v
             Azure Kubernetes
                  Service
                     |
              +------+------+
              |             |
              v             v
          Kubernetes    Kubernetes
          Deployment     Service
              |
              v
          Application Pods
```

---

## Technology Stack

| Category | Technology |
|---|---|
| Programming Language | Python 3.12 |
| Backend Framework | FastAPI |
| API Server | Uvicorn |
| Testing | Pytest |
| Containerization | Docker |
| Operating System | Red Hat Enterprise Linux 10 |
| Version Control | Git |
| Source Code Hosting | GitHub |
| CI/CD | Azure DevOps Pipelines |
| Build Agent | RHEL 10 Self-Hosted Agent |
| Container Registry | Azure Container Registry |
| Container Orchestration | Kubernetes |
| Cloud Kubernetes Service | Azure Kubernetes Service (planned) |
| Container CLI | kubectl |

---

## Project Features

### 1. FastAPI Application

- Python-based backend application.
- REST API development using FastAPI.
- API documentation through Swagger UI.
- Application execution using Uvicorn.

### 2. Docker Containerization

- Dockerfile-based image creation.
- Application dependencies installed inside the container.
- Consistent application runtime environment.
- Container image tagging and publishing.

### 3. Automated Testing

- Pytest-based automated testing.
- Test execution through Azure DevOps.
- Pipeline execution stops when a test stage fails.

### 4. CI/CD Automation

- GitHub source code integration.
- Azure DevOps pipeline configuration.
- Self-hosted RHEL build agent.
- Automated Python dependency installation.
- Automated test execution.
- Docker image build and push.

### 5. Azure Container Registry

- Centralized Docker image storage.
- Version-based image tagging.
- Container image management using Azure CLI.

---

## Prerequisites

Install the following tools before running the project.

| Tool | Purpose |
|---|---|
| Python 3.12 | Application runtime |
| Git | Version control |
| Docker Engine | Containerization |
| Azure CLI | Azure resource management |
| kubectl | Kubernetes management |
| RHEL 10 or compatible Linux | Development environment |

---

## Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/OshanWanasekara/enterprise-ai-platform.git
```

Navigate into the project:

```bash
cd enterprise-ai-platform
```

### 2. Create a Python Virtual Environment

```bash
python3.12 -m venv venv
```

Activate the environment:

```bash
source venv/bin/activate
```

### 3. Upgrade pip

```bash
python -m pip install --upgrade pip
```

### 4. Install Dependencies

```bash
pip install -r requirements.txt
```

---

## Run Locally

Start the FastAPI application using Uvicorn.

```bash
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

The application will be available at:

```text
http://localhost:8000
```

FastAPI Swagger documentation:

```text
http://localhost:8000/docs
```

Alternative API documentation:

```text
http://localhost:8000/redoc
```

**Note:** This command assumes your application entry point is `app/main.py` and contains the FastAPI instance named `app`. Adjust it if your actual entry point differs.

---

## Run with Docker

### 1. Build the Docker Image

```bash
docker build -t enterprise-ai-platform:latest .
```

### 2. Verify the Docker Image

```bash
docker images
```

### 3. Run the Container

```bash
docker run -d \
  --name ai-platform \
  -p 8000:8000 \
  enterprise-ai-platform:latest
```

### 4. Check Running Containers

```bash
docker ps
```

### 5. View Container Logs

```bash
docker logs ai-platform
```

### 6. Stop the Container

```bash
docker stop ai-platform
```

### 7. Remove the Container

```bash
docker rm ai-platform
```

Access the API:

```text
http://localhost:8000/docs
```

---

## Automated Testing

The project uses Pytest for automated testing.

Run all tests:

```bash
python -m pytest -v
```

Run tests with detailed output:

```bash
python -m pytest -v -s
```

The Azure DevOps pipeline executes the automated tests before building and publishing the Docker image.

---

## Azure Container Registry

The project uses Azure Container Registry (ACR) to store Docker images.

### Registry Information

| Configuration | Value |
|---|---|
| Registry Name | `enterpriseaiplatform123` |
| Login Server | `enterpriseaiplatform123.azurecr.io` |
| Repository | `enterprise-ai-platform` |

### 1. Login to Azure

```bash
az login
```

If the browser login is unavailable:

```bash
az login --use-device-code
```

### 2. Login to ACR

```bash
az acr login --name enterpriseaiplatform123
```

### 3. Tag the Docker Image

```bash
docker tag enterprise-ai-platform:latest \
  enterpriseaiplatform123.azurecr.io/enterprise-ai-platform:latest
```

### 4. Push the Image

```bash
docker push \
  enterpriseaiplatform123.azurecr.io/enterprise-ai-platform:latest
```

### 5. Verify Published Images

```bash
az acr repository show-tags \
  --name enterpriseaiplatform123 \
  --repository enterprise-ai-platform \
  --output table
```

Previously verified image tags:

- `17`
- `latest`
- `test`

---

## CI/CD Pipeline

Azure DevOps is used to automate the application delivery process.

### Pipeline Workflow

1. Developer pushes source code to GitHub.
2. Azure DevOps detects changes in the `main` branch.
3. Pipeline runs on the RHEL 10 self-hosted agent.
4. Python environment is created.
5. Application dependencies are installed.
6. Pytest executes automated tests.
7. Docker builds the application image.
8. Docker pushes the image to Azure Container Registry.

### Self-Hosted Agent Configuration

| Configuration | Value |
|---|---|
| Agent Operating System | RHEL 10 |
| Agent Pool | `RHEL-Docker-Agents` |
| Agent Name | `rhel10-docker-agent` |
| Agent Version | `5.282.0` |

Start the agent manually:

```bash
cd ~/myagent
./run.sh
```

Keep the agent running while pipeline jobs are executing.

### Azure DevOps Pipeline YAML

The following is the pipeline configuration used in this project.

```yaml
trigger:
  - main

pool:
  name: RHEL-Docker-Agents

variables:
  imageName: enterprise-ai-platform

steps:

  # Step 1: Check build environment
  - script: |
      echo "Checking RHEL build environment..."
      python3.12 --version
      docker --version
      docker info
    displayName: 'Check RHEL and Docker environment'

  # Step 2: Install Python dependencies
  - script: |
      echo "Creating Python virtual environment..."
      python3.12 -m venv .venv

      .venv/bin/python -m pip install --upgrade pip
      .venv/bin/python -m pip install -r requirements.txt
      .venv/bin/python -m pip install pytest
    displayName: 'Install Python dependencies'

  # Step 3: Run automated tests
  - script: |
      echo "Running application tests..."
      .venv/bin/python -m pytest -v
    displayName: 'Run automated tests'

  # Step 4: Build and push Docker image
  - task: Docker@2
    displayName: 'Build and push Docker image to ACR'
    inputs:
      command: buildAndPush
      containerRegistry: 'acr-enterprise-ai-platform'
      repository: 'enterprise-ai-platform'
      Dockerfile: '$(Build.SourcesDirectory)/Dockerfile'
      buildContext: '$(Build.SourcesDirectory)'
      tags: |
        $(Build.BuildId)
        latest
```

### Required Azure DevOps Service Connection

Create a Docker Registry service connection for your ACR.

Use the following configuration:

| Field | Value |
|---|---|
| Connection name | `acr-enterprise-ai-platform` |
| Registry URL | `https://enterpriseaiplatform123.azurecr.io` |
| Authentication | Docker Registry credentials |

Do not commit passwords, tokens, or other credentials to the GitHub repository.

For production, use an appropriately scoped identity and secure authentication instead of permanent administrator credentials.

---

## Kubernetes and AKS Deployment

The next phase is to deploy the Docker container to Azure Kubernetes Service.

The intended Kubernetes configuration includes:

- Kubernetes Deployment.
- Kubernetes Service.
- Container image from Azure Container Registry.
- Application Pod management.
- External application access through a LoadBalancer Service.

### Planned Kubernetes Directory

```text
k8s/
├── deployment.yaml
└── service.yaml
```

### Planned Deployment Commands

Connect to the AKS cluster:

```bash
az aks get-credentials \
  --resource-group rg-enterprise-ai-aks \
  --name enterprise-ai-aks \
  --overwrite-existing
```

Apply Kubernetes manifests:

```bash
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

Verify deployment:

```bash
kubectl get deployments
kubectl get pods
kubectl get services
```

Check application logs:

```bash
kubectl logs deployment/enterprise-ai-platform
```

**Deployment status:** AKS deployment is planned. Cluster provisioning is currently pending resolution of the Azure subscription's allowed-region policy. The commands above are intended for use after the cluster is successfully created and configured.

---

## Environment Variables

If the application requires configuration values, define them through environment variables rather than hardcoding secrets.

Example:

```bash
export APP_ENV=development
```

For Docker:

```bash
docker run -d \
  --name ai-platform \
  -p 8000:8000 \
  -e APP_ENV=development \
  enterprise-ai-platform:latest
```

Store sensitive configuration in an appropriate secrets manager. Never commit `.env` files containing credentials.

---

## Troubleshooting

### 1. Docker Container Name Conflict

Error:

```text
The container name "/ai-platform" is already in use.
```

Solution:

```bash
docker rm -f ai-platform
```

Then run the container again.

### 2. Docker Authentication Required

Error:

```text
authentication required
```

Solution:

```bash
az acr login --name enterpriseaiplatform123
```

Check your Azure DevOps Docker Registry service connection if the error occurs inside the pipeline.

### 3. Python Version Issues

Verify Python:

```bash
python3.12 --version
```

Use the correct Python executable when creating the virtual environment:

```bash
python3.12 -m venv .venv
```

### 4. Azure Kubernetes Service Region Restriction

Error:

```text
RequestDisallowedByAzure
```

Solution:

Check the subscription's allowed locations and select a permitted region that supports AKS deployment.

```bash
az account list-locations --output table
```

Remember that subscription policy restrictions may prevent deployment even when a region is generally available in Azure.

### 5. Docker Daemon Issues

Check Docker:

```bash
sudo systemctl status docker
```

Start Docker if necessary:

```bash
sudo systemctl start docker
```

---

## Future Improvements

- Complete AKS cluster provisioning.
- Deploy the application using Kubernetes.
- Integrate AKS deployment into Azure DevOps.
- Implement automated rolling updates.
- Add Kubernetes health probes.
- Implement monitoring with Prometheus and Grafana.
- Integrate centralized logging.
- Implement Infrastructure as Code using Terraform.
- Improve secret management and container security.
- Introduce resource limits and autoscaling.

---

## Author

**WANASEKARA ARACHCHILLAYA OSHAN HAVISHKA WANASEKARA**

Information Technology Graduate

GitHub: [OshanWanasekara](https://github.com/OshanWanasekara)

Project Repository: [Enterprise AI Platform](https://github.com/OshanWanasekara/enterprise-ai-platform)

---

## License

This project is developed for educational and practical DevOps engineering purposes.

Add a LICENSE file to the repository if you intend to distribute the project under a specific open-source license.

---

**Enterprise AI Platform — Building, Testing, Containerizing and Automating Cloud Application Delivery.**
