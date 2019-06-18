## Update parity to a newer version

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
cp group_vars/upd-parity-version.example group_vars/all
```
and change the following variables:
* `poa_role` - role of the node on the network (one of `bootnode`, `validator`, `moc`, `explorer`)
* `GENESIS_BRANCH` - either `"sokol"` or `"core"` or `"dai"` or `"kovan"` depending which network you're updating

don't change other options

3. create/edit `hosts` file and put your node's ip address (assuming it's 192.0.2.1) there with the following header:
```
[upd-parity-version]
192.0.2.1
```
**NOTE**: if you're updating an existing file, make sure you remove other tags `[...]` and ips.

4. run the playbook (change user: ubuntu to your user name, if necessary):
```
ansible-playbook -i hosts upd-parity-version.yml
```
**NOTE** if you're getting ssh connection error, try to add option `-e 'ansible_ssh_user=ubuntu'` to the command line above, substituting `ubuntu` with correct ssh username, which is usually either `ubuntu` or `root` or `poa` or `centos` depending on your setup. You may also need to specify exact path to your ssh private key with `--key-file=/path/to/private.key` cli option.

### Verifying the update
0. playbook run should be completed without errors

1. open network statistic webpage:
  - for sokol test network: https://sokol-netstat.poa.network
  - for core main network: https://core-netstat.poa.network
  - for dai network: https://dai-netstat.poa.network
  - for kovan network: https://kovan-netstat.poa.network

check that your node is "green" and is catching new blocks. It may take 5-6 minutes to fully start and reconnect

2. connect to the node
```
ssh root@192.0.2.1
```
and check parity version (replace `bootnode` with correct role name ,e.g. `validator`):
```
/home/bootnode/parity --version
```
sample output (version number may be different):
```

```
```
Parity Ethereum
  version Parity-Ethereum/v2.4.6-stable-94164e1-20190514/x86_64-linux-gnu/rustc1.34.1
Copyright 2015-2019 Parity Technologies (UK) Ltd.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

By Wood/Paronyan/Kotewicz/Drwięga/Volf
   Habermeier/Czaban/Greeff/Gotchac/Redmann
```

3. during the following day check status of your node on network status webpage and associated functions (e.g. for validators - are block rewards still being sent from your mining key to your payout key).

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
ls backups-version
```
it contains folders labeled by the time backup was created in format`<year><month><day>T<hour><minute><second>`, e.g.
```
# ls backups-version
20190311T200132 20190614T214517
```
copy the version number that corresponds to this day. In the following examples we assume that it's `20180209T214517`.

5. make sure you have your mining key data (keyfile, password, address) available to you

6. remove files from the new version:
```
rm -rf parity_data
rm parity
rm node.toml
```

7. restore previous versions of these files from backup (note dots `.` at the end of each line here, they are important):
```
cp -a backups-version/20190614T214517/parity .
cp -a backups-version/20190614T214517/parity_data .
cp -a backups-version/20180614T214517/node.toml .
```

8. check parity version (must be previous one):
```
./parity --version
```
sample output (version number may be different):
```
Parity Ethereum
  version Parity-Ethereum/v2.3.2-beta-678138f-20190203/x86_64-linux-gnu/rustc1.31.1
Copyright 2015-2018 Parity Technologies (UK) Ltd.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

By Wood/Paronyan/Kotewicz/Drwięga/Volf
   Habermeier/Czaban/Greeff/Gotchac/Redmann
```

9. restart services
```
systemctl restart poa-parity
systemctl restart poa-netstats
```

10. open network statistic webpage:
  - for sokol test network: https://sokol-netstat.poa.network
  - for core main network: https://core-netstat.poa.network
  - for dai network: https://dai-netstat.poa.network

check that your node is "green" and is catching new blocks. It may take 2-3 minutes to fully start and reconnect
