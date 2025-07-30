# Version Checker - V1

A modern, containerized web application built with nginx that displays version information with a beautiful blue gradient interface.

## 🚀 Features

- **Modern UI**: Beautiful blue gradient background with animated "V1" text
- **Responsive Design**: Works perfectly on desktop, tablet, and mobile devices
- **Security**: Built with security best practices including non-root user and security headers
- **Performance**: Optimized nginx configuration with gzip compression and caching
- **Health Checks**: Built-in health monitoring endpoints
- **Containerized**: Ready-to-deploy Docker container

## 🏗️ Architecture

- **Base Image**: nginx:alpine (lightweight and secure)
- **Web Server**: nginx with custom configuration
- **Static Content**: HTML/CSS/JavaScript with modern animations
- **Security**: Non-root user, security headers, and minimal attack surface

## 📋 Prerequisites

- Docker
- Docker Compose
- Make (optional, for convenience commands)

## 🚀 Quick Start

### Using Docker Compose (Recommended)

```bash
# Build and start the application
make build
make run

# Or use docker-compose directly
docker-compose up -d
```

### Using Docker directly

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

# Build the Docker image
make build

# Start the application
make run

# Stop the application
make stop

# View logs
make logs

# Test the application
make test

# Clean up containers and images
make clean

# Open shell in running container
make shell
```

### Project Structure

```
version-checker/
├── Dockerfile              # Multi-stage Docker build
├── docker-compose.yml      # Docker Compose configuration
├── nginx.conf             # Custom nginx configuration
├── html/
│   └── index.html         # Main application page
├── .dockerignore          # Docker build context exclusions
├── .gitignore            # Git exclusions
├── Makefile              # Development convenience commands
└── README.md             # This file
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

- **Security headers**: X-Frame-Options, X-XSS-Protection, etc.
- **Minimal base image**: Alpine Linux for reduced attack surface
- **Health checks**: Built-in monitoring for container health

## 📊 Monitoring

### Health Check Endpoint

The application provides a health check endpoint at `/health` that returns a simple "healthy" response.

### Logs

Access logs are available through:
```bash
# Docker Compose
docker-compose logs -f

# Direct Docker
docker logs -f version-checker
```

## 🧪 Testing

Run the built-in tests:
```bash
make test
```

This will:
1. Check the health endpoint
2. Verify the main page loads correctly

## 🚀 Deployment

### Production Deployment

1. Build the production image:
   ```bash
   docker build -t version-checker:latest .
   ```

2. Deploy with your preferred orchestration tool (Kubernetes, Docker Swarm, etc.)

### Docker Registry

To push to a registry:
```bash
# Tag for your registry
docker tag version-checker:latest your-registry/version-checker:v1

# Push to registry
docker push your-registry/version-checker:v1
```

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
