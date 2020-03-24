## Vagrant environement for puppet

Configure a puppet development/demo environment with the following components:
- puppetmaster, puppetdb and puppetboard (either on a single VM or multiple ones)
- additional nodes to test agents
- this repository consists of a Vagrantfile defining several possible hosts and bootstrap scripts to install master and agents
- all the configuration is done via puppet via r10k sync'd locally

### Bootstrap the puppetmaster in standalone mode
This installation provides a master with puppetdb and puppetboard on single VM. To use this, your master node needs to have the role **role::master_standalone**. See _r10k/blob/production/manifests/nodes.pp_ for role assignment and _r10k/tree/production/site/role/manifests_ for role list. To change the master role (standalone or not) you will have to fork the puppet-r10k repo, modify theses files and update the r10k configuration in the bootstrap script to use your repo.

* Install virtualbox and vagrant
* Clone vagrant files
* Go into puppet env, create puppet master and configure it (default box: boxcutter/ubuntu1604)
```
cd vagrant-puppet
vagrant up puppetmaster
```  
*Details about virtual machines are in the Vagrantfile (private network for puppet, port redirection for puppetboard, hosts file)*
* When the vm boots for the first time, vagrant provisioning kicks in using **bootstrap.sh**.
Main steps:
    - Configuring EPEL & puppetlabs repo
    - Installing puppet, rubygems and git
    - Install hiera-eyaml and copy sample keys. _This is for test purposes only._
    - Creating hiera.yaml (simple conf, see bootstrap.sh content)
    - Installing r10k gem
    - Deploying with r10k via {{r10k puppetfile}}
    - Performing first puppet run (puppetmaster role configures puppet master, puppetdb)

After a few minutes everything should ready.


### Bootstrap the puppetmaster with separate puppetdb and Puppetboard
Setting up the master is similar to standalone but the node needs the role **role::master** and you need a node with role **role::puppetdb** and optionnally one with role **role::puppetreports**. The assignment of the VM created by vagrant and their roles can be found at _r10k/blob/production/manifests/nodes.pp_
```
node 'puppetmaster' {
  include role::master
}
node 'puppetdb' {
  include role::puppetdb
}
node 'puppetreports' {
  include role::puppetreports
}
```
1. Create the puppetmaster: ```vagrant up puppetmaster```
2. Create the puppetdb: ```vagrant up puppetdb```. This will install the agent and perform a first puppet run against the master. It will trigger warnings because the master is configured to use puppetdb (see the master profile) but this role is not available *yet*. You will not need to sign the node certificates because autosigned is configured on the master for puppetdb and puppetreports (autosign.conf is created by the master profile using data for hiera: https://github.com/cringdahl/puppet-r10k/blob/production/hieradata/nodes/puppetmaster.vm.local.yaml)
3. Create the puppetreports node  ```vagrant up puppetreports```
4. You can now access puppetboard at http://localhost:5001


### Add client virtual machines
websrv and test are configured in Vagrantfile (very easy to add new ones): same private network setup, hosts file configuration, no puppet
1. Change site.pp, add profiles to websrv node.
2. Create VM: ``` vagrant up websrv```. This will install the agent. The puppetmaster is configured to autosign all hosts. _This is for test purposes only._


### Support for hiera-eyaml
This setup includes hiera-eyaml

- During the bootstrap the hiera-eyaml gem is installed and the hiera.yaml is configured to support the eyaml backend
- To create your own keys, install the hiera-eyaml gem and simply run ```eyaml createkeys```
- Keys are copied to /var/lib/puppet/secure/keys
- The hieradata on github refered to in the r10k configuration contains an encrypted content
- To create an eyaml encrypted string use ```eyaml encrypt -s "Message"```
- Then simply add the output to a hiera yaml file
```
key: >
   ENC[PKCS7,...]
```
- The base profile contains a notice that will show the decrypted content in all runs


### Snapshot fresh install
If you want to be able to go back to a clean puppetmaster, db and or reports (fresh from install, without having to do the full provisioning)
1. Install snaphost plugin
```
vagrant plugin install vagrant-vbox-snapshot
```
2. Snapshot VM:
```
vagrant snapshot take puppetmaster freshinstall
```
3. After this you can go back to the snaphost if needed:
```
vagrant snapshot go puppetmaster freshinstall
```
You can find more information here: https://github.com/dergachev/vagrant-vbox-snapshot

### Installing Puppet Modules
If you have private modules you need installed, you can scp them to your puppetmaster.
1. Install scp plugin
```
vagrant plugin install scp
```
2. Transfer the directory.
```
vagrant scp /path/to/directory/or/file puppetmaster:.
```
3. Login and mv the directory, or run a puppet module install.