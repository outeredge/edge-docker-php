FROM ubuntu:14.04
MAINTAINER outer/edge <hello@outeredgeuk.com>

ENV DEBIAN_FRONTEND noninteractive
ENV HOME /root

# Install Default Packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl nano wget software-properties-common \
        ruby nodejs-legacy npm git-core apache2 libapache2-mod-php5 \
        php5-cli php5-mysql php5-sqlite php5-curl php5-intl && \
    apt-get clean && \
    rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/*

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install bower
RUN npm install -g bower && npm cache clean

# Setup apache
RUN a2enmod rewrite
ADD apache.conf /etc/apache2/sites-enabled/000-default.conf
ADD run.sh /run.sh
RUN chmod +x /run.sh

WORKDIR /var/www
EXPOSE 80
CMD ["/run.sh"]
