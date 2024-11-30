# Stage 1: Build the React app
FROM node:20 as build
WORKDIR /app

# Copy only the package.json and package-lock.json first to leverage caching
COPY app/package.json ./
COPY app/package-lock.json ./

# Install dependencies
RUN npm install

# Now copy the rest of the application code
COPY app/ ./
COPY nginx.conf /etc/nginx/conf.d/default.conf
# Build the application
RUN npm run build

# Stage 2: Serve the app using NGINX
FROM nginx:alpine
COPY --from=build /app/build /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]