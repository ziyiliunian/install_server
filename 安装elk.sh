#!/bin/bash 
#请自行修改yum源
#by dr 
#scp ./open.repo /etc/yum.repos.d/
yum -y install java-1.8.0-openjdk
yum -y install elasticsearch
#sed -i '/# network.host: 192.168.0.1/network.host: 0.0.0.0/'  /etc/elasticsearch/elasticsearch.yml
#systemctl enable elasticsearch
#systemctl start elasticsearch

