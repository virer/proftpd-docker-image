#!/bin/sh

if test -e /etc/sftp-config/ftp.passwd; then cat /etc/sftp-config/ftp.passwd > /usr/local/etc/ftp/ftp.passwd 
if test -e /etc/sftp-config/ftp.group;  then cat /etc/sftp-config/ftp.group > /usr/local/etc/ftp/ftp.group 

/usr/local/sbin/proftpd -n -c /usr/local/etc/proftpd/proftpd.conf

# EOF