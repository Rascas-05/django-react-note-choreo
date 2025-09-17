### Stage 1: Build Vite frontend
FROM node:22-alpine AS builder

WORKDIR /app/frontend

RUN npm install -g pnpm

COPY frontend/ ./

RUN yarn install --frozen-lockfile && yarn build

### Stage 2: Serve with nginx
FROM choreoanonymouspullable.azurecr.io/nginxinc/nginx-unprivileged:stable-alpine-slim

ENV ENABLE_PERMISSIONS=TRUE
ENV DEBUG_PERMISSIONS=TRUE
ENV USER_NGINX=10015
ENV GROUP_NGINX=10015

# Use SPA nginx config
COPY frontend/default.conf /etc/nginx/conf.d/default.conf

# Copy the correct Vite output dist/
COPY --from=builder /app/frontend/dist /usr/share/nginx/html/

USER nginx
EXPOSE 8080