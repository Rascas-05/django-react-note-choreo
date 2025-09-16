# Builder stage
FROM node:20-alpine AS builder
WORKDIR /app
COPY frontend/package.json frontend/yarn.lock ./
RUN yarn install --frozen-lockfile
COPY frontend/ .
RUN yarn build

# Nginx stage
FROM nginxinc/nginx-unprivileged:stable-alpine-slim
COPY --from=builder /app/dist /usr/share/nginx/html
EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]