FROM php:8.2-apache

ENV APACHE_DOCROOT /var/www/html
ENV NODE_MAJOR 20

RUN apt-get update \
 && apt-get install -y \
 curl \
 apt-transport-https \
 git \
 build-essential \
 libssl-dev \
 wget \
 unzip \
 bzip2 \
 libbz2-dev \
 zlib1g-dev \
 libfontconfig \
 libfreetype6-dev \
 libjpeg62-turbo-dev \
 libpng-dev \
 libicu-dev \
 libxml2-dev \
 libldap2-dev \
 libmcrypt-dev \
 fabric \
 jq \
 gnupg \
 && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN docker-php-ext-install mysqli pdo pdo_mysql

RUN pecl install redis \
    &&  rm -rf /tmp/pear \
    &&  docker-php-ext-enable redis

RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
RUN echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list
RUN apt-get update && apt-get install nodejs -y
RUN npm install -g yarn

ENV PATH "/composer/vendor/bin:$PATH"
ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_HOME /composer
ENV COMPOSER_VERSION 2.6.2

RUN curl -s -f -L -o /tmp/installer.php https://raw.githubusercontent.com/composer/getcomposer.org/main/web/installer \
     && php /tmp/installer.php --no-ansi --install-dir=/usr/bin --filename=composer --version=${COMPOSER_VERSION} \
     && rm /tmp/installer.php \
     && composer --ansi --version --no-interaction \
     && composer global require drush/drush --prefer-dist

#RUN cd /usr/src && mkdir php && cd php && mkdir ext && cd ext && mkdir mcrypt
#
#RUN docker-php-ext-configure gd \
#    && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu \
#    && docker-php-ext-install -j$(nproc) \
#      bcmath \
#      bz2 \
#      calendar \
#      exif \
#      ftp \
#      gd \
#      gettext \
#      intl \
#      ldap \
#      mcrypt \
#      mysqli \
#      opcache \
#      pcntl \
#      pdo_mysql \
#      shmop \
#      soap \
#      sockets \
#      sysvmsg \
#      sysvsem \
#      sysvshm \
#      zip \
#    && pecl install redis apcu \
#    && docker-php-ext-enable redis apcu


#
# PHP configuration
#
# Set timezone
RUN echo "date.timezone = \"America/New_York\"" > $PHP_INI_DIR/conf.d/timezone.ini
# Increase PHP memory limit
RUN echo "memory_limit=-1" > $PHP_INI_DIR/conf.d/timezone.ini
# Set upload limit
RUN echo "upload_max_filesize = 128M\npost_max_size = 128M" > $PHP_INI_DIR/conf.d/00-max_filesize.ini


#
# Apache configuration
#
RUN a2enmod rewrite headers expires ssl \
  && sed -i "/User www-data/c\User \$\{APACHE_RUN_USER\}" /etc/apache2/apache2.conf \
  && sed -i "/Group www-data/c\Group \$\{APACHE_RUN_GROUP\}" /etc/apache2/apache2.conf \
  && sed -i "/DocumentRoot \/var\/www\/html/c\\\tDocumentRoot \$\{APACHE_DOCROOT\}" /etc/apache2/sites-enabled/000-default.conf \
  # Preemptively add a user 1000, for use with $APACHE_RUN_USER on osx
  && adduser --uid 1000 --gecos 'My OSX User' --disabled-password osxuser


COPY src/ /var/www/html/

WORKDIR /var/www/html

RUN composer install && composer dump-autoload
RUN npm install

EXPOSE 80