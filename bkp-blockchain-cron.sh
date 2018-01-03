#!/bin/bash

#### line to add to crontab (remove leading '#')
# 30 * * * * /bin/bash /root/poa-devops/bkp-blockchain-cron.sh
####

set -e
set -u
set -o

OUT_FILE="logs/bkp-blockchain.out"
ERR_FILE="logs/bkp-blockchain.err"

cd /root/poa-devops

echo "Starting at $(date -u)" >> $OUT_FILE
echo "Starting at $(date -u)" >> $ERR_FILE

# actual command
/usr/local/bin/ansible-playbook -i hosts -c local site.yml >> $OUT_FILE 2>> $ERR_FILE

echo "" >> $OUT_FILE
echo "" >> $ERR_FILE
