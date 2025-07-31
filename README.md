# Version Checker - V1

A modern, containerized web application built with nginx that displays version information with a beautiful blue gradient interface. Now featuring **enterprise-grade Kubernetes deployment** with Helm charts and ArgoCD rollouts.

## 🚀 Features

### Core Application
- **Modern UI**: Beautiful blue gradient background with animated "V1" text
- **Responsive Design**: Works perfectly on desktop, tablet, and mobile devices
- **Security**: Built with security best practices including non-root user and security headers
- **Performance**: Optimized nginx configuration with gzip compression and caching
- **Health Checks**: Built-in health monitoring endpoints (`/health`)
- **Favicon Support**: Proper favicon handling to prevent 404 errors

### Enterprise Deployment (NEW!)
- **Helm Charts**: Production-ready Kubernetes deployment with Helm 3
- **ArgoCD Rollouts**: Blue-Green and Canary deployment strategies
- **GitOps Workflow**: Complete ArgoCD integration for continuous deployment
- **Auto-scaling**: Horizontal Pod Autoscaling support
- **Analysis Templates**: Automated rollout analysis and health checks
- **Ingress Support**: External access configuration with TLS
- **Monitoring Integration**: Prometheus-compatible metrics and analysis

## 🏗️ Architecture

- **Base Image**: nginx:alpine (lightweight and secure)
- **Web Server**: nginx with custom configuration
- **Static Content**: HTML/CSS/JavaScript with modern animations
- **Security**: Non-root user, security headers, and minimal attack surface

## 📋 Prerequisites

### For Docker Deployment
- Docker
- Docker Compose
- Make (optional, for convenience commands)

### For Kubernetes Deployment (NEW!)
- Kubernetes cluster (1.19+)
- Helm 3.2.0+
- ArgoCD (for GitOps deployment)
- ArgoCD Rollouts controller (for advanced deployments)

## 🚀 Quick Start

### Option 1: Docker Compose (Simple)

```bash
# Build and start the application
make build
make run

# Test the application
make test
```

### Option 2: Kubernetes with Helm (Recommended for Production)

```bash
# Install with Helm
make helm-install

# Check deployment status
make helm-status

# Test Kubernetes deployment
make helm-test
```

### Option 3: ArgoCD GitOps (Enterprise)

```bash
# Deploy with ArgoCD (after updating repository URL)
make argocd-install

# Monitor rollout progress
kubectl get rollouts -n version-checker -w
```

### Option 4: Docker Direct

```bash
# Build the image
docker build -t version-checker:v1 .

# Run the container
docker run -d -p 8080:80 --name version-checker version-checker:v1
```

## 🌐 Access the Application

Once running, access the application at:
- **Main Page**: http://localhost:8080
- **Health Check**: http://localhost:8080/health

## 🛠️ Development

### Available Commands

```bash
# Show all available commands
make help

# Docker commands
make build           # Build the Docker image
make run             # Start the application
make stop            # Stop the application
make logs            # View logs
make test            # Test the application
make clean           # Clean up containers and images
make shell           # Open shell in running container

# Helm commands (NEW!)
make helm-install    # Install the Helm chart
make helm-uninstall  # Uninstall the Helm chart
make helm-upgrade    # Upgrade the Helm chart
make helm-status     # Check Helm deployment status
make helm-test       # Test Helm deployment
make helm-lint       # Lint the Helm chart
make helm-package    # Package the Helm chart

# ArgoCD commands (NEW!)
make argocd-install  # Install ArgoCD application
make argocd-status   # Check ArgoCD application status
```

### Project Structure

```
version-checker/
├── .github/
│   └── workflows/
│       └── docker-publish.yml     # GitHub Actions CI/CD
├── argocd-bootstrap/               # 🆕 ArgoCD GitOps setup
│   ├── README.md                   # ArgoCD bootstrap guide
│   └── application.yaml            # ArgoCD Application manifest
├── helm-chart/                     # 🆕 Kubernetes Helm chart
│   └── version-checker/
│       ├── templates/              # Kubernetes manifests
│       │   ├── _helpers.tpl        # Helm template helpers
│       │   ├── analysistemplate.yaml # Rollout analysis
│       │   ├── configmap.yaml      # Nginx configuration
│       │   ├── hpa.yaml            # Horizontal Pod Autoscaler
│       │   ├── ingress.yaml        # Ingress configuration
│       │   ├── rollout.yaml        # ArgoCD Rollout (Canary/Blue-Green)
│       │   ├── service.yaml        # Kubernetes Service
│       │   └── serviceaccount.yaml # Service Account
│       ├── Chart.yaml              # Chart metadata
│       ├── README.md               # Chart documentation
│       └── values.yaml             # Configuration values
├── html/                           # Static web content
│   ├── favicon.ico                 # Favicon file (prevents 404s)
│   └── index.html                  # Main application page
├── .gitignore                      # Git exclusions
├── Dockerfile                      # Multi-stage Docker build
├── HELM_DEPLOYMENT.md              # 🆕 Comprehensive deployment guide
├── Makefile                        # Development & deployment commands
├── README.md                       # This file
├── docker-compose.yml              # Docker Compose configuration
└── nginx.conf                      # Custom nginx configuration
```

## 🔧 Configuration

### Environment Variables

- `NGINX_ENV`: Set to `production` for production deployment

### Port Configuration

