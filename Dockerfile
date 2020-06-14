# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Dockerfile                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: seogkim <seogkim@42seoul.kr>               +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2020/06/05 04:10:02 by seogkim           #+#    #+#              #
#    Updated: 2020/06/05 04:10:04 by seogkim          ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

FROM debian:buster
LABEL maintainer="seogkim <seogkim@student.42seoul.kr>"

# UPDATE PACKAGE & INSTALL SERVICES
RUN apt-get update;\
    apt-get install -y wget nginx php-fpm php-mysql php-mysqlnd php-mbstring mariadb-server mariadb-client

# COPY NGINX CONFIG
COPY ./srcs/default ./etc/nginx/sites-available/default

# ISSUE SSL Certificate
RUN openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -subj "/C=KR/ST=Seoul/L=Seongnam-si/O=42/OU=Student/CN=seogkim" -keyout /etc/ssl/private/localhost.key -out /etc/ssl/certs/localhost.crt

# SET WORKING DIR
WORKDIR /var/www/html/

# INSTALL PHPMYADMIN & COPY CONFIG
RUN mkdir phpmyadmin;\
    wget https://files.phpmyadmin.net/phpMyAdmin/4.9.5/phpMyAdmin-4.9.5-all-languages.tar.gz;\
    tar -xvf phpMyAdmin-4.9.5-all-languages.tar.gz --strip-components=1 -C ./phpmyadmin;\
    rm -rf phpMyAdmin-4.9.5-all-languages.tar.gz
COPY ./srcs/config.inc.php ./phpmyadmin

# INSTALL WORKPRESS & COPY CONFIG
RUN wget https://wordpress.org/latest.tar.gz;\
    tar -xvf latest.tar.gz;\
    rm -rf latest.tar.gz
COPY ./srcs/wp-config.php ./wordpress

# SET PERMISSION
RUN chown -R www-data:www-data /var/www/*;\
    chmod -R 755 /var/www/*

# START SERVICES & CREATE USER & CREATE DB
CMD	service mysql start;\
	service php7.3-fpm start;\
	echo "CREATE USER 'seogkim'@'%' identified by '';" | mysql -u root --skip-password;\
	echo "CREATE DATABASE my_server;" | mysql -u root --skip-password;\
	echo "GRANT ALL PRIVILEGES ON *.* TO 'seogkim'@'%';" | mysql -u root --skip-password ;\
	echo "FLUSH PRIVILEGES;" | mysql -u root --skip-password;\
    service nginx start;\
    sleep inf
