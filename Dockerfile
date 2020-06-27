FROM nginx:1.19-alpine
LABEL maintainer="Deokgyu Yang <secugyu@gmail.com>" \
      description="Lightweight h5ai 0.29.2 container with Nginx 1.19 & PHP 7.4 based on Alpine Linux."

# Add PHP 7.4 repository
ADD https://dl.bintray.com/php-alpine/key/php-alpine.rsa.pub /etc/apk/keys/php-alpine.rsa.pub
RUN apk --update add ca-certificates && \
    echo "https://dl.bintray.com/php-alpine/v3.11/php-7.4" >> /etc/apk/repositories

# Install packages
RUN apk update
RUN apk add --no-cache \
    bash bash-completion supervisor tzdata \
    php7 php7-fpm php7-session php7-json php7-xml php7-mbstring php7-exif \
    php7-intl php7-gd php7-imagick php7-zip \
    ffmpeg imagemagick zip apache2-utils

# Environments
ENV TZ='Asia/Seoul'
ENV HTPASSWD='false'
ENV HTPASSWD_USER='guest'
ENV HTPASSWD_PW=''

# Copy configuration files
COPY config/h5ai.conf /etc/nginx/conf.d/h5ai.conf
COPY config/php_set_timezone.ini /etc/php7/conf.d/zzz_custom.ini
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Copy h5ai
COPY config/_h5ai /usr/share/h5ai/_h5ai

# Configure Nginx server
RUN sed --in-place=.bak 's/worker_processes  1/worker_processes  auto/g' /etc/nginx/nginx.conf
RUN mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.bak

# Add shell script, patch files
ADD config/init.sh /
ADD config/h5ai.conf.htpasswd.patch /
# Set entry point file permission
RUN chmod a+x /init.sh

EXPOSE 80
VOLUME [ "/config", "/h5ai" ]
ENTRYPOINT [ "/init.sh" ]