The application runs on port 80 inside the container and is mapped to port 8080 on the host by default. You can change this in `docker-compose.yml`:

```yaml
ports:
  - "YOUR_PORT:80"
```

## 🔒 Security Features

### Application Security
- **Security headers**: X-Frame-Options, X-XSS-Protection, Content-Security-Policy
- **Minimal base image**: Alpine Linux for reduced attack surface
- **Non-root execution**: Containers run as nginx user (UID 101)
- **Health checks**: Built-in monitoring for container health
- **Favicon handling**: Prevents 404 errors and log noise

### Kubernetes Security (Helm Chart)
- **Security contexts**: Dropped capabilities and read-only root filesystem options
- **Service accounts**: Minimal RBAC permissions
- **Pod security**: Non-root containers with security context enforcement
- **Network policies**: Ready for network segmentation (can be enabled)
- **Resource limits**: CPU and memory constraints to prevent resource exhaustion

## 📊 Monitoring

### Health Check Endpoints

- **Health Check**: `/health` - Returns simple "healthy" response
- **Favicon**: `/favicon.ico` - Properly cached favicon to prevent 404s

### Docker Logs

```bash
# Docker Compose
make logs
docker-compose logs -f

# Direct Docker
docker logs -f version-checker
```

### Kubernetes Monitoring (Helm Chart)

```bash
# Check deployment status
make helm-status
kubectl get all -n version-checker

# View pod logs
kubectl logs -l app.kubernetes.io/name=version-checker -n version-checker

# Monitor rollout progress (with ArgoCD Rollouts)
kubectl argo rollouts get rollout version-checker -n version-checker --watch
```

### Analysis Templates (ArgoCD Rollouts)

The Helm chart includes automated analysis templates for:
- **Success Rate Analysis**: HTTP response code monitoring
- **Response Time Analysis**: 95th percentile latency tracking  
- **Health Check Analysis**: Simple endpoint validation

### Prometheus Integration

The chart supports Prometheus metrics collection for advanced monitoring and analysis during rollouts.

## 🧪 Testing

### Docker Testing
```bash
# Run built-in tests
make test

# This will:
# 1. Check the health endpoint
# 2. Verify the main page loads correctly
# 3. Test favicon accessibility
```

### Kubernetes Testing  
```bash
# Test Helm deployment
make helm-test

# Manual testing
kubectl port-forward service/version-checker 8080:80 -n version-checker
curl http://localhost:8080/health
curl http://localhost:8080/favicon.ico
```

### ArgoCD Rollout Testing
```bash
# Test canary deployments
kubectl argo rollouts set image version-checker version-checker=version-checker:v1.1.0 -n version-checker

# Monitor analysis
kubectl get analysisruns -n version-checker

# Promote if healthy
kubectl argo rollouts promote version-checker -n version-checker
```

## 🚀 Deployment

### Traditional Docker Deployment

1. Build the production image:
   ```bash
   docker build -t version-checker:latest .
   ```

2. Push to registry:
   ```bash
   # Tag for your registry
   docker tag version-checker:latest your-registry/version-checker:v1
   
   # Push to registry
   docker push your-registry/version-checker:v1
   ```

### Kubernetes Deployment with Helm (Recommended)

1. **Install the Helm chart**:
   ```bash
   # Install with default values
   make helm-install
   
   # Or install with custom values
   helm install version-checker ./helm-chart/version-checker -f custom-values.yaml
   ```

2. **Configure for your environment**:
   ```bash
   # Enable ingress
   helm upgrade version-checker ./helm-chart/version-checker \
     --set ingress.enabled=true \
     --set ingress.hosts[0].host=version-checker.yourdomain.com
   
   # Enable auto-scaling
   helm upgrade version-checker ./helm-chart/version-checker \
     --set autoscaling.enabled=true \
     --set autoscaling.maxReplicas=10
   ```

### ArgoCD GitOps Deployment (Enterprise)

1. **Setup ArgoCD and Rollouts**:
   ```bash
   # Install ArgoCD Rollouts
   kubectl create namespace argo-rollouts
   kubectl apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml
   ```

2. **Deploy with ArgoCD**:
   ```bash
   # Update repository URL in argocd-bootstrap/application.yaml
   # Then apply the ArgoCD application
   kubectl apply -f argocd-bootstrap/application.yaml
   ```

3. **Monitor deployments**:
   ```bash
   # Check rollout status
   kubectl argo rollouts get rollout version-checker -n version-checker
   
   # Promote canary deployment
   kubectl argo rollouts promote version-checker -n version-checker
   ```

### Deployment Strategies Available

- **Canary Deployment** (Default): Progressive traffic shifting (20% → 40% → 60% → 80% → 100%)
- **Blue-Green Deployment**: Zero-downtime deployments with manual promotion
- **Regular Deployment**: Standard Kubernetes deployment without rollouts

For detailed deployment documentation, see **[HELM_DEPLOYMENT.md](HELM_DEPLOYMENT.md)**.

## 🔄 Version Management

This project is designed for version checking and can be easily extended to support multiple versions by:
1. Creating different branches for each version
2. Using different Docker tags
3. Implementing version routing logic

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For issues and questions:
1. Check the logs: `make logs`
2. Verify the container is running: `docker ps`
3. Test the endpoints: `make test`
4. Open an issue in the repository

---

**Built with ❤️ by the DevOps Team**
