#!/bin/bash 

USERLOG="$HOME/userlog.txt"
DATETIME=$(date "+%b %d %T")
echo "${DATETIME} ${HOSTNAME}" >> $USERLOG
w | tail -n +2 | awk '{print "- "$1","$2","$3","$4","$7}' >> $USERLOG

#w | sed -n '2,$ p' | awk '{print "- "$1","$2","$3","$4","$7}' >> $USERLOG
