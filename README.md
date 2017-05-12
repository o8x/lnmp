# LAMP
在RHEL系计算机上部署lamp

### 需要处理的依赖包 ###
~~~shell
    dnf yum 均可执行下列操作
    dnf -y remove apr-util-devel apr apr-util-mysql apr-docs apr-devel apr-util apr-util-docs 
    dnf -y install openssl openssl-devel db4-devel libjpeg-devel libpng-devel libXpm-devel gmp-devel libc-client-devel openldap-devel unixODBC-devel postgresql-devel sqlite-devel aspell-devel net-snmp-devel libxslt-devel libxml2-devel pcre-devel mysql-devel unixODBC-devel postgresql-devel pspell-devel net-snmp-devel libxslt-devel freetype-devel libxml-devel libc-client-devel pam-devel libc-client libc-client-devel bzip2 bzip2-devel 
~~~

### 需要的进行的链接动作
~~~shell
    ln -s /usr/lib64/libssl.so /usr/lib/
    ln -s /usr/lib64/libc-client.so /usr/lib/libc-client.so 
~~~
----------------------------------------------------------------------------------

# 需要提前编译或安装的包

**mcrypt**
~~~shell
    tar zxf libmcrypt-2.5.7.tar.gz
    cd libmcrypt-2.5.7
    ./configure
    make && make install
    -------
    wget http://sourceforge.net/project/showfiles.php?group_id=4286&package_id=4300&release_id=645636
    wget http://sourceforge.net/project/showfiles.php?group_id=4286&package_id=4300&release_id=645636
    wget http://sourceforge.net/project/showfiles.php?group_id=87941&package_id=91948&release_id=642101 
~~~

**apr**
~~~shell
    tar -zxf apr-1.4.5.tar.gz  
    cd  apr-1.4.5  
    ./configure --prefix=/opt/Tools/Lamp/apr  
    make && make install
    -------
    wget http://mirrors.hust.edu.cn/apache//apr/apr-1.5.2.tar.gz
~~~

**apr-util**
~~~shell
    tar -zxf apr-util-1.3.12.tar.gz  
    cd apr-util-1.3.12  
    ./configure --prefix=/opt/Tools/Lamp/apr-util -with- apr=/opt/Tools/Lamp/apr/bin/apr-1-config  
    make && make install
    wget http://mirrors.hust.edu.cn/apache//apr/apr-util-1.5.4.tar.gz
    -------
    Apr-iconv
    wget http://mirrors.hust.edu.cn/apache//apr/apr-iconv-1.2.1.tar.gz
~~~

**pcre**
~~~shell
    unzip -o pcre-8.10.zip  
    cd pcre-8.10  
    ./configure --prefix=/opt/Tools/Lamp/pcre  
    make && make install
    -------
    wget https://ftp.pcre.org/pub/pcre/pcre-8.00.tar.gz
~~~
---------------------------------------------------------------------------------

# 编译安装Php

~~~shell
    ./configure --prefix="/opt/Tools/Lamp/php" --with-apxs2="/opt/Tools/Lamp/apache24/bin/apxs" --with-config-file-path="/opt/Tools/Lamp/php/etc" --with-pear --enable-shared --enable-inline-optimization --disable-debug --with-libxml-dir --enable-bcmath --enable-calendar --enable-ctype --with-kerberos --enable-ftp --with-jpeg-dir --with-freetype-dir --enable-gd-native-ttf --with-gd --with-iconv --with-zlib --with-openssl --with-xsl --with-imap-ssl --with-imap --with-gettext --with-mhash --enable-sockets --enable-mbstring=all --with-curl --with-curlwrappers --enable-mbregex --enable-exif --with-bz2 --with-sqlite3 --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-pdo-sqlite --enable-fileinfo --enable-phar --enable-zip --with-pcre-regex --with-mcrypt --enable-fpm
    -------
    wget http://tw2.php.net/get/php-7.1.4.tar.gz/from/this/mirror
    wget http://cn2.php.net/get/php-7.1.4.tar.gz/from/this/mirror
    ---------------------------------------------------------
    如果需要nginx支持，则需要另外加入 --enable-fpm 并除去 --with-apsx
~~~
-------------------------------------------

# 编译安装Nginx

~~~shell
    ./configure --prefix=/opt/Tools/Lamp/nginx --with-http_ssl_module --with-pcre=../pcre-8.39 --with-zlib=../zlib-1.2.8 
    make
    make install
    ------
    wget http://nginx.org/download/nginx-1.12.0.zip
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
    ------
    wget http://mirror.bit.edu.cn/apache//httpd/httpd-2.4.25.tar.gz
~~~
---------------------------------------

## 配置apache

### 编辑/conf/httpd.conf ###

**使Apache支持PHP**
```php
    AddType  application/x-compress .Z
    AddType application/x-httpd-php .php
    AddType application/x-httpd-php-source .php5
```
**自动解析php扩展名**
~~~php
    <IfModule dir_module>
        DirectoryIndex index.html index.php
    </IfModule>
~~~

**使用分布式apache配置文件**
~~~php
    <Files ".ht*">
        Require all granted
    </Files>
~~~

**修改服务器名**
~~~php
    ServerName 127.0.0.1:80
~~~

**修改文档目录**
~~~php
    DocumentRoot "/opt/Tools/Lamp/apache24/htdocs"
    <Directory "/opt/Tools/Lamp/apache24/htdocs">
~~~

**修改监听端口**
~~~php
    Listen 80
~~~

**开启URL重写**
~~~php
    LoadModule rewrite_module modules/mod_rewrite.so
~~~


# 编译安装Mysql

```php
	dnf -y gcc gcc-c++ cmake
	Stable版本 mariadb 10.0.0 https://mirrors.tuna.tsinghua.edu.cn/mariadb//mariadb-10.0.30/bintar-linux-x86_64/mariadb-10.0.30-linux-x86_64.tar.gz
```    
**配置安装目录与数据储存目录
```php
	cmake .-DCMAKE_INSTALL_PREFIX=/usr/local/mysql -DMYSQL_DATADIR=/usr/local/mysql/data
```
**编译 安装**
```php
	make && make install
```
**用户和组配置**
```php
	useradd -r mysql
	chown -R mysql:mysql ./
```
**删除旧配置文件并初始化新的配置文件**
```php
	rm /etc/my.cnf
	prefix/scripts/mysql_install_db --user=mysql
```
**清除所有者，但是保持data目录的mysql所有者**
```php
	chown -R root ./*
	chown -R mysql ./data
```
**后台运行mysql**
```php
	prefix/bin/mysqld_safe --user=mysql & 
```
**连接mysql控制台**
```php
	prefix/prefix/bin/mysql
```
**添加守护进程到开机启动 环境变量**
```php
	$PATH/prefix/bin
	/etc/init.d
```


# 为Apache配置SSL DV证书
**加载模块**
```php
	修改http.conf
	LoadModule socache_shmcb_module modules/mod_socache_shmcb.so
	LoadModule ssl_module modules/mod_ssl.so (如果找不到请确认是否编译过 openssl 插件)
	Include conf/extra/httpd-ssl.conf
```
**修改http-ssl.conf**
```php
	添加 SSL 协议支持协议，去掉不安全的协议
	SSLProtocol all -SSLv2 -SSLv3
	修改加密套件如下
	SSLCipherSuite ECDHE-RSA-AES128-GCM-SHA256:ECDHE:ECDH:AES:HIGH:!NULL:!aNULL:!MD5:!ADH:!RC4
	证书公钥配置
	SSLCertificateFile cert/public.pem
	证书私钥配置
	SSLCertificateKeyFile cert/214077101580586.key
	证书链配置，如果该属性开头有 '#'字符，请删除掉
	SSLCertificateChainFile cert/chain.pem
```

















