#!/bin/bash

TODAY=`date +"%Y-%m-%d"`
DATABASE='ttrade_development'
USER='root'
PASSWD='root'

TRADEDATE=`mysql -u$USER -p$PASSWD $DATABASE <<EOF | tail -n +2
SELECT cfgdate FROM sysconfigs where(cfgname = 'marketdate');
EOF`

mysqldump --opt --default-character-set=utf8 --lock-all-tables -hlocalhost -u$USER -p$PASSWD -d $DATABASE > "./data/dev.${TODAY}-d.c-$TRADEDATE.sql"

mysqldump --default-character-set=utf8 --lock-all-tables -hlocalhost -u$USER -p$PASSWD -tc $DATABASE > "./data/dev.${TODAY}-d.d-$TRADEDATE.sql"

mysqldump --default-character-set=utf8 --lock-all-tables -hlocalhost -u$USER -p$PASSWD $DATABASE > "./data/dev.${TODAY}-d.a-$TRADEDATE.sql"


