# Stage 1: Base Nginx image
FROM nginx:alpine

# Copy the tar.gz artifact (Jenkins pipeline downloads it)
# It will match:  starbugs-app-x.x.x.tar.gz
COPY *.tar.gz /tmp/app.tar.gz

# Remove default nginx HTML and extract your build
RUN rm -rf /usr/share/nginx/html/* \
    && tar -xzf /tmp/app.tar.gz -C /usr/share/nginx/html/ \
    && rm -f /tmp/app.tar.gz

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
