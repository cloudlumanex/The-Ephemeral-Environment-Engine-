#!/bin/bash

set -e  # Exit on error

# Required environment variables
: "${PR_NUMBER:?PR_NUMBER is required}"
: "${NAMESPACE:?NAMESPACE is required}"
: "${IMAGE:?IMAGE is required}"
: "${ENV_NAME:?ENV_NAME is required}"
: "${BRANCH_NAME:?BRANCH_NAME is required}"
: "${DB_URL:?DB_URL is required}"

echo "========================================="
echo "Deploying Application to Kubernetes"
echo "========================================="
echo "PR Number: ${PR_NUMBER}"
echo "Namespace: ${NAMESPACE}"
echo "Image: ${IMAGE}"
echo "Environment: ${ENV_NAME}"
echo "Branch: ${BRANCH_NAME}"
echo "========================================="

# Create temporary directory for processed manifests
TEMP_DIR=$(mktemp -d)
trap "rm -rf ${TEMP_DIR}" EXIT

# Process deployment.yaml
echo "Processing deployment manifest..."
sed -e "s|NAMESPACE_PLACEHOLDER|${NAMESPACE}|g" \
    -e "s|PR_NUMBER_PLACEHOLDER|${PR_NUMBER}|g" \
    -e "s|IMAGE_PLACEHOLDER|${IMAGE}|g" \
    -e "s|ENV_NAME_PLACEHOLDER|${ENV_NAME}|g" \
    -e "s|BRANCH_NAME_PLACEHOLDER|${BRANCH_NAME}|g" \
    -e "s|DB_URL_PLACEHOLDER|${DB_URL}|g" \
    templates/deployment.yaml > ${TEMP_DIR}/deployment.yaml

# Process service.yaml
echo "Processing service manifest..."
sed -e "s|NAMESPACE_PLACEHOLDER|${NAMESPACE}|g" \
    -e "s|PR_NUMBER_PLACEHOLDER|${PR_NUMBER}|g" \
    templates/service.yaml > ${TEMP_DIR}/service.yaml

# Apply manifests to Kubernetes
echo "Applying manifests to Kubernetes..."
kubectl apply -f ${TEMP_DIR}/deployment.yaml
kubectl apply -f ${TEMP_DIR}/service.yaml

# Wait for deployment to be ready
echo "Waiting for deployment to be ready..."
kubectl rollout status deployment/demo-app -n ${NAMESPACE} --timeout=5m

# Show deployment status
echo ""
echo "========================================="
echo "Deployment Complete!"
echo "========================================="
kubectl get pods -n ${NAMESPACE}
kubectl get svc -n ${NAMESPACE}
echo "========================================="
