FROM nginx:1.25

RUN mkdir /app/ && \
    usermod -u 1001 nginx && groupmod -g 1001 nginx

EXPOSE 8000

COPY nginx.conf /etc/nginx/nginx.conf

CMD ["nginx", "-g", "daemon off;"]
