#!/bin/bash

TODAY=`date +"%Y-%m-%d"`
DATABASE='ttrade_development'
USER='root'
PASSWD='root'

mysql -hlocalhost -u$USER -p$PASSWD $DATABASE < $1 

