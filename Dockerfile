# syntax=docker/dockerfile:1
FROM php:8.0.5-apache-buster

#install all the system dependencies and enable PHP modules 
RUN apt-get update && apt-get install -y git \
    zip \
    curl \
    unzip \
    libicu-dev \
    libbz2-dev \
    libmcrypt-dev \
    libreadline-dev \
    libxml2-dev \
    libfreetype6-dev \ 
    libzip-dev \
    g++

#to install php xml, gd, mbstring, zip
RUN apt-get install -y libpng-dev \
    libjpeg-dev \
    libjpeg62-turbo-dev \
    libonig-dev \
    pngquant

RUN apt autoremove -y

RUN docker-php-ext-install bz2 \
    iconv \
    bcmath \
    xml \
    intl \
    pdo_mysql \
    mysqli \
    opcache

RUN docker-php-ext-enable opcache

RUN docker-php-ext-configure gd --with-freetype --with-jpeg && docker-php-ext-install gd

#clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

#set our application folder as an environment variable
ENV APP_HOME /var/www/html

#change uid and gid of apache to docker user uid/gid
RUN usermod -u 1000 www-data && groupmod -g 1000 www-data

#change the web_root to laravel /var/www/html/public folder
RUN sed -i -e "s/html/html\/public/g" /etc/apache2/sites-enabled/000-default.conf

# enable apache module rewrite
RUN a2enmod rewrite

#copy source files and run composer, assuming that you have source code for composer
COPY . $APP_HOME
RUN service apache2 restart

# set timezone
ENV TZ=America/New_York
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

#change ownership of our applications
RUN chown -R www-data:www-data $APP_HOME