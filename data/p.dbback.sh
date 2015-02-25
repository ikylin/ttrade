#!/bin/bash

TODAY=`date +"%Y-%m-%d_%H%M%S"`
DATABASE='ttrade_production'
USER='root'
PASSWD='root'

TRADEDATE=`mysql -u$USER -p$PASSWD $DATABASE <<EOF | tail -n +2
SELECT cfgdate FROM sysconfigs where(cfgname = 'marketdate');
EOF`

mysqldump --opt --default-character-set=utf8 --lock-all-tables -hlocalhost -u$USER -p$PASSWD -d $DATABASE > "./data/prod.${TODAY}-c-$TRADEDATE.sql"

mysqldump --default-character-set=utf8 --lock-all-tables -hlocalhost -u$USER -p$PASSWD -tc $DATABASE > "./data/prod.${TODAY}-d-$TRADEDATE.sql"

mysqldump --default-character-set=utf8 --lock-all-tables -hlocalhost -u$USER -p$PASSWD $DATABASE > "./data/prod.${TODAY}-a-$TRADEDATE.sql"


