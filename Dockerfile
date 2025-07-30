# Multi-stage build for optimized production image
FROM nginx:alpine AS base

# Install necessary packages
RUN apk add --no-cache \
    curl \
    && rm -rf /var/cache/apk/*

# Use existing nginx user for security (already exists in base image)

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Copy static files
COPY html/ /usr/share/nginx/html/

# Set proper permissions
RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chmod -R 755 /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

# Start nginx (runs as root by default, which is standard for nginx containers)
CMD ["nginx", "-g", "daemon off;"] 