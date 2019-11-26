#!/bin/sh
###################################################################
# Script Name	: InstallUnifi.sh                                                                                             
# Description	: Install Script for Unifi on Ubuntu 18.04LTS                                                                             
# Args       	:                                                                                         
# Author     	: Julien Mousqueton                                                 
# Twitter    	: @JMousqueton                                           
###################################################################

sudo apt-key adv --keyserver keyserver.ubuntu.com --recv 06E85760C0A52C50 
echo 'deb https://www.ui.com/downloads/unifi/debian stable ubiquiti' | sudo tee /etc/apt/sources.list.d/100-ubnt-unifi.list
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0C49F3730359A14518585931BC711F9BA15703C6
echo "deb https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.4.list
sudo apt update
sudo apt upgrade
sudo apt install ca-certificates apt-transport-https certbot fail2ban ufw python3-certbot-nginx nginx unifi -y 
sudo apt autoremove

#### NGINX Configuration 
echo -n "Enter your domain name [my.fqdn.com]: "
read NAME
       systemctl stop nginx
    echo -e "server {\n\
        listen 80;\n\
        server_name $NAME;\n\
        error_log /var/log/unifi/nginx.log;\n\
        proxy_cache off;\n\
        proxy_store off;\n\
        location / {\n\
        proxy_cookie_domain $NAME \$host;\n\
        sub_filter $NAME \$host;\n\
        proxy_set_header X-Real-IP \$remote_addr;\n\
        proxy_set_header HOST \$http_host;\n\
        proxy_pass https://localhost:8443;\n\
        }\n\
        }\n\
        " > /etc/nginx/sites-enabled/default
    echo "Waiting 10 seconds for nginx start ... "
    sleep 10
    sudo systemctl start nginx 
    sudo ufw allow 22/tcp 
    sudo ufw allow http
    sudo ufw allow https 
    sudo ufw enable
    certbot -d $NAME --nginx
    sudo service nginx restart
    sudo apt install postfix mailutils -y
