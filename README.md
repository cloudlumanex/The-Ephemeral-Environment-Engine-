# The Ephemeral Environment Engine

A fully automated system that creates isolated preview environments for every Pull Request, complete with dedicated databases, unique URLs, and automatic cleanup.

## 🎯 Project Overview

Every time a developer opens a Pull Request, this system automatically:
- Builds a Docker image from the PR code
- Provisions an isolated PostgreSQL database
- Deploys the application to Kubernetes
- Generates a unique URL (e.g., `pr-123.myapp.com`)
- Configures SSL certificates
- Seeds the database with test data

When the PR is closed or merged, everything is automatically destroyed to save costs.

## 🏗️ Architecture
```
┌─────────────────────────────────────────────────────────────┐
│  Developer Opens PR                                         │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│  GitHub Actions Workflow Triggers                           │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ├──► Build Docker Image (tagged with PR number)
                 │
                 ├──► Terraform Provisions Infrastructure
                 │    ├─ Kubernetes Namespace (pr-123)
                 │    ├─ PostgreSQL Database
                 │    └─ Database Credentials
                 │
                 ├──► Deploy Application to K8s
                 │    ├─ Connect to Database
                 │    └─ Expose via Service
                 │
                 ├──► Configure DNS & SSL
                 │    └─ Generate pr-123.myapp.com
                 │
                 └──► Seed Database with Test Data
                      └─ Anonymized production-like data
```

## 🛠️ Technology Stack

- **CI/CD:** GitHub Actions
- **Containerization:** Docker
- **Container Registry:** GitHub Container Registry (ghcr.io)
- **Infrastructure as Code:** Terraform
- **Orchestration:** Kubernetes (kind for local development)
- **Database:** PostgreSQL 15
- **Application:** Node.js + Express (demo app)
- **Ingress:** Nginx Ingress Controller (planned)
- **SSL Certificates:** cert-manager + Let's Encrypt (planned)

## 📁 Project Structure
```
.
├── .github/
│   └── workflows/
│       └── preview-environment.yml    # Main CI/CD workflow
├── demo-app/
│   ├── server.js                      # Node.js demo application
│   ├── package.json
│   └── Dockerfile                     # Container definition
├── terraform/
│   ├── modules/
│   │   └── preview-env/               # Reusable Terraform module
│   │       ├── main.tf                # K8s resources (namespace, DB, service)
│   │       ├── variables.tf           # Input variables
│   │       └── outputs.tf             # Outputs (DB connection, etc.)
│   └── environments/
│       └── dev/                       # Development environment config
│           ├── main.tf                # Calls the module
│           └── variables.tf           # Environment variables
└── README.md
```

## 🚀 Getting Started

### Prerequisites

- Docker Desktop (or Docker Engine)
- kubectl (`v1.28+`)
- kind (`v0.20+`)
- Terraform (`v1.13+`)
- Git
- GitHub account

### Local Setup

1. **Clone the repository:**
```bash
   git clone https://github.com/cloudlumanex/The-Ephemeral-Environment-Engine-.git
   cd The-Ephemeral-Environment-Engine-
```

2. **Create a kind cluster:**
```bash
   kind create cluster --name ephemeral-dev
```

3. **Verify cluster is running:**
```bash
   kubectl cluster-info --context kind-ephemeral-dev
   kubectl get nodes
```

4. **Test Terraform locally:**
```bash
   cd terraform/environments/dev
   
   # Create a test variables file
   cat > terraform.tfvars << EOF
   pr_number        = "999"
   environment_name = "pr-999"
   namespace        = "pr-999"
   db_password      = "testpassword123"
   EOF
   
   # Initialize and apply
   terraform init
   terraform plan
   terraform apply
```

5. **Verify the environment:**
```bash
   # Check namespace
   kubectl get namespace pr-999
   
   # Check all resources
   kubectl get all -n pr-999
   
   # Test database connection
   kubectl exec -it -n pr-999 $(kubectl get pod -n pr-999 -l app=postgres -o jsonpath='{.items[0].metadata.name}') -- psql -U previewuser -d previewdb
```

6. **Cleanup:**
```bash
   terraform destroy
```

## 🔧 How It Works

### 1. Pull Request Opened

When a PR is opened, the GitHub Actions workflow:
- Checks out the PR code
- Builds a Docker image tagged with `pr-<number>`
- Pushes the image to GitHub Container Registry
- Runs Terraform to provision:
  - Kubernetes namespace
  - PostgreSQL database
  - Database credentials (K8s Secret)
  - Service to expose the database

### 2. Pull Request Closed

When a PR is closed or merged:
- Terraform destroys all provisioned resources
- Kubernetes namespace is deleted
- Database and all data are removed
- Docker images remain in the registry (optional cleanup)

## 📊 Current Status

### ✅ Completed
- [x] GitHub Actions workflow (provision & teardown)
- [x] Docker image building and pushing
- [x] Terraform infrastructure provisioning
- [x] PostgreSQL database isolation per PR
- [x] Local testing with kind cluster

### 🚧 In Progress
- [ ] Kubernetes application deployment
- [ ] Ingress configuration for unique URLs
- [ ] SSL certificate automation (cert-manager)
- [ ] Database seeding scripts
- [ ] TTL/Reaper script for idle environments

### 📋 Planned
- [ ] Multi-environment support (staging, production)
- [ ] Cost tracking and reporting
- [ ] Slack/Discord notifications
- [ ] Performance metrics collection
- [ ] Migration to cloud Kubernetes (EKS/GKE/AKS)

## 🔐 Security Considerations

- Database credentials are stored as Kubernetes Secrets
- Sensitive Terraform state files are gitignored
- Docker images use official base images
- PostgreSQL uses least-privilege user accounts
- Network policies can be added for additional isolation

## 💰 Cost Optimization

- **Local Development:** Free (kind cluster on your laptop)
- **Cloud Deployment:** Costs vary by provider
  - Use smallest instance types (t3.micro, f1-micro)
  - Implement TTL to auto-delete idle environments
  - Use spot/preemptible instances where possible
  - Monitor and set budget alerts

## 🤝 Contributing

This is a learning project. Feel free to:
- Open issues for bugs or suggestions
- Submit PRs with improvements
- Fork and adapt for your own use

## 📝 License

MIT License - feel free to use this project for learning or production.

## 🙏 Acknowledgments

- Built as a DevOps learning project
- Inspired by modern CI/CD best practices
- Thanks to the Kubernetes, Terraform, and GitHub Actions communities

## 📧 Contact

**Author:** Emmanuel Nnanna Ulu  
**GitHub:** [@cloudlumanex](https://github.com/cloudlumanex)  
**Project:** [The Ephemeral Environment Engine](https://github.com/cloudlumanex/The-Ephemeral-Environment-Engine-)

---

**⭐ If this project helped you learn, please consider giving it a star!**