FROM nginx:alpine

# Copy renamed artifact from Jenkins build context
COPY app.tar.gz /tmp/app.tar.gz

RUN rm -rf /usr/share/nginx/html/* \
    && tar -xzf /tmp/app.tar.gz -C /usr/share/nginx/html/ \
    && rm -f /tmp/app.tar.gz

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
