#!/usr/bin/env bash
sudo rpm -ivh http://dl.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm
sudo yum install ansible -y

cat >> /etc/hosts << "EOL"
192.168.30.1 Test1 #HAPROXY
192.168.30.2 Test2 #NGINX
192.168.30.3 Test3 #NGINX
192.168.30.4 controller #ANSIBLE
EOL
