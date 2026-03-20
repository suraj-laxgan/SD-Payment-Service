# Base image: PHP 8.3 with FPM (used in production environments)
FROM php:8.3-fpm

# Install system dependencies required by Laravel & PHP extensions
# git → version control (composer may use it)
# curl → for API calls / downloads
# zip/unzip → required by composer
# libpng-dev → needed for GD (image processing)
# libonig-dev → required for mbstring
# libxml2-dev → required for XML handling
RUN apt-get update && apt-get install -y \
    git \                
    curl \              
    zip unzip \         
    libpng-dev \         
    libonig-dev \      
    libxml2-dev         

# Install PHP extensions required by Laravel
# pdo →  database abstraction
# pdo_mysql → MySQL support
# mbstring → multibyte string support (UTF-8)
# exif → image metadata
# pcntl → process control (queues, jobs)
# bcmath → high precision math
# gd → image processing

RUN docker-php-ext-install \
    pdo \                
    pdo_mysql \          
    mbstring \           
    exif \              
    pcntl \              
    bcmath \            
    gd                   

# Copy Composer (dependency manager) from official image
# This avoids installing composer manually
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory inside container
# All commands will run from this path
WORKDIR /var/www

# Copy only composer files first (for Docker cache optimization)
COPY composer.json composer.lock ./

# Install PHP dependencies
# RUN composer install

# Install dependencies WITHOUT running Laravel scripts
RUN composer install --no-scripts --no-autoloader

# Copy the rest of the Laravel application
COPY . .

# Prevents permission issues later (logs/cache)
RUN chown -R www-data:www-data /var/www

# Generate autoload after full code is present
RUN composer dump-autoload

# Inform Docker that this container uses port 8000
# (documentation purpose only)
EXPOSE 8000

# Start Laravel development server
# 0.0.0.0 is required so it is accessible from outside container
CMD php artisan serve --host=0.0.0.0 --port=8000