# Load image php fpm
FROM php:7.2-fpm-alpine
# Directorio del proyecto
WORKDIR /app
# instalacion de paquetes y utilidades
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
# Copia de configuración de php
COPY etc/php/ /usr/local/etc/php/
# Copia de instantclient_12_2
COPY ./instantclient_12_2 /opt/oracle/instantclient_12_2
# Configuración de instantclient
RUN ln -s /opt/oracle/instantclient_12_2/libclntsh.so.12.1 /opt/oracle/instantclient_12_2/libclntsh.so
RUN ln -s /opt/oracle/instantclient_12_2/libocci.so.12.1 /opt/oracle/instantclient_12_2/libocci.so
RUN ln -s /usr/lib/libnsl.so.2 /usr/lib/libnsl.so.1
RUN ln -s /lib/libc.so.6 /usr/lib/libresolv.so.2
RUN echo "/opt/oracle/instantclient_12_2 > /etc/ld.so.conf.d/oracle-instantclient.conf" \
    ldconfig
# Actualización de las variables de entorno
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/oracle/instantclient_12_2:/lib64
ENV ORACLE_HOME=$ORACLE_HOME:/opt/oracle/instantclient_12_2
# Instalación de extensiones de PHP oci8 / pdo-oci
RUN docker-php-ext-configure oci8 --with-oci8=instantclient,/opt/oracle/instantclient_12_2 \
    && docker-php-ext-install oci8
RUN docker-php-ext-configure pdo_oci --with-pdo-oci=instantclient,/opt/oracle/instantclient_12_2 \
    && docker-php-ext-install pdo_oci
# Ejecución de php
CMD ["php-fpm"]
