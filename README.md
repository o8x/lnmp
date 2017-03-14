# LAMP
在RHEL系计算机上部署lamp

### 需要处理的依赖包 ###
~~~
dnf yum 均可执行下列操作
dnf -y remove apr-util-devel apr apr-util-mysql apr-docs apr-devel apr-util apr-util-docs 
dnf -y install openssl openssl-devel db4-devel libjpeg-devel libpng-devel libXpm-devel gmp-devel libc-client-devel openldap-devel unixODBC-devel postgresql-devel sqlite-devel aspell-devel net-snmp-devel libxslt-devel libxml2-devel pcre-devel mysql-devel unixODBC-devel postgresql-devel pspell-devel net-snmp-devel libxslt-devel freetype-devel libxml-devel libc-client-devel pam-devel libc-client libc-client-devel
~~~

### 需要的进行的链接动作
~~~
ln -s /usr/lib64/libssl.so /usr/lib/
ln -s /usr/lib64/libc-client.so /usr/lib/libc-client.so 
~~~
----------------------------------------------------------------------------------

# 需要提前编译或安装的包

**mcrypt**
~~~
tar zxf libmcrypt-2.5.7.tar.gz
cd libmcrypt-2.5.7
./configure
make && make install
~~~

**apr**
~~~
tar -zxf apr-1.4.5.tar.gz  
cd  apr-1.4.5  
./configure --prefix=/opt/Tools/Lamp/apr  
make && make install  
~~~

**APR-util**
~~~
tar -zxf apr-util-1.3.12.tar.gz  
cd apr-util-1.3.12  
./configure --prefix=/opt/Tools/Lamp/apr-util -with- apr=/opt/Tools/Lamp/apr/bin/apr-1-config  
make && make install
~~~

**pcre**
~~~
unzip -o pcre-8.10.zip  
cd pcre-8.10  
./configure --prefix=/opt/Tools/Lamp/pcre  
make && make install 
~~~
---------------------------------------------------------------------------------

# 编译安装Php

~~~
./configure --prefix="/opt/Tools/Lamp/php" --with-apxs2="/opt/Tools/Lamp/apache24/bin/apxs" --with-config-file-path="/opt/Tools/Lamp/php/etc" --with-pear --enable-shared --enable-inline-optimization --disable-debug --with-libxml-dir --enable-bcmath --enable-calendar --enable-ctype --with-kerberos --enable-ftp --with-jpeg-dir --with-freetype-dir --enable-gd-native-ttf --with-gd --with-iconv --with-zlib --with-openssl --with-xsl --with-imap-ssl --with-imap --with-gettext --with-mhash --enable-sockets --enable-mbstring=all --with-curl --with-curlwrappers --enable-mbregex --enable-exif --with-bz2 --with-sqlite3 --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-pdo-sqlite --enable-fileinfo --enable-phar --enable-zip --with-pcre-regex --with-mcrypt --enable-fpm
---------------------------------------------------------
如果需要nginx支持，则需要另外加入 --enable-fpm 并除去 --with-apsx
~~~
-------------------------------------------

# 编译安装Nginx

~~~
./configure --prefix=/opt/Tools/Lamp/nginx --with-http_ssl_module --with-pcre=../pcre-8.39 --with-zlib=../zlib-1.2.8 
make
make install
~~~

## 配置nginx
**使php支持pathinfo与隐藏index.php**
```nginx
    server { 
        listen       80;
        default_type text/plain;
        root /var/www/html;
        index index.php index.htm index.html;
    #隐藏index.php
        location / {
              if (!-e $request_filename) {
                       #一级目录
                      # rewrite ^/(.*)$ /index.php/$1 last;
                       #二级目录
                       rewrite ^/MYAPP/(.*)$ /MYAPP/index.php/$1 last;
                 }  
        }
    #pathinfo设置
            location ~ \.php($|/) {
                fastcgi_pass   127.0.0.1:9000;
                fastcgi_index  index.php;
                fastcgi_split_path_info ^(.+\.php)(.*)$;
                fastcgi_param   PATH_INFO $fastcgi_path_info;
                fastcgi_param  SCRIPT_FILENAME   $document_root$fastcgi_script_name;
                include        fastcgi_params;
            }
    }
```

----------------------------------------

# 编译安装apache

~~~
./configure --prefix=/opt/Tools/Lamp/Apache2 --enable-module=shared --with-apr=/opt/Tools/Lamp/apr --with-apr-util=/opt/Tools/Lamp/apr-util/ --with-pcre=/opt/Tools/Lamp/pcre
~~~
---------------------------------------

## 配置apache

### 编辑/conf/httpd.conf ###

**使Apcche支持PHP**
```php
AddType  application/x-compress .Z
AddType application/x-httpd-php .php
AddType application/x-httpd-php-source .php5
```
**自动解析php扩展名**
~~~
<IfModule dir_module>
DirectoryIndex index.html index.php
</IfModule>
~~~

**使用分布式apache配置文件**
~~~
<Files ".ht*">
Require all granted
</Files>
~~~

**修改服务器名**
~~~
修改ServerName www.example.com:80 为 ServerName 127.0.0.1:80
~~~

**修改文档目录**
~~~
DocumentRoot "/opt/Tools/Lamp/apache24/htdocs"
<Directory "/opt/Tools/Lamp/apache24/htdocs">
~~~

**修改监听端口**
~~~
Listen 80
~~~

**开启URL重写**
~~~
LoadModule rewrite_module modules/mod_rewrite.so
~~~
