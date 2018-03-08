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
yum install $URL &>>$LOG
Stat $?
