# Deployment Guide

## Current Setup: Local Development with kind

This project is currently configured for **local development** using kind (Kubernetes in Docker).

### ⚠️ Important Limitation

The GitHub Actions workflow is **structured correctly** but cannot deploy to your local kind cluster because:
- GitHub Actions runs on GitHub's servers
- Your kind cluster runs on your local machine
- They cannot communicate with each other

### 🎯 Two Deployment Approaches

#### Option 1: Local Testing (Current Setup)
Use this for learning and development:
```bash
# 1. Create kind cluster
kind create cluster --name ephemeral-dev

# 2. Set environment variables
export PR_NUMBER="123"
export NAMESPACE="pr-123"
export IMAGE="ghcr.io/cloudlumanex/ephemeral-demo:pr-2"
export ENV_NAME="pr-123"
export BRANCH_NAME="test-branch"

# 3. Provision with Terraform
cd terraform/environments/dev
terraform init
terraform apply

# 4. Deploy application
export DB_URL=$(terraform output -raw db_connection_string)
cd ../../k8s
./deploy.sh

# 5. Test
kubectl port-forward -n pr-123 svc/demo-app 8080:80
curl http://localhost:8080/
```

#### Option 2: Cloud Deployment (Production)
To make the workflow fully functional, you need a Kubernetes cluster that GitHub Actions can access:

**Supported Options:**
- AWS EKS (Elastic Kubernetes Service)
- Google GKE (Google Kubernetes Engine)
- Azure AKS (Azure Kubernetes Service)
- DigitalOcean Kubernetes
- Any cluster with external access

**Required GitHub Secrets for Cloud:**
```
KUBE_CONFIG         # Base64 encoded kubeconfig
AWS_ACCESS_KEY_ID   # If using AWS
AWS_SECRET_KEY      # If using AWS
DB_PASSWORD         # Database password (already added)
```

**Steps to Enable Cloud Deployment:**

1. Create a Kubernetes cluster in your cloud provider
2. Get the kubeconfig file
3. Add it as a GitHub secret (base64 encoded)
4. Update the workflow to use the secret:
```yaml
- name: Configure kubectl
  run: |
    mkdir -p $HOME/.kube
    echo "${{ secrets.KUBE_CONFIG }}" | base64 -d > $HOME/.kube/config
    kubectl cluster-info
```

5. Update Terraform provider to use cloud resources (EKS, RDS, etc.)

## 🧪 Testing the Workflow

Even without cloud access, you can test that the workflow **structure** is correct:

1. Open a PR
2. Check the Actions tab
3. The workflow will:
   - ✅ Build Docker image successfully
   - ✅ Run Terraform init successfully
   - ❌ Fail at kubectl commands (expected - no cluster access)

This confirms the workflow logic is sound and ready for cloud deployment.

## 📝 Current Workflow Capabilities

What works now:
- ✅ Trigger on PR open/close
- ✅ Build and push Docker images
- ✅ Extract PR metadata
- ✅ Generate unique environment names
- ✅ Terraform configuration is correct
- ✅ Kubernetes manifests are correct
- ✅ Deployment script works locally

What needs cloud setup:
- ⏳ Terraform apply from GitHub Actions
- ⏳ Kubectl commands from GitHub Actions
- ⏳ Automatic deployments on PR open
- ⏳ Automatic cleanup on PR close

## 🚀 Next Steps

1. **For Learning:** Continue testing locally with the manual commands above
2. **For Production:** Set up a cloud Kubernetes cluster and add credentials
3. **For Portfolio:** Document both approaches in your README
