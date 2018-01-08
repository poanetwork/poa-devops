## DevOps scripts

### 1. Setup blockchain backup from a node:
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
cp group_vars/all.example group_vars/all
```
and set the following variables:
* `poa_role` - node's role (one of `bootnode`, `validator`, `moc`, `explorer`, `netstat`)
* `access_key` - s3 access key
* `secret_key` - s3 secret key
* `s3_bucket` - s3 bucket name

you can ignore other variables in this file

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

### 2. Make a spec.json hard-fork
0. this guide assumes that you're running this playbook from the same machine you used to make initial deployment of your node. So that you already have `python` and `ansible` installed, and you have the correct ssh keypair to root-access the node.

1. clone this repository:
```
git clone https://github.com/poanetwork/poa-devops.git
cd poa-devops
```

2. create `group_vars/all` file:
```
cp group_vars/all.example group_vars/all
```
and set the following variables:
* `poa_role` - node's role (one of `bootnode`, `validator`, `moc`, `explorer`, `netstat`)
* `MAIN_REPO_FETCH` - github account where spec.json is located (e.g. "poanetwork")
* `GENESIS_BRANCH` - correct branch name to fetch from (e.g. "sokol" for testnet, "core" for mainnet)

ignore other variables in this file

3. create `hosts` file:
```
touch hosts
```
and put your node's ip address (assuming it's 192.0.2.1) there with the following header:
```
[hf-spec-change]
192.0.2.1
```

4. run the playbook:
```
ansible-playbook -i hosts site.yml
```

5. verify that your node is active in the netstat of the corresponding network

6. connect to the node
```
ssh root@192.0.2.1
```
switch to the home folder of corresponding role:
```
# substitute validator with your node's role (bootnode, moc, ...)
cd /home/validator
```
and check the update time of `spec.json` (should be about the time you started the playbook)
```
ls -lh
# a long list should appear here, look for spec.json in the rightmost column and check the date and time on the same row
```
also check that backup was created:
```
ls -lh spec-hfs/
# look for a file named similar to spec-hf-20180108-174649.json Numbers represent date and time in UTC when the playbook was started
```
