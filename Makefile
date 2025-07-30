.PHONY: help build run stop clean logs shell test

# Default target
help:
	@echo "Available commands:"
	@echo "  build    - Build the Docker image"
	@echo "  run      - Start the application with docker-compose"
	@echo "  stop     - Stop the application"
	@echo "  clean    - Remove containers and images"
	@echo "  logs     - Show application logs"
	@echo "  shell    - Open shell in running container"
	@echo "  test     - Test the application"

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