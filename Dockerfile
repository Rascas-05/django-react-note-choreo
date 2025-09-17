# Stage 1: Build the frontend with Node
FROM node:22.15.0-alpine AS builder

# Set working directory
WORKDIR /app

# Copy dependency files first (for better caching)
COPY package*.json yarn.lock* pnpm-lock.yaml* ./

# Install dependencies (pick your manager; here Yarn is enforced)
RUN npm install -g pnpm && \
    if [ -f "./package-lock.json" ]; then npm ci --only=production; \
    elif [ -f "./yarn.lock" ]; then yarn install --frozen-lockfile; \
    elif [ -f "./pnpm-lock.yaml" ]; then pnpm install --frozen-lockfile; \
    else npm install; fi

# Copy source code
COPY . .

# Build the application (Vite outputs to /app/dist)
RUN yarn build

# Stage 2: Serve with Nginx
FROM choreoanonymouspullable.azurecr.io/nginxinc/nginx-unprivileged:stable-alpine-slim

# Choreo requires UID between 10000–20000
ENV USER_NGINX=10015
ENV GROUP_NGINX=10015

# Permissions debug (optional)
ENV ENABLE_PERMISSIONS=TRUE
ENV DEBUG_PERMISSIONS=TRUE

# Copy nginx configuration
COPY --from=builder /app/default.conf /etc/nginx/conf.d/default.conf

# Copy built frontend from builder stage
COPY --from=builder /app/dist /usr/share/nginx/html/

# Switch to root just to fix ownership
USER root
RUN chown -R ${USER_NGINX}:${GROUP_NGINX} /usr/share/nginx/html/ && \
    chmod -R 755 /usr/share/nginx/html/

# ✅ Switch to secure unprivileged UID (within Choreo’s required range)
USER ${USER_NGINX}

# Expose the port (nginx-unprivileged default is 8080)
EXPOSE 8080

# Health check (30s interval, 3 retries)
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/ || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"]