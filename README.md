# Cloud-Native Backend Deployment on Microsoft Azure

Production-ready containerized web application deployed on Azure with CI/CD automation.

##  Architecture

- **Azure App Service** - Web App hosting
- **Azure Container Registry** - Docker image storage
- **GitHub Actions** - CI/CD automation
- **Managed Identity** - Secure authentication
- **Azure Key Vault** - Secret management
- **Virtual Network** - Network isolation

##  Key Features

- Automated Docker image build and deployment
- Secure resource access without credentials (Managed Identity)
- Private network communication (VNet + Private Endpoints)
- Container logging and monitoring

##  Technologies

- Azure (App Service, ACR, Key Vault, VNet)
- Docker
- GitHub Actions
- Python/Flask
- Azure CLI

## Deployment Workflow
1. Code pushed to GitHub
2. GitHub Actions builds Docker image
3. Image pushed to Azure Container Registry
4. Azure App Service pulls latest image
5. Application deployed automatically
