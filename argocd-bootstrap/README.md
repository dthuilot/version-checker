# ArgoCD Bootstrap for Version Checker

This directory contains the ArgoCD Application manifest to bootstrap the version-checker application using the Helm chart with ArgoCD Rollouts.

## Prerequisites

1. **ArgoCD** installed in your Kubernetes cluster
2. **ArgoCD Rollouts** controller installed in your cluster
3. **Prometheus** (optional, for advanced rollout analysis)

### Installing ArgoCD Rollouts

```bash
kubectl create namespace argo-rollouts
kubectl apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml
```

### Installing ArgoCD (if not already installed)

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

## Deployment Steps

### 1. Update Repository URL

Before applying the ArgoCD Application, update the `repoURL` in `application.yaml`:

```yaml
spec:
  source:
    repoURL: https://github.com/YOUR-ORG/version-checker.git  # Update this
```

### 2. Apply the ArgoCD Application

```bash
# Apply the application manifest
kubectl apply -f argocd-bootstrap/application.yaml

# Check the application status
kubectl get applications -n argocd

# Watch the application sync
kubectl get rollouts -n version-checker -w
```

### 3. Access the Application

```bash
# Port-forward to access the service
kubectl port-forward service/version-checker 8080:80 -n version-checker

# Or check the pods directly
kubectl get pods -n version-checker
kubectl get rollouts -n version-checker
```

## Configuration Options

### Canary Deployment (Default)

The application is configured for Canary deployments by default:

- **Progressive Traffic Shifting**: 20% → 40% → 60% → 80% → 100%
- **Automated Steps**: Some steps auto-proceed, others require manual approval
- **Risk Mitigation**: Limited blast radius during deployment
- **Analysis**: Continuous monitoring at each traffic percentage

### Blue-Green Deployment

To switch to Blue-Green deployment, update the Helm values:

```yaml
rollouts:
  strategy: blueGreen
```

### Canary Deployment Steps

The default canary configuration includes:

1. **20% Traffic**: Manual approval required
2. **40% Traffic**: Auto-proceed after 10 seconds  
3. **60% Traffic**: Auto-proceed after 10 seconds
4. **80% Traffic**: Auto-proceed after 10 seconds
5. **100% Traffic**: Full rollout complete

### Disable Rollouts

To use regular Kubernetes Deployments instead of Rollouts:

```yaml
rollouts:
  enabled: false
```

## Monitoring and Analysis

The chart includes AnalysisTemplates for:

1. **Success Rate Analysis**: Monitors HTTP success rates
2. **Response Time Analysis**: Monitors 95th percentile response times
3. **HTTP Health Check**: Simple HTTP endpoint checks

### Customizing Analysis

You can customize the analysis by modifying the values in `values.yaml`:

```yaml
rollouts:
  blueGreen:
    prePromotionAnalysis:
      templates:
      - templateName: success-rate
      args:
      - name: service-name
        value: version-checker-preview
```

## Troubleshooting

### Check Rollout Status

```bash
kubectl describe rollout version-checker -n version-checker
kubectl get replicasets -n version-checker
```

### Check ArgoCD Application

```bash
kubectl describe application version-checker -n argocd
```

### Manual Promotion (Blue-Green)

```bash
kubectl argo rollouts promote version-checker -n version-checker
```

### Rollback

```bash
kubectl argo rollouts undo version-checker -n version-checker
```

## Advanced Configuration

### Custom Analysis with Prometheus

If you have Prometheus installed, you can enable advanced metrics analysis by updating the AnalysisTemplate in the chart to use your Prometheus instance.

### Ingress Configuration

Enable ingress in the values.yaml:

```yaml
ingress:
  enabled: true
  className: "nginx"
  hosts:
    - host: version-checker.yourdomain.com
      paths:
        - path: /
          pathType: Prefix
```

### Auto-scaling

Enable HPA:

```yaml
autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 80
```