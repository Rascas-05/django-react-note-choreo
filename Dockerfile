### Stage 1: Build Vite frontend
FROM node:22-alpine AS builder

WORKDIR /app/frontend

# Install pnpm in case some deps use it
RUN npm install -g pnpm

# Copy only frontend sources (keeps image smaller)
COPY frontend/ ./

# Install deps (lockfile aware)
RUN if [ -f "package-lock.json" ]; then npm ci; \
    elif [ -f "yarn.lock" ]; then yarn install --frozen-lockfile; \
    elif [ -f "pnpm-lock.yaml" ]; then pnpm install --frozen-lockfile; \
    fi

# Build for production (Vite → dist/)
RUN yarn build || npm run build || pnpm build

### Stage 2: Serve with nginx
FROM choreoanonymouspullable.azurecr.io/nginxinc/nginx-unprivileged:stable-alpine-slim

ENV ENABLE_PERMISSIONS=TRUE
ENV DEBUG_PERMISSIONS=TRUE
ENV USER_NGINX=10015
ENV GROUP_NGINX=10015

# Copy custom nginx config if available
COPY --from=builder /app/frontend/default.conf /etc/nginx/conf.d/default.conf

# Serve built dist folder
COPY --from=builder /app/frontend/dist /usr/share/nginx/html/

USER nginx

EXPOSE 8080