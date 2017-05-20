#!/bin/bash
# 为RHEL家族计算机部署lamp环境

    user=$(whoami)
    if ["$user" != "root"]
        then
        echo -e "因为安装过程需要权限比较高，所以我们希望您使用root权限\n"
        exit
    fi

    longSleepTime="5s"
    sleepTime="3s"
    prefix="/opt/lamp/"
    if [! -d ${prefix}] 
        then
        mkdir -p $prefix
    fi

    echo -e "\n即将开始部署lamp"
    echo -e "\n请确认您的计算机是RHEL或Centos平台"
    echo -e "\n5秒后进入安装进程"
    sleep ${longSleepTime}
    echo -e "\n正在进行依赖包处理"
    sleep ${sleepTime}

    # 处理一些基础依赖
    yum -y remove apr-util-devel apr apr-util-mysql apr-docs apr-devel apr-util apr-util-docs 
    yum -y install openssl openssl-devel db4-devel libjpeg-devel libpng-devel mcrypt mcrypt-devel libXpm-devel gmp-devel libc-client-devel openldap-devel unixODBC-devel postgresql-devel sqlite-devel aspell-devel net-snmp-devel libxslt-devel libxml2-devel pcre-devel mysql-devel unixODBC-devel postgresql-devel pspell-devel net-snmp-devel libxslt-devel freetype-devel libxml-devel libc-client-devel pam-devel libc-client libc-client-devel bzip2 bzip2-devel 
    echo -e "\n进行一些必要的链接动作"
    sleep ${sleepTime}

    # 处理一些链接动作
    ln -s /usr/lib64/libssl.so /usr/lib/
    ln -s /usr/lib64/libc-client.so /usr/lib/libc-client.so 
    
    echo "即将开始编译依赖包"
    sleep ${sleepTime}
    read -t 30 -n 1 -p "是否继续执行安装进程 'y' or 'n'" next 
    
    # 声明当前路径
    nowDir=""
    
    # 安装一个tar包
    # 参数1 地址 ,参数2保存名 ,参数3 扩展名 参数4 其他编译参数
    installTar(){
        
        nowDir="$(pwd)"
        wget "$1" -O "$2""$3"
        tar xzvf "$2""$3" -C "$2"
        cd "$2"
        ./configure --prefix="$prefix""/""$2" "$4"
        make && make install
        
        cd "$nowDir"
        echo "$2 安装完毕"
        sleep "$sleepTime"
        exit 0
    }   

    # 安装一个zip包
    # 参数1 地址 ,参数2保存名 ,参数3 扩展名 参数4 其他编译参数
    installZip(){
        
        nowDir="$(pwd)"
        wget "$1" -O "$2""$3"
        unzip -o "$2""$3"  
        cd "$2"
        ./configure --prefix="$prefix""/""$2" "$4"
        make && make install

        cd "$nowDir"
        echo -e "\n $2 安装完毕"
        sleep "$sleepTime"
        exit 0
    }

    if ["$next" = "y"]
        then
        # 安装依赖
        installTar "http://sourceforge.net/project/showfiles.php?group_id=4286&package_id=4300&release_id=645636" "libmcrypt" ".tar.gz" ""
        installTar "http://mirrors.hust.edu.cn/apache/apr/apr-1.5.2.tar.gz" "apr" ".tar.gz" ""
        installTar "http://mirrors.hust.edu.cn/apache//apr/apr-util-1.5.4.tar.gz" "apr-util" ".tar.gz" "-with-apr=""$prefix""apr/bin/apr-1-config"
        installTar "http://mirrors.hust.edu.cn/apache//apr/apr-iconv-1.2.1.tar.gz" "apr-iconv" ".tar.gz" ""
        installZip "https://ftp.pcre.org/pub/pcre/pcre-8.00.tar.gz" "pcre" ".zip" ""
        # 安装apache24
        installTar "http://mirror.bit.edu.cn/apache//httpd/httpd-2.4.25.tar.gz" "apache24" ".tar.gz" "--enable-module=shared --with-apr=""$prefix""apr --with-apr-util=""$prefix""apr-util/ --with-pcre=""$prefix""/pcre"
        # 安装php7.14
        installTar "http://cn2.php.net/get/php-7.1.4.tar.gz/from/this/mirror" "php7" ".tar.gz" './configure --prefix='"$prefix"'"php7/" --with-apxs2='"$prefix"'"apache24/bin/apxs" --with-config-file-path="/opt/lamp/php/etc" --with-pear --enable-shared --enable-inline-optimization --disable-debug --with-libxml-dir --enable-bcmath --enable-calendar --enable-ctype --with-kerberos --enable-ftp --with-jpeg-dir --with-freetype-dir --enable-gd-native-ttf --with-gd --with-iconv --with-zlib --with-openssl --with-xsl --with-imap-ssl --with-imap --with-gettext --with-mhash --enable-sockets --enable-mbstring=all --with-curl --with-curlwrappers --enable-mbregex --enable-exif --with-bz2 --with-sqlite3 --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-pdo-sqlite --enable-fileinfo --enable-phar --enable-zip --with-pcre-regex --with-mcrypt'

        echo -e "\n\'n\n\n\n\n\n\n"
        echo -e "\n安装完成，即将开始配置Apache"
        read -t 30 -p "是否需要自动配置" autoConfig

        if ["$autoConfig" = "y"] 
            then
            echo -e "\e$longSleepTime""后开始配置apache！"
            sleep "$longSleepTime"
            
            cp "$prefix""apache24/conf/httpd.conf" "$prefix""apache24/conf/httpd.conf_back"
            echo -e "\n添加独立配置文件"
            echo -e "\nInclude conf/gukoo.conf" >> "$prefix""apache24/conf/httpd.conf"

            useradd apache
            # 修改配置
            (
                cat << EOF
                {
                    User apache
                    Group apache
                    AddType application/x-httpd-php .php
                    AddType application/x-httpd-php-source .php5

                    <IfModule dir_module>
                        DirectoryIndex index.html index.php
                    </IfModule>

                    <Files ".ht*">
                        Require all granted
                    </Files>

                    ServerName 127.0.0.1:80
                    LoadModule rewrite_module modules/mod_rewrite.so
                    Include conf/extra/httpd-vhosts.conf 
                }
                EOF
            ) > "$prefix""apache24/conf/gukoo.conf"

            # 为apache赋予用户组
            chown -R apache:apache "$prefix""apache24"
            echo -e "\nphp apache 配置完毕"

            read -t 30 -p "是否安装mysql : " useMysql

            # 安装mysql
            if [$useMysql = "y"] 
                then

                # 判断是否为linux2.6 ，如果是则安装mariadb5.5，否则安装10.1
                if [$(cat /proc/version |grep "Linux version 2.6") != ""] 
                    then
                    wget -O "mariadb.tar.gz" https://downloads.mariadb.org/f/mariadb-5.5.56/source/mariadb-5.5.56.tar.gz/from/http%3A//mirrors.tuna.tsinghua.edu.cn/mariadb/?serve
                else
                    wget -O "mariadb.tar.gz" https://downloads.mariadb.org/f/mariadb-10.1.23/source/mariadb-10.1.23.tar.gz/from/http%3A//mirrors.tuna.tsinghua.edu.cn/mariadb/?serve
                fi

                # 得到当前目录并赋值，用以回到源码目录
                nowDir=$(pwd)
                # 解压文件到本地的mysql目录
                tar xzvf "mariadb5.5.tar.gz" -C "./mysql"
                # 进入目录
                cd "./mysql"
                
                # cmake填写参数与安装
                cmake -DCMAKE_INSTALL_PREFIX="$prefix"mysql -DMYSQL_DATADIR="$prefix"mysql/data
                make && make install
                # 安装完毕，进入安装目录
                cd "$prefix""mysql"

                # 添加用户并且切换用户与组
                useradd -r mysql
                chown -R mysql:mysql ./mysql
                # 删除旧的配置文件
                rm /etc/my.cnf

                # 赋予执行用户
                ./scripts/mysql_install_db --user=mysql

                # 收回权限
                chown -R root ./*
                chown -R mysql ./data

                # 回到源码目录
                cd "$nowDir"

                read -t 0 -p "php mysql apache 都已经安装与配置完成了，是否需要立即启动他们？ : y or n " boot

                if ["$boot" = "y"] 
                    then
                    $("$prefix"mysql/bin/mysqld_safe --user=mysql &)
                    $("$prefix"apache24/bin/httpd -k start)
                else    
                    echo "安装结束，源码下载目录为 : " "$(pwd)"
                    echo "安装结束，安装目录为 : " "$prefix" "\n"
                    exit 0        
                fi
            else
                echo "安装结束，源码下载目录为 : " "$(pwd)"
                echo "安装结束，安装目录为 : " "$prefix" "\n"
                exit 0
            fi
        else 
            echo "安装结束，源码下载目录为 : " "$(pwd)"
            echo "安装结束，安装目录为 : " "$prefix" "\n"
            exit 0    
        fi
    else
        echo "安装结束，源码下载目录为 : " "$(pwd)"
        exit 0
    fi