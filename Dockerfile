# php image load
FROM php:7.2-fpm-alpine

WORKDIR /app

RUN apk --update upgrade \
    && apk add --no-cache autoconf automake make gcc g++ icu-dev \
        libxml2-dev \
        libzip-dev \
        libpng-dev \
        libaio \
        libnsl \
        libc6-compat \
        gcompat \
        curl \ 
        $PHPIZE_DEPS \
        icu-dev \
        libzip-dev \
        postgresql-dev \
        zlib-dev \
        && docker-php-ext-install pdo zip intl xmlrpc soap bcmath gd pcntl exif sockets \
    && pecl install apcu-5.1.17 \
    && docker-php-ext-install -j$(nproc) \
       bcmath \
       opcache \
       pdo \
       pdo_mysql \
       tokenizer \
   && docker-php-ext-enable \
       apcu \
       opcache
COPY etc/php/ /usr/local/etc/php/
# Instalación de extensiones y librerias
# RUN apt-get update && apt-get install -y \
#     zlib1g-dev \
#     libicu-dev \
#     libxml2-dev \
#     libpq-dev \
#     libzip-dev \
#     libpng-dev \
#     vim \
#     libaio1 \
#     iputils-ping \
#     && docker-php-ext-install pdo zip intl xmlrpc soap bcmath gd pcntl exif sockets

# Copia de instantclient_12_2
COPY ./instantclient_12_2 /opt/oracle/instantclient_12_2
RUN ln -s /opt/oracle/instantclient_12_2/libclntsh.so.12.1 /opt/oracle/instantclient_12_2/libclntsh.so
RUN ln -s /opt/oracle/instantclient_12_2/libocci.so.12.1 /opt/oracle/instantclient_12_2/libocci.so
# RUN ln -sf /opt/oracle/instantclient_12_2/libociei.so /opt/oracle/instantclient_12_2/libociei.so
# RUN ln -sf /opt/oracle/instantclient_12_2/libnnz12.so /opt/oracle/instantclient_12_2/libnnz12.so
RUN ln -s /usr/lib/libnsl.so.2 /usr/lib/libnsl.so.1
RUN ln -s /lib/libc.so.6 /usr/lib/libresolv.so.2
RUN echo "/opt/oracle/instantclient_12_2 > /etc/ld.so.conf.d/oracle-instantclient.conf" \
    ldconfig

ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/oracle/instantclient_12_2:/lib64
ENV ORACLE_HOME=$ORACLE_HOME:/opt/oracle/instantclient_12_2

# Instalamos extensiones de PHP oci8 / pdo-oci
RUN docker-php-ext-configure oci8 --with-oci8=instantclient,/opt/oracle/instantclient_12_2 \
    && docker-php-ext-install oci8
RUN docker-php-ext-configure pdo_oci --with-pdo-oci=instantclient,/opt/oracle/instantclient_12_2 \
    && docker-php-ext-install pdo_oci

RUN echo 'extension=oci8' > /usr/local/etc/php/conf.d/docker-php-ext-oci8.ini
# Copia de composer en la última versión
# COPY --from=composer:lts /usr/bin/composer /usr/bin/composer
# ENV COMPOSER_ALLOW_SUPERUSER 1

# # Instalación dependencia socket io laravel
# RUN composer require pusher/pusher-php-server "~4.0"
# # Instalación de node
# RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash - &&\
# apt-get install -y nodejs
# RUN npm install -g npm@9.6.2

# # Instalación de laravel echo server
# RUN npm install -g laravel-echo-server
# RUN laravel-echo-server .
# # Instalación del demonio administrador de procesos
# RUN npm install pm2 -g

# # COPY . /var/www/html/
# WORKDIR /var/www/html/
# RUN pm2 start /var/www/html/socket.sh
CMD ["php-fpm"]