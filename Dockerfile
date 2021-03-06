FROM debian:bullseye-slim

RUN apt -y update \
    && apt -y install wget build-essential curl git unzip  nginx nano net-tools \
    && apt -y install apt-transport-https ca-certificates lsb-release \
    && wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg \
    && echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list \
    && apt -y update \
    &&  apt -y install php7.0-common php7.0-cli php7.0-cgi php7.0-fpm php7.0-mysql php7.0-sqlite3 php7.0-curl php7.0-mbstring \
    && apt -y install gnupg default-jre \ 
    && wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.2.0-amd64.deb \ 
    && dpkg -i elasticsearch-8.2.0-amd64.deb

RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/bin/composer

RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - \
    && apt -y install nodejs 
RUN npm i -g pm2 \
    && npm i -g yarn  \
    && systemctl enable nginx \
    && systemctl enable php7.0-fpm \
    && systemctl enable elasticsearch 

RUN cd /opt \
    && git clone https://github.com/AlphaReign/www-php.git \
    && cd www-php \
    && composer install \
    && nano index.php 

RUN cd /opt \
    && git clone https://github.com/AlphaReign/scraper.git \
    && cd scraper \
    && yarn \
    && yarn migrate 

COPY start.sh /opt/start.sh

CMD ["bash","/opt/start.sh"]