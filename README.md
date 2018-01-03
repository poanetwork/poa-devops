## DevOps scripts

### Setup blockchain backup from a node:
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

6. install `ansible`:
```
pip install ansible
```

7. create `group_vars/all` file:
```
cp group_vars/all.example group_vars/all
```
and set the following variables in it:
* `poa_role` - node's role (one of `bootnode`, `validator`, `moc`, `explorer`, `netstat`)
* `access_key` - s3 access key
* `secret_key` - s3 secret key
* `s3_bucket` - s3 bucket name 

8. create `hosts` file:
```
cp hosts.example hosts
```
and set it to run on localhost:
```
[backup]
localhost
```

9. run playbook (still, do this on the node)
```
ansible-playbook -i hosts -c local site.yml
```

10. if all is well, setup a cronjob to run every hour:
```
crontab -e
```
append the following line:
```
30 * * * * /bin/bash /root/poa-devops/cron-bkp-blockchain.sh
```
