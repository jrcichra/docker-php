# vim:set ft=dockerfile:

FROM debian:jessie
MAINTAINER Pooya Parsa <pooya@pi0.ir>

# Install packages
RUN apt update
RUN apt install -y git nginx wget \
	sudo dbus \
	php5-fpm php5-curl php5-mysql php5-mcrypt php5-json php5-cli php5-curl php5-dev \
	openssl libssl-dev libcurl4-openssl-dev libsasl2-dev libpcre3-dev pkg-config curl

# Installing the MongoDB PHP Driver with PECL
RUN pecl install mongodb

RUN echo "extension = mongodb.so" > /etc/php5/mods-available/mongo.ini && \
	ln -fvs /etc/php5/mods-available/mongo.ini /etc/php5/fpm/conf.d/ && \
	ln -fvs /etc/php5/mods-available/mongo.ini /etc/php5/cli/conf.d/

# Cleanup
RUN rm -rf /var/lib/apt/lists/* /var/cache/apt/packages/* && apt-get remove -y php5-dev libssl-dev libcurl4-openssl-dev libsasl2-dev libpcre3-dev pkg-config && apt-get autoremove -y

# Install composer
RUN wget https://getcomposer.org/composer.phar -O /usr/local/bin/composer && \
	chmod +x /usr/local/bin/composer

# Git
RUN mkdir -p /var/www && \
    chown www-data:www-data -R /var/www && \
    sudo -u www-data git config --global credential.helper store

# Php
COPY conf/php.ini /etc/php5/fpm/php.ini
COPY conf/www.conf /etc/php5/fpm/pool.d/www.conf 

# Nginx
COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/nginx-default /etc/nginx/sites-enabled/default

# Home dir
RUN mkdir -p /var/www && chown -R www-data:www-data /var/www

# Let's Encrypt
RUN wget -nv -O - https://github.com/lukas2511/letsencrypt.sh/archive/master.tar.gz | tar -xvzf - && \
	mv letsencrypt.sh-master/ /opt/letsencrypt && \
	cp /opt/letsencrypt/config.sh.example /opt/letsencrypt/config.sh && \
	touch /opt/letsencrypt/domains.txt && \
	mkdir -p /opt/letsencrypt/.acme-challenges

# Lasser
COPY laaser /usr/share/laaser

#Bin
COPY bin /usr/local/bin

#Entrypoint Script
ENTRYPOINT ["/usr/local/bin/entrypoint"]
