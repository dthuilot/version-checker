# Version Checker Helm Chart

A Helm chart for deploying the Version Checker application with ArgoCD Rollouts support.

## Features

- **ArgoCD Rollouts**: Support for Blue-Green and Canary deployments
- **Health Checks**: Built-in liveness and readiness probes
- **Analysis Templates**: Automated rollout analysis and validation
- **Security**: Non-root containers with security contexts
- **Monitoring**: Prometheus-compatible metrics and analysis
- **Scalability**: Horizontal Pod Autoscaling support

## Installation

### Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- ArgoCD Rollouts controller (for rollout features)

### Installing the Chart

```bash
# Add your helm repository (if using a helm repository)
helm repo add your-repo https://your-helm-repo.com

# Install the chart
helm install version-checker ./helm-chart/version-checker

# Or install with custom values
helm install version-checker ./helm-chart/version-checker -f custom-values.yaml
```

### Uninstalling the Chart

```bash
helm uninstall version-checker
```

## Configuration

The following table lists the configurable parameters and their default values.

### Basic Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of replicas | `3` |
| `image.repository` | Image repository | `version-checker` |
| `image.tag` | Image tag | `latest` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |

### Rollouts Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `rollouts.enabled` | Enable ArgoCD Rollouts | `true` |
| `rollouts.strategy` | Rollout strategy (blueGreen/canary) | `blueGreen` |
| `rollouts.blueGreen.autoPromotionEnabled` | Auto-promote blue-green deployments | `false` |
| `rollouts.blueGreen.scaleDownDelaySeconds` | Delay before scaling down old version | `30` |

### Service Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `service.type` | Service type | `ClusterIP` |
| `service.port` | Service port | `80` |
| `service.targetPort` | Container target port | `80` |

### Ingress Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `ingress.enabled` | Enable ingress | `false` |
| `ingress.className` | Ingress class name | `""` |
| `ingress.hosts` | Ingress hosts configuration | `[]` |

### Health Check Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `healthCheck.enabled` | Enable health checks | `true` |
| `healthCheck.path` | Health check path | `/health` |
| `healthCheck.initialDelaySeconds` | Initial delay for health checks | `30` |

## Examples

### Blue-Green Deployment

```yaml
rollouts:
  enabled: true
  strategy: blueGreen
  blueGreen:
    autoPromotionEnabled: false
    scaleDownDelaySeconds: 30
    prePromotionAnalysis:
      templates:
      - templateName: success-rate
      args:
      - name: service-name
        value: version-checker-preview
```

### Canary Deployment

```yaml
rollouts:
  enabled: true
  strategy: canary
  canary:
    replicas: "30%"
    maxUnavailable: 1
    maxSurge: "25%"
    steps:
    - setWeight: 20
    - pause: {}
    - setWeight: 40
    - pause: {duration: 10}
    - setWeight: 60
    - pause: {duration: 10}
    - setWeight: 80
    - pause: {duration: 10}
```

### With Ingress

```yaml
ingress:
  enabled: true
  className: "nginx"
  annotations:
    kubernetes.io/tls-acme: "true"
  hosts:
    - host: version-checker.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: version-checker-tls
      hosts:
        - version-checker.example.com
```

### With Auto-scaling

```yaml
autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 80
  targetMemoryUtilizationPercentage: 80
```

## Monitoring and Analysis

The chart includes several AnalysisTemplates:

1. **success-rate**: Monitors HTTP success rates using Prometheus
2. **http-success-rate**: Simple HTTP endpoint health checks

### Custom Analysis

You can create custom analysis templates by adding them to the `templates/` directory:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: AnalysisTemplate
metadata:
  name: custom-analysis
spec:
  metrics:
  - name: custom-metric
    provider:
      # Your custom analysis configuration
```

## Security

The chart follows security best practices:

- Non-root containers
- Read-only root filesystem options
- Security contexts with dropped capabilities
- Service account with minimal permissions

## Troubleshooting

### Common Issues

1. **Rollout stuck in progressing state**:
   ```bash
   kubectl describe rollout version-checker
   kubectl logs -l app.kubernetes.io/name=version-checker
   ```

2. **Analysis failing**:
   ```bash
   kubectl describe analysisrun -l rollout=version-checker
   ```

3. **Health checks failing**:
   ```bash
   kubectl describe pod -l app.kubernetes.io/name=version-checker
   ```

### Debug Commands

```bash
# Check rollout status
kubectl get rollouts

# Check analysis runs
kubectl get analysisruns

# Check services
kubectl get services

# Check pods
kubectl get pods -l app.kubernetes.io/name=version-checker
```