# LAMP

## 在RHEL系计算机上部署lamp

>自动化脚本在 ./INSTALL.sh <br />
>懂linux shell的大佬可以帮忙改改，感激不尽 <br />
>*脚本未经测试，未经测试，未经测试 <br />*
>脚本安装的软件版本是 php7.14 apache2.4 (mariadb10.1 或 mariadb5.5.56) <br />

----------------------------------------------------------------------------------

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
    ./configure --prefix=/opt/lamp/apr  
    make && make install
    -------
    wget http://mirrors.hust.edu.cn/apache//apr/apr-1.5.2.tar.gz
~~~

**apr-util**
~~~shell
    tar -zxf apr-util-1.3.12.tar.gz  
    cd apr-util-1.3.12  
    ./configure --prefix=/opt/lamp/apr-util -with- apr=/opt/lamp/apr/bin/apr-1-config  
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
    ./configure --prefix=/opt/lamp/pcre  
    make && make install
    -------
    wget https://ftp.pcre.org/pub/pcre/pcre-8.00.tar.gz
~~~
---------------------------------------------------------------------------------

## yum dnf 查找不到的包
**lib-client**
```php
	ftp://195.220.108.108/linux/centos/6.9/os/x86_64/Packages/libc-client-2007e-11.el6.x86_64.rpm
```

**lib-xml**
```php
	
```


# 编译安装Php

~~~shell
    ./configure --prefix="/opt/lamp/php" --with-apxs2="/opt/lamp/apache24/bin/apxs" --with-config-file-path="/opt/lamp/php/etc" --with-pear --enable-shared --enable-inline-optimization --disable-debug --with-libxml-dir --enable-bcmath --enable-calendar --enable-ctype --with-kerberos --enable-ftp --with-jpeg-dir --with-freetype-dir --enable-gd-native-ttf --with-gd --with-iconv --with-zlib --with-openssl --with-xsl --with-imap-ssl --with-imap --with-gettext --with-mhash --enable-sockets --enable-mbstring=all --with-curl --with-curlwrappers --enable-mbregex --enable-exif --with-bz2 --with-sqlite3 --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-pdo-sqlite --enable-fileinfo --enable-phar --enable-zip --with-pcre-regex --with-mcrypt --enable-fpm
    -------
    wget http://tw2.php.net/get/php-7.1.4.tar.gz/from/this/mirror
    wget http://cn2.php.net/get/php-7.1.4.tar.gz/from/this/mirror
    ---------------------------------------------------------
    如果需要nginx支持，则需要另外加入 --enable-fpm 并除去 --with-apsx
~~~
-------------------------------------------

# 编译安装Nginx

~~~shell
    ./configure --prefix=/opt/lamp/nginx --with-http_ssl_module --with-pcre=../pcre-8.39 --with-zlib=../zlib-1.2.8 
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


**PHP-fpm 配置**
```
	在执行文件时  加上 --with-config-file-path=/usr/local/php/etc 可以指定php.ini的位置
	# cd /usr/local/php/etc/  进入这个目录
	# cp php-fpm.conf.default php-fpm.conf  添加php-fpm.conf 配置文件
	# cd php-fpm.d  在进入这个目录
	# cp www.conf.default www.conf  添加www.conf，这个文件是phpfpm的端口号等信息
	进入php-fpm.conf 这个文件把 ;pid = run/php-fpm.pid 前面的;去掉
	启动php
	#/usr/local/php/sbin/php-fpm
	配置nginx
	进入nginx.conf ，在 /usr/local/nginx/conf/nginx.conf中
	location ~ \.php$ {
		root html;
		fastcgi_pass 127.0.0.1:9000;
		fastcgi_index index.php;
		fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
		include fastcgi_params;
	}
	重启nginx :/usr/local/nginx/sbin/nginx -s reload
	安装完成
	php-fpm信号控制启动重启等状态
	SIGINT, SIGTERM 立刻终止
	SIGQUIT 平滑终止
	SIGUSR1 重新打开日志文件
	SIGUSR2 平滑重载所有worker进程并重新载入配置和二进制模块
	php重启：kill -USR2 `cat /usr/local/php/var/run/php-fpm.pid`
	停止 ： kill -SIGINT php-fpm.pid
```
----------------------------------------

# 编译安装apache

~~~
    ./configure --prefix=/opt/lamp/apache24 --enable-module=shared --with-apr=/opt/lamp/apr --with-apr-util=/opt/lamp/apr-util/ --with-pcre=/opt/lamp/pcre
    ------
    wget http://mirror.bit.edu.cn/apache//httpd/httpd-2.4.25.tar.gz
~~~
---------------------------------------

## 配置apache

### 编辑/conf/httpd.conf ###

**使Apache支持PHP**
```php
    AddType application/x-compress .Z
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

**引入配置文件**
~~~
    Include "Path/configFileName.conf"
~~~

**切换php版本**
~~~
    编译多个版本php在指定的目录
    建议以(php[version])为目录名
    在http.conf中写入以下行即可
    LoadModule php[version].so 
~~~

**修改服务器名**
~~~php
    ServerName 127.0.0.1:80
~~~

**修改文档目录**
~~~php
    DocumentRoot "/opt/lamp/apache24/htdocs"
    <Directory "/opt/lamp/apache24/htdocs">
~~~

**修改监听端口**
~~~php
    Listen 80
~~~

**开启URL重写**
~~~php
    LoadModule rewrite_module modules/mod_rewrite.so
~~~

**开启分布式配置文件**
~~~
    http.conf
    Options FollowSymLinks 
    AllowOverride None
    改为：
    AllowOverride All 

    参考资料 ：http://www.jb51.net/article/25476.htm
~~~

**隐藏目录**
~~~
    .htaccess
    deny from all
~~~
**重写URL**
~~~
    .htaccess
    <IfModule mod_rewrite.c>
        Options +FollowSymlinks
        RewriteEngine On
        RewriteCond %{REQUEST_FILENAME} !-d
        RewriteCond %{REQUEST_FILENAME} !-f
        RewriteRule ^(.*)$ index.php/$1 [QSA,PT,L]
    </IfModule>
~~~

**关闭列出目录**
~~~
    .htaccess
    <Files *>
        Options -Indexes
    </Files>

    http.conf
    <Directory dirName>
        Options FollowSymLinks
        AllowOverride  All
    </Directory>
~~~

**定义错误码页面**
~~~
    .htaccess
　　ErrorDocument 404 /errors/notfound.html 
　　ErrorDocument 500 /errors/internalerror.html 
~~~

**虚拟主机配置**
~~~
    取消httpd.conf注释
    #Include conf/extra/httpd-vhosts.conf 

    修改conf/extra/httpd-vhosts.conf 添加以下内容
    基于端口创建主机
        Listen 80 
        Listen 8080
        <VirtualHost doMain:portNumber>
            DocumentRoot "prefix"
            ServerName websiteName
        </VirtualHost>

    基于域名创建主机
        <VirtualHost *:80>
            DocumentRoot "prefix"
            ServerName websiteName
            ServerAlias siteAlias
            ErrorLog "logs/test1-error.log"
            CustomLog "logs/test1-access.log" common
        </VirtualHost>

    基于IP创建主机
        <VirtualHost 172.20.30.50:80>
            DocumentRoot "prefix"
            ServerName websiteName
            ErrorLog "logs/test2-error.log"
            CustomLog "logs/test2-access.log" common
        </VirtualHost>
~~~

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

# 编译安装Mysql

```php
	dnf -y gcc gcc-c++ cmake
    二进制版本
	   Stable mariadb 10.0.0 https://mirrors.tuna.tsinghua.edu.cn/mariadb//mariadb-10.0.30/bintar-linux-x86_64/mariadb-10.0.30-linux-x86_64.tar.gz
    源码版本
        Stable mariadb 10.1.0 https://downloads.mariadb.org/f/mariadb-10.1.23/source/mariadb-10.1.23.tar.gz/from/http%3A//mirrors.tuna.tsinghua.edu.cn/mariadb/?serve
        Stable mariadb 5.5.56 https://downloads.mariadb.org/f/mariadb-5.5.56/source/mariadb-5.5.56.tar.gz/from/http%3A//mirrors.tuna.tsinghua.edu.cn/mariadb/?serve
```

**配置安装目录与数据储存目录
```php
	cmake -DCMAKE_INSTALL_PREFIX=/opt/lamp/mysql -DMYSQL_DATADIR=/opt/lamp/mysql/data
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

**新建用户**
```
    insert into mysql.user(`User` ,`Password`) values('user' ,'pass');
```

**赋予权限**
```
    grant all privileges on user.* to user@"allow host" identified by 'password';
```

**刷新权限**
```
    flush privileges;
```

**硬关闭mysql**
```
    ps -e | grep mysql | awk $1 > temp
    for mysql in $(cat temp)
        do
        kill -9 mysql
    done
    rm temp
```
