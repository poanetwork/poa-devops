## Update bootnodes.txt

0. this guide assumes that you're running this playbook from the same machine that you used to make initial deployment of your node. So that you already have `python` and `ansible` installed, and you have the correct ssh keypair to root-access the node.

### Running the update
1. clone this repository if you haven't done so before
```
git clone https://github.com/poanetwork/poa-devops.git
cd poa-devops
```
or pull the latest changes
```
cd poa-devops
git pull origin master
```

2. create `group_vars/all` file:
```
cp group_vars/upd-bootnodes-txt.example group_vars/all
```
and change the following variables:
* `poa_role` - role of the node on the network (one of `bootnode`, `validator`, `moc`, `explorer`)
* `GENESIS_BRANCH` - either `"sokol"` for testnet or `"core"` for mainnet

don't change other options

3. create/edit `hosts` file and put your node's ip address (assuming it's 192.0.2.1) there with the following header:
```
[upd-bootnodes-txt]
192.0.2.1
```
**NOTE**: if you're updating an existing file, make sure you remove other tags `[...]` and ips.

4. run the playbook:
```
ansible-playbook -i hosts upd-bootnodes-txt.yml
```

### Verifying the update
0. playbook run should be completed without errors

1. open network statistic webpage:
  - for sokol test network: https://sokol-netstat.poa.network
  - for core main network: https://core-netstat.poa.network

check that your node is "green" and is catching new blocks. It may take 2-3 minutes to fully start and reconnect. Check how many peers you have.

### Rollback to the previous version (in case of problems)
**NOTE**: if you get any errors please consult the POA Team first, probably you have a minor issue and don't need to rollback

1. connect to the node:
```
ssh root@192.0.2.1
```

2. switch to your home folder (replace `bootnode` with correct role name):
```
cd /home/bootnode
```

3. stop services:
```
systemctl stop poa-netstats
systemctl stop poa-parity
```

4. locate the backup folder:
```
ls backups-bootnodes.txt
```
it contains folders labeled by the time backup was created in format`<year><month><day>T<hour><minute><second>`, e.g.
```
# ls backups-bootnodes.txt
20180208T152105 20180209T214517
```
copy the version number that corresponds to this day. In the following examples we assume that it's `20180209T214517`.

5. restore previous versions of these files from backup (note dots `.` at the end of each line here, they are important):
```
cp -a backups-bootnodes.txt/20180209T214517/bootnodes.txt .
```

6. restart services
```
systemctl restart poa-parity
systemctl restart poa-netstats
```

7. open network statistic webpage:
  - for sokol test network: https://sokol-netstat.poa.network
  - for core main network: https://core-netstat.poa.network

check that your node is "green" and is catching new blocks. It may take 2-3 minutes to fully start and reconnect.
