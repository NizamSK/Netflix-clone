# Stage 1: Build the application
FROM node:16.17.0-alpine as builder

# Set working directory in the container
WORKDIR /app

# Copy package.json and package-lock.json files
COPY package.json package-lock.json ./

# Install dependencies using npm
RUN npm install

# Install TypeScript globally (if required for your project)
RUN npm install -g typescript

# Copy the rest of the application files
COPY . .

# Set build arguments and environment variables
ARG TMDB_V3_API_KEY
ENV VITE_APP_TMDB_V3_API_KEY=${TMDB_V3_API_KEY}
ENV VITE_APP_API_ENDPOINT_URL="https://api.themoviedb.org/3"

# Build the application using npm
RUN npm run build

# Stage 2: Serve the built application using NGINX
FROM nginx:stable-alpine

# Set working directory in NGINX container
WORKDIR /usr/share/nginx/html

# Remove existing files in NGINX html directory
RUN rm -rf ./*

# Copy the built files from the builder stage
COPY --from=builder /app/dist .

# Expose port 80 for HTTP traffic
EXPOSE 80

# Set NGINX as the entrypoint
ENTRYPOINT ["nginx", "-g", "daemon off;"]

