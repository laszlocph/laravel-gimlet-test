# Use the webdevops/php-nginx image with Alpine Linux
FROM webdevops/php-nginx:8.2

RUN php -v

# Install system requirements for Laravel
RUN apt-get update && apt-get install -y \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libxml2-dev \
    libzip-dev \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libwebp-dev \
    libxpm-dev \
    libgd-dev \
    libmagickwand-dev

# Correctly specify PHP extensions required by Laravel
RUN docker-php-ext-install -j$(nproc) \
    bcmath \
    fileinfo \
    pdo_mysql

# Copy Composer binary from the Composer official Docker image
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set environment variables
ENV WEB_DOCUMENT_ROOT /app/public
ENV APP_ENV production

# Set the working directory inside the container
WORKDIR /app

# Copy the application code into the container
COPY . .

# Install dependencies using Composer
RUN composer install --no-interaction --optimize-autoloader --no-dev

# Optimize configuration, route, and view caching
RUN php artisan config:cache
RUN php artisan route:cache
RUN php artisan view:cache

# Change ownership of the application files to avoid permission issues
RUN chown -R application:application .
