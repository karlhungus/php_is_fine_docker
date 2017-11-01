# use the ubuntu base image provided by dotCloud
FROM ubuntu

MAINTAINER izaak
# copy config file for mysql
#ADD files/my.cnf /etc/mysql/my.cnf

# make sure the package repository is up to date
#RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list
RUN apt-get update

RUN echo 'mysql-server mysql-server/root_password password password' | debconf-set-selections
RUN echo 'mysql-server mysql-server/root_password_again password password' | debconf-set-selections
RUN apt-get -y install php7.0 libapache2-mod-php7.0 php7.0-cli \
      php7.0-common php7.0-mbstring php7.0-gd php7.0-intl php7.0-xml \
      php7.0-mysql php7.0-mcrypt php7.0-zip mysql-client \
      mysql-server git sudo \
      less vim curl wget
# hack for not start mysql-server cause of /sbin/initctl
#RUN dpkg-divert --local --rename --add /sbin/initctl
#RUN ln -s /bin/true /sbin/initctl

# install mysql
#RUN apt-get install -y -o Dpkg::Options::="--force-confold" mysql-common
#RUN DEBIAN_FRONTEND=noninteractive apt-get install -q -y mysql-server
#RUN apt-get install -y libapache2-mod-auth-mysql php7-mysql

# config for root login from remote
#RUN (/usr/bin/mysqld_safe &); sleep 5; echo "grant all privileges on *.* to root@'%';" | mysql -u root # -ppassword
#CMD ["/usr/bin/mysqld_safe"]

# install subversion
#RUN apt-get -y install subversion
RUN useradd -ms /bin/bash sfproject && adduser sfproject sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER sfproject


# create directory for libs
RUN mkdir -p /home/sfproject/lib/vendor


# composer
ADD files/composer.sh /home/sfproject/composer.sh
RUN sudo chmod +x /home/sfproject/composer.sh
RUN curl -kfLc - -o /home/sfproject/composer-setup.php https://getcomposer.org/installer
RUN php /home/sfproject/composer-setup.php --install-dir /home/sfproject --filename=composer.phar
#RUN /home/sfproject/composer.sh
RUN sudo mv /home/sfproject/composer.phar /usr/local/bin/composer
ADD files/composer.json /home/sfproject/
WORKDIR /home/sfproject
RUN composer install


# create project
#RUN ./symfony_create_project.sh

RUN php ./lib/vendor/lexpress/symfony1/data/bin/symfony generate:project project_example
RUN php ./lib/vendor/lexpress/symfony1/data/bin/symfony configure:database "mysql:host=localhost;dbname=dbname" root password
RUN php ./lib/vendor/lexpress/symfony1/data/bin/symfony generate:app frontend
ADD files/ProjectConfiguration.class.php /home/sfproject/config/

# Directory Structure Rights
RUN chmod 777 /home/sfproject/cache/ /home/sfproject/log/

# environment value
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2

# expose http & ssh port
EXPOSE 8080

ADD files/000-default.conf /etc/apache2/sites-available/
RUN sudo service apache2 start
RUN sudo service mysql start

CMD ["bin/bash"]
