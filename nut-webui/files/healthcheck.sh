#!/bin/bash

err_report() {
    printf "check on #%s: error detected!\n" $1
    exit 1
}

trap 'err_report $LINENO' ERR

service fcgiwrap status
service nginx status
busybox wget http://localhost -O/dev/null
busybox wget https://localhost -O/dev/null
