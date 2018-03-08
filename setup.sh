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
    elif [ "$1" = 10  ]; then 
        warning "$2"
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

## Installing Java
yum install java -y &>>$LOG 
Stat $? "Installing Java"

el_install() {
    ## Installing Elastic Search
    URL="https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-$VERSION.rpm"
    rpm -q elasticsearch &>>$LOG 
    if [ $? -eq 0 ]; then 
        Stat 10 "Elastic Search already installed"
    else 
        yum install $URL -y &>>$LOG
        Stat $? "Installing Elastic Search"
    fi

    ps -ef | grep '/etc/elasticsearch' | grep -v grep &>>$LOG 
    if [ $? -eq 0 ]; then 
        Stat 10 'Elastic Search already running'
    else 
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
    fi
}


ls_install() {
    ## Installing LogStash 
    URL="https://artifacts.elastic.co/downloads/logstash/logstash-$VERSION.rpm"
    rpm -q logstash &>>$LOG 
    [ $? -eq 0 ] && Stat 10 'LogStash already installed' && return
    yum install $URL -y &>>$LOG
    Stat $? "Installing LogStash"
}

ls_start() {
    systemctl enable logstash &>>$LOG 
    systemctl start logstash 
    Stat $? "Starting LogStash"
}


el_install
ls_install 
ls_start