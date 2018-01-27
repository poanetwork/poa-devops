## Setup blockchain backup on a node
1. connect to the node as `root`.

2. clone this repository to `root`'s home folder:
```
git clone https://github.com/poanetwork/poa-devops.git
```

3. make sure `python` (v2.6+ or v3.5+) is installed on the node.

4. install `pip` and/or upgrade it to the newest version:
```
apt-get install python-pip
pip install --upgrade pip
```

5. upgrade `setuptools` to the newest version:
```
pip install --upgrade setuptools
```

6. install `boto` and `boto3` packages:
```
pip install boto boto3
```

7. install `ansible`:
```
pip install ansible
```

8. create `group_vars/all` file:
```
cp group_vars/backup-parity.example group_vars/all
```
and set the following variables:
* `poa_role` - node's role (one of `bootnode`, `validator`, `moc`, `explorer`, `netstat`)
* `backup_parity_data` - `true`/`false` - backup whole `parity_data` folder "as is" or not (default: `true`)
* `backup_parity_blocks` - `true`/`false` - use or not `parity export blocks` to create a file with exported blocks and backup it (default: `true`)
* `access_key` - s3 access key
* `secret_key` - s3 secret key
* `s3_bucket` - s3 bucket name
* `node_name` - short descriptive name of the node (e.g. `sokol-arche`). It will be used as part of a backup file name, so it must be lowercase, must not contain spaces, commas, etc

9. create `hosts` file:
```
touch hosts
```
and set it to run `backup` on localhost:
```
[backup]
localhost
```

10. run playbook (still, do this on the node)
```
ansible-playbook -i hosts -c local site.yml
```

11. if all is well, setup a cronjob to run every hour:
```
crontab -e
```
append the following line:
```
30 * * * * /bin/bash /root/poa-devops/bkp-blockchain-cron.sh
```

12. configure logrotate to archive old log files. Create file `/etc/cron.hourly/poa-devops-logrotate` with the following content:
```
#!/bin/bash
/usr/sbin/logrotate /root/poa-devops/bkp-blockchain-logrotate.conf
```
and set permission to run it:
```
chmod 755 /etc/cron.hourly/poa-devops-logrotate
```

## How to restore from the backup

### Restore from `parity_data`
_Must be done under `root` account_

0. place backup file to the user's home directory, e.g. `/home/bootnode` (or `/home/moc`, etc)

1. stop netstats (if it's installed) and parity
```
# may fail if netstats is not installed, ignore it then:
systemctl stop poa-netstats
systemctl stop poa-parity
```

2. backup your current `parity_data`
```
# replace bootnode with other role's name if necessary (e.g. moc, validator, etc)
cd /home/bootnode
mv parity_data parity_data.bkp.$(date -u +%Y%m%d-%H%M%S)
```

3. unpack `parity_data` folder from backup
```
# exact filename will be different
tar -xzf 20180127-134045-bootnode-sokol-archive-parity_data.tar.gz
```

4. make sure that `bootnode` (or `moc`, etc) is owner of the unpacked directory
```
ls -lh
```
check owner of the `parity_data`, if it's another user, run
```
# replace bootnode with correct user name if necessary (e.g. moc, validator, etc)
chown -R bootnode:bootnode parity_data
```

5. restart parity and netstats (if it's installed)
```
systemctl start poa-parity
# unnecessary if netstats is not installed:
systemctl start poa-netstats
```

6. open `NETSTATS_URL` in your browser to see if node is up and accepts blocks. If not, explore parity logs in `/home/bootnode/logs/parity.log` or try to start parity manually to see if it fails at startup:
```
# assuming you're still in home folder
./parity --config node.toml
```

### Restore from `parity_blocks`
Parity docs: https://github.com/paritytech/parity/wiki/FAQ:-Backup,-Restore,-and-Files#how-do-i-backup-my-blockchain

_Must_ be done under `root` account_

0. place backup file to the user's home directory, e.g. `/home/bootnode` (or `/home/moc`, etc)

1. stop netstats (if it's installed) and parity
```
# may fail if netstats is not installed, ignore it then:
systemctl stop poa-netstats
systemctl stop poa-parity
```

2. backup your current `parity_data`
```
# replace bootnode with other role's name if necessary (e.g. moc, validator, etc)
cd /home/bootnode
cp -a parity_data parity_data.bkp.$(date -u +%Y%m%d-%H%M%S)
```

3. remove current chain
```
rm -rf parity_data/cache parity_data/chains
```

4. unpack `parity_blocks.rlp` file from backup
```
# exact filename will be different
gunzip 20180127-134045-bootnode-sokol-archive-parity_blocks.rlp.gz
```

5. import blocks from backup
```
./parity --config node.toml import 20180127-134045-bootnode-sokol-archive-parity_blocks.rlp
```

6. make sure that `bootnode` (or `moc`, etc) is owner of `parity_data` and all its subfolders, most importantly newly created `parity_data/cache` and `parity_data/chains`
```
ls -lh
ls -lh parity_data
```
if owner is another user, run
```
# replace bootnode with correct user name if necessary (e.g. moc, validator, etc)
chown -R bootnode:bootnode parity_data
```

7. restart parity and netstats (if it's installed)
```
systemctl start poa-parity
# unnecessary if netstats is not installed:
systemctl start poa-netstats
```

8. open `NETSTATS_URL` in your browser to see if node is up and accepts blocks. If not, explore parity logs in `/home/bootnode/logs/parity.log` or try to start parity manually to see if it fails at startup:
```
# assuming you're still in home folder
./parity --config node.toml
```
