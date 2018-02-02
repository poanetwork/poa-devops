## Update scripts on validator nodes

**ONLY FOR VALIDATOR NODES**

0. this guide assumes that you're running this playbook from the same machine you used to make initial deployment of your node. So that you already have `python` and `ansible` installed, and you have the correct ssh keypair to root-access the node.

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
cp group_vars/upd-scripts-validator.example group_vars/all
```
and set the following variables:
* `MAIN_REPO_FETCH` - github account where spec.json is located (e.g. "poanetwork")
* `SCRIPTS_VALIDATOR_BRANCH` - correct branch name to fetch from (e.g. "sokol" for testnet, "core" for mainnet)

3. create/edit `hosts` file:
```
echo "" > hosts
```
and put your node's ip address (assuming it's 192.0.2.1) there with the following header:
```
[upd-scripts-validator]
192.0.2.1
```

4. run the playbook:
```
ansible-playbook -i hosts site.yml
```

5. connect to the node
```
ssh root@192.0.2.1
```
switch to the home folder:
```
cd /home/validator
```
and check the update time of `poa-scripts-validator` folder (should be about the time you started the playbook)
```
ls -lh
# a long list should appear here, look for poa-scripts-validator in the rightmost column and check the date and time on the same row
```
also check that backup was created:
```
ls -lh backups-scripts-validator/
# look for a file named similar to poa-scripts-validator-20180202-184912.json Numbers represent date and time in UTC when the playbook was started
```

6. wait 2 hours and check that balance of your payout key gets updated
