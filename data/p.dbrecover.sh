#!/bin/bash

DATABASE='ttrade_production'
USER='root'
PASSWD='root'

mysql -hlocalhost -u$USER -p$PASSWD $DATABASE < $1 

