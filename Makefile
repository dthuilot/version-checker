.PHONY: help build run stop clean logs shell test helm-install helm-uninstall helm-upgrade helm-status helm-test helm-lint helm-package

# Default target
help:
	@echo "Available commands:"
	@echo "  build         - Build the Docker image"
	@echo "  run           - Start the application with docker-compose"
	@echo "  stop          - Stop the application"
	@echo "  clean         - Remove containers and images"
	@echo "  logs          - Show application logs"
	@echo "  shell         - Open shell in running container"
	@echo "  test          - Test the application"
	@echo ""
	@echo "Helm commands:"
	@echo "  helm-install  - Install the Helm chart"
	@echo "  helm-uninstall- Uninstall the Helm chart"
	@echo "  helm-upgrade  - Upgrade the Helm chart"
	@echo "  helm-status   - Check Helm deployment status"
	@echo "  helm-test     - Test Helm deployment"
	@echo "  helm-lint     - Lint the Helm chart"
	@echo "  helm-package  - Package the Helm chart"

# Build the Docker image
build:
	docker-compose build

# Start the application
run:
	docker-compose up -d

# Stop the application
stop:
	docker-compose down

# Clean up containers and images
clean:
	docker-compose down --rmi all --volumes --remove-orphans
	docker system prune -f

# Show logs
logs:
	docker-compose logs -f

# Open shell in container
shell:
	docker-compose exec version-checker sh

# Test the application
test:
	@echo "Testing application..."
	@curl -f http://localhost:8080/health || (echo "Health check failed" && exit 1)
	@curl -f http://localhost:8080/ || (echo "Main page check failed" && exit 1)
	@echo "All tests passed!"

# Development commands
dev-build:
	docker build -t version-checker:dev .

dev-run:
	docker run -d -p 8080:80 --name version-checker-dev version-checker:dev

dev-stop:
	docker stop version-checker-dev && docker rm version-checker-dev 

# Helm commands
helm-lint:
	@echo "Linting Helm chart..."
	helm lint helm-chart/version-checker

helm-package:
	@echo "Packaging Helm chart..."
	helm package helm-chart/version-checker

helm-install: helm-lint
	@echo "Installing Helm chart..."
	helm install version-checker helm-chart/version-checker \
		--create-namespace \
		--namespace version-checker \
		--set image.tag=latest

helm-upgrade: helm-lint
	@echo "Upgrading Helm chart..."
	helm upgrade version-checker helm-chart/version-checker \
		--namespace version-checker \
		--set image.tag=latest

helm-uninstall:
	@echo "Uninstalling Helm chart..."
	helm uninstall version-checker --namespace version-checker

helm-status:
	@echo "Helm deployment status:"
	helm status version-checker --namespace version-checker
	@echo ""
	@echo "Kubernetes resources:"
	kubectl get all -n version-checker

helm-test:
	@echo "Testing Helm deployment..."
	@kubectl wait --for=condition=available --timeout=300s deployment/version-checker -n version-checker || \
	 kubectl wait --for=condition=progressing --timeout=300s rollout/version-checker -n version-checker
	@echo "Testing health endpoint..."
	kubectl port-forward service/version-checker 8080:80 -n version-checker &
	@sleep 5
	@curl -f http://localhost:8080/health || (echo "Health check failed" && exit 1)
	@curl -f http://localhost:8080/ || (echo "Main page check failed" && exit 1)
	@pkill -f "kubectl port-forward" || true
	@echo "Helm deployment tests passed!"

# ArgoCD commands
argocd-install:
	@echo "Installing ArgoCD application..."
	kubectl apply -f argocd-bootstrap/application.yaml

argocd-status:
	@echo "ArgoCD application status:"
	kubectl get application version-checker -n argocd
	@echo ""
	@echo "Rollout status:"
	kubectl get rollouts -n version-checker