#!/bin/sh /etc/rc.common
MYSQL_PW = "99012016"
PHP_PORT = "81"
PHP_DOMAIN = "myDomain"
opkg update
opkg install apache
sed -i 's,Listen.*,Listen $PHP_PORT,g' /etc/apache/httpd.conf
sed -i 's,#ServerName.*,ServerName $PHP_DOMAIN:$PHP_PORT,g' /etc/apache/httpd.conf
sed -i 's,LogLevel debug.*,LogLevel error,g' /etc/apache/httpd.conf
sed -i 's,DirectoryIndex index.html.*,DirectoryIndex index.php index.html,g' /etc/apache/httpd.conf
sed -i 's,<IfModule mime_module>.*,<IfModule mime_module>\n AddType application/x-httpd-php .php\n Action application/x-httpd-php "/php/php-cgi" ,g' /etc/apache/httpd.conf
sed -i 's,ScriptAlias /cgi-bin/ "/usr/share/cgi-bin/".*,ScriptAlias /cgi-bin/ "/usr/share/cgi-bin/"\n ScriptAlias /php/ "/usr/bin/" ,g' /etc/apache/httpd.conf
apachectl start
opkg install php5 php5-cgi php5-fastcgi php5-mod-json php5-mod-curl php5-cli php5-mod-ftp php5-mod-gd php5-mod-mbstring php5-mod-mcrypt php5-mod-mysql php5-mod-mysqli php5-mod-pdo php5-mod-sqlite3 php5-mod-sockets
ln -s /usr/bin/php-cgi /usr/share/cgi-bin/
echo -e '<Directory "/usr/share/cgi-bin">\n    AllowOverride None\n    Options FollowSymLinks\n    Order allow,deny\n    Allow from all\n</Directory>\n\n<Directory "/usr/bin">\n    AllowOverride None\n    Options none\n    Order allow,deny\n    Allow from all\n</Directory>' >> /etc/apache/httpd.conf
sed -i 's,doc_root.*,doc_root = "",g' /etc/php.ini
apachectl restart
opkg update
opkg install libpthread libncurses libreadline mysql-server
mkdir -p /mnt/data/mysql
mkdir -p /mnt/data/tmp
mysql_install_db --force
/etc/init.d/mysqld start
/etc/init.d/mysqld enable
mysqladmin -u root password $MYSQL_PW
mv apache /etc/init.d/
/etc/init.d/apache start
/etc/init.d/apache enable
opkg install nano
opkg install openssh-sftp-server
