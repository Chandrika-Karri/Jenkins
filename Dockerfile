FROM ubuntu:latest
RUN apt update -y
RUN apt install nginx -y
RUN rm -rf /var/www/html/*
COPY . /var/www/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
