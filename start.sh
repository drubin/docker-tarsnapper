#!/bin/bash
GLOBIGNORE="*"

RANDOM_BACKUP_HOUR=`shuf -i 0-23 -n 1`
RANDOM_EXPIRE_HOUR=`shuf -i 0-23 -n 1`
RANDOM_BACKUP_MINUTE=`shuf -i 1-59 -n 1`
RANDOM_EXPIRE_MINUTE=`shuf -i 1-59 -n 1`

BACKUP_CRON=${BACKUP_CRON:-"$RANDOM_BACKUP_MINUTE $RANDOM_BACKUP_HOUR * * *"}
EXPIRE_CRON=${EXPIRE_CRON:-"$RANDOM_EXPIRE_MINUTE $RANDOM_EXPIRE_HOUR * * *"}

cat << EOF > /etc/cron.d/tarsnapper
$BACKUP_CRON root /tarsnapper-backup.sh >> /var/log/cron.log 2>&1
EOF
cat << EOF >> /etc/cron.d/tarsnapper
$EXPIRE_CRON root /tarsnapper-expire.sh >> /var/log/cron.log 2>&1

EOF

[ -n "$JOB_NAME" ] && sed -i "s/mybackup/$JOB_NAME/" /etc/tarsnapper.conf
[ -n "$DELTA" ] && sed -i "s/1d 7d 30d/$DELTA/" /etc/tarsnapper.conf

chmod 0644 /etc/cron.d/tarsnapper
touch /var/log/cron.log

cron && tail -f /var/log/cron.log