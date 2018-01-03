#!/bin/bash

#### line to add to crontab (remove leading '#')
# 30 * * * * /bin/bash /root/poa-devops/cron-bkp-blockchain.sh
####

set -e
set -u
set -o

cd /root/poa-devops

echo "$(date -u)" >> out.txt
echo "$(date -u)" >> err.txt

# actual command
/usr/local/bin/ansible-playbook -i hosts -c local site.yml >> logs/bkp-blockchain.out 2>> logs/bkp-blockchain.err

echo "" >> out.txt
echo "" >> err.txt
