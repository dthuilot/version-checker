# Version Checker - Helm Deployment with ArgoCD Rollouts

This project now includes comprehensive Helm chart support with ArgoCD Rollouts for advanced deployment strategies.

## 📁 Project Structure

```
version-checker/
├── docker-compose.yml          # Original Docker Compose setup
├── Dockerfile                  # Container image definition
├── Makefile                   # Build and deployment automation
├── nginx.conf                 # Nginx configuration
├── html/                      # Static web content
│   └── index.html
├── helm-chart/                # 🆕 Helm chart for Kubernetes deployment
│   └── version-checker/
│       ├── Chart.yaml         # Chart metadata
│       ├── values.yaml        # Default configuration values
│       ├── README.md          # Chart documentation
│       └── templates/         # Kubernetes manifests
│           ├── _helpers.tpl   # Helper templates
│           ├── rollout.yaml   # ArgoCD Rollout (Blue-Green/Canary)
│           ├── service.yaml   # Kubernetes Service
│           ├── configmap.yaml # Nginx configuration
│           ├── serviceaccount.yaml
│           ├── analysistemplate.yaml # Rollout analysis
│           ├── ingress.yaml   # Ingress configuration
│           └── hpa.yaml       # Horizontal Pod Autoscaler
└── argocd-bootstrap/          # 🆕 ArgoCD Application setup
    ├── application.yaml       # ArgoCD Application manifest
    └── README.md              # Bootstrap instructions
```

## 🚀 Quick Start

### Option 1: Traditional Docker Deployment

```bash
# Build and run with Docker Compose
make build
make run

# Test the application
make test
```

### Option 2: Kubernetes with Helm

```bash
# Build the Docker image
make build

# Install with Helm (requires Kubernetes cluster)
make helm-install

# Check deployment status
make helm-status

# Test the Kubernetes deployment
make helm-test
```

### Option 3: ArgoCD with Rollouts (Recommended for Production)

1. **Setup Prerequisites**:
   ```bash
   # Install ArgoCD Rollouts
   kubectl create namespace argo-rollouts
   kubectl apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml
   ```

2. **Deploy with ArgoCD**:
   ```bash
   # Update the repository URL in argocd-bootstrap/application.yaml
   # Then apply the ArgoCD application
   kubectl apply -f argocd-bootstrap/application.yaml
   ```

## 🔄 Deployment Strategies

### Blue-Green Deployment (Default)

- **Zero Downtime**: New version deployed alongside current version
- **Manual Promotion**: Requires manual approval to switch traffic
- **Instant Rollback**: Quick switch back to previous version
- **Analysis**: Automated health checks before promotion

```yaml
rollouts:
  strategy: blueGreen
  blueGreen:
    autoPromotionEnabled: false  # Manual approval required
    scaleDownDelaySeconds: 30
```

### Canary Deployment

- **Gradual Rollout**: Traffic slowly shifted to new version
- **Risk Mitigation**: Limited blast radius during deployment
- **Progressive Analysis**: Continuous monitoring at each step

```yaml
rollouts:
  strategy: canary
  canary:
    steps:
    - setWeight: 20    # 20% traffic to new version
    - pause: {}        # Manual approval
    - setWeight: 40    # 40% traffic to new version
    - pause: {duration: 10}  # Auto-proceed after 10s
```

## 📊 Monitoring and Analysis

The Helm chart includes automated analysis templates:

### Success Rate Analysis
- Monitors HTTP response codes
- Prometheus-based metrics collection
- Configurable success thresholds

### Response Time Analysis
- Tracks 95th percentile response times
- Performance regression detection
- Automated rollback on degradation

### Health Check Analysis
- Simple HTTP endpoint validation
- Works without external monitoring systems
- Immediate failure detection

## 🛠️ Development Workflow

### 1. Local Development
```bash
# Start local development environment
make run

# Test changes
make test

# View logs
make logs
```

### 2. Build and Test
```bash
# Build new image version
make build

# Test with Helm locally
make helm-install

# Run tests against Kubernetes deployment
make helm-test
```

### 3. Deploy to Production
```bash
# Update image tag in ArgoCD
kubectl patch application version-checker -n argocd --type='json' \
  -p='[{"op": "replace", "path": "/spec/source/helm/parameters/0/value", "value": "v1.1.0"}]'

# Monitor rollout progress
kubectl get rollouts -n version-checker -w

# Promote when ready (Blue-Green)
kubectl argo rollouts promote version-checker -n version-checker
```

## 🔧 Configuration

### Helm Values

Key configuration options in `helm-chart/version-checker/values.yaml`:

```yaml
# Replica configuration
replicaCount: 3

# Image configuration
image:
  repository: version-checker
  tag: "1.0.0"

# Rollout strategy
rollouts:
  enabled: true
  strategy: blueGreen  # or canary

# Resource limits
resources:
  limits:
    cpu: 100m
    memory: 128Mi
  requests:
    cpu: 50m
    memory: 64Mi

# Auto-scaling
autoscaling:
  enabled: false
  minReplicas: 2
  maxReplicas: 10
```

### ArgoCD Application

Configure in `argocd-bootstrap/application.yaml`:

```yaml
spec:
  source:
    repoURL: https://github.com/your-org/version-checker.git
    targetRevision: helm-argocd-rollouts
    helm:
      parameters:
        - name: image.tag
          value: "1.0.0"
        - name: rollouts.strategy
          value: "blueGreen"
```

## 🔒 Security Features

- **Non-root containers**: Runs as nginx user (UID 101)
- **Read-only filesystem**: Minimal attack surface
- **Security contexts**: Dropped capabilities
- **Service accounts**: Minimal RBAC permissions
- **Security headers**: XSS protection, CSRF prevention

## 📈 Scaling and Performance

### Horizontal Pod Autoscaling
```yaml
autoscaling:
  enabled: true
  targetCPUUtilizationPercentage: 80
  targetMemoryUtilizationPercentage: 80
```

### Resource Optimization
- **CPU**: 50m request, 100m limit
- **Memory**: 64Mi request, 128Mi limit
- **Nginx**: Optimized for static content serving

## 🆘 Troubleshooting

### Common Issues

1. **Rollout Stuck**:
   ```bash
   kubectl describe rollout version-checker -n version-checker
   kubectl argo rollouts abort version-checker -n version-checker
   ```

2. **Analysis Failing**:
   ```bash
   kubectl get analysisruns -n version-checker
   kubectl describe analysisrun <analysis-run-name> -n version-checker
   ```

3. **ArgoCD Sync Issues**:
   ```bash
   kubectl get application version-checker -n argocd -o yaml
   kubectl describe application version-checker -n argocd
   ```

### Debug Commands

```bash
# Check all resources
kubectl get all -n version-checker

# View rollout status
kubectl get rollouts -n version-checker

# Check pod logs
kubectl logs -l app.kubernetes.io/name=version-checker -n version-checker

# Port forward for testing
kubectl port-forward service/version-checker 8080:80 -n version-checker
```

## 🎯 Next Steps

1. **Customize Analysis**: Add custom metrics and analysis templates
2. **Enable Ingress**: Configure external access with TLS
3. **Add Monitoring**: Integrate with Prometheus and Grafana
4. **Setup Alerts**: Configure notifications for deployment failures
5. **Multi-Environment**: Create separate ArgoCD applications for dev/staging/prod

For detailed documentation, see:
- [Helm Chart README](helm-chart/version-checker/README.md)
- [ArgoCD Bootstrap README](argocd-bootstrap/README.md)