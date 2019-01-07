## Make a spec.json hard-fork
0. this guide assumes that you're running this playbook from the same machine you used to make initial deployment of your node. So that you already have `python` and `ansible` installed, and you have the correct ssh keypair to root-access the node.

1. if you already have a cloned version of this repository, pull latest changes:
```
cd poa-devops
git pull origin master
```

otherwise, clone this repository:
```
git clone https://github.com/poanetwork/poa-devops.git
cd poa-devops
```

2. create `group_vars/all` file:
```
cp group_vars/hf-spec-change.example group_vars/all
```
and set the following variables:
* `poa_role` - node's role (one of `bootnode`, `validator`, `moc`, `explorer`, `netstat`)
* `MAIN_REPO_FETCH` - github account where spec.json is located (e.g. `poanetwork`)
* `GENESIS_BRANCH` - correct network name (`sokol` for testnet, `core` for mainnet, `dai` for xdai-chain)

3. create/edit `hosts` file:
```
echo "" > hosts
```
and put your node's ip address (assuming it's 192.0.2.1) in the following way:
```
[hf-spec-change]
192.0.2.1
```
make sure you don't have other tags (`[...]`) in hosts file

**NOTE** for those who host multiple nodes:
* if all your nodes are of the same role (e.g. all bootnodes), you can run this playbook on all of them by listing their ips, e.g.
```
[hf-spec-change]
192.0.2.1
192.0.2.2
192.0.2.3
192.0.2.4
```
* if you host nodes of different types you can set `poa_role` individually against the corresponding ip address like so:
```
[hf-spec-change]
192.0.2.1 poa_role=explorer
192.0.2.2
192.0.2.3 poa_role=moc
192.0.2.4
```
on lines where you omitted explicit `poa_role`, the value from `group_vars/all` is used.

4. run the playbook:
```
ansible-playbook -i hosts site.yml
```

**NOTE** if you're getting ssh connection error, try to add option `-e 'ansible_ssh_user=ubuntu'` to the command line above, substituting `ubuntu` with correct ssh username, which is usually either `ubuntu` or `root` or `poa` or `centos` depending on your setup

5. verify that your node is active in the netstat of the corresponding network (https://sokol-netstat.poa.network/ for `sokol` or https://core-netstat.poa.network/ for `core`)

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
