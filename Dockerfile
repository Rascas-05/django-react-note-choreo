### Stage 1: Build
FROM node:22.15.0-alpine AS builder

WORKDIR /app/frontend

RUN npm install -g pnpm

COPY frontend/ ./

# use yarn since you’ve got a yarn.lock
RUN yarn install --frozen-lockfile && yarn build

### Stage 2: Serve with nginx
FROM choreoanonymouspullable.azurecr.io/nginxinc/nginx-unprivileged:stable-alpine-slim

ENV ENABLE_PERMISSIONS=TRUE
ENV DEBUG_PERMISSIONS=TRUE
ENV USER_NGINX=10015
ENV GROUP_NGINX=10015

# Copy nginx config if provided
COPY --from=builder /app/frontend/default.conf /etc/nginx/conf.d/default.conf

# Copy the Vite dist/ output, not build/
COPY --from=builder /app/frontend/dist /usr/share/nginx/html/

USER nginx

EXPOSE 8080
