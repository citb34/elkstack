#!/bin/bash

VERSION=5.5.3
LOG=/tmp/elklog
rm -f $LOG

## Source Common Functions
curl -s "https://raw.githubusercontent.com/linuxautomations/scripts/master/common-functions.sh" >/tmp/common-functions.sh
#source /root/scripts/common-functions.sh
source /tmp/common-functions.sh

Stat() {
    if [ "$1" = 0 ];then 
        success "$2"
    else 
        error "$2"
        exit 1
    fi
}

## Checking Root User or not.
CheckRoot

## Checking SELINUX Enabled or not.
CheckSELinux

## Checking Firewall on the Server.
CheckFirewall

## Installing Elastic Search
URL="https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-$VERSION.rpm"
yum install $URL -y &>>$LOG
Stat $? "Installing Elastic Search"
systemctl enable elasticsearch &>$LOG 
systemctl start elasticsearch 
i=0
while [ $i -lt 10 ] ; do 
    netstat -lntp | grep 9200 &>/dev/null 
    if [ $? -eq 0 ]; then 
        break 
    else 
        sleep 10 
        i=$(($i+1))
    fi 
done 

curl localhost:9200 &>>$LOG 
Stat $? "Starting Elastic Search"

## Installing LogStash 
URL="https://artifacts.elastic.co/downloads/logstash/logstash-$VERSION.rpm"
yum install $URL -y &>>$LOG
systemctl enable logstash &>>$LOG 
systemctl start logstash 
Stat $? "Starting LogStash"
