# -*- mode: ruby -*-
# vi: set ft=ruby :

# add or remove nodes here
AGENTS=["websrv","test"]

GITHUB_KEY="~/.ssh/id_rsa.git"

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

SUBNET="192.168.128"
DOMAIN="vm.local"

MASTERNAME="puppetmaster"
MASTERIP="#{SUBNET}.2"

DBNAME="puppetdb"
DBIP="#{SUBNET}.3"

REPORTSNAME="puppetreports"
REPORTSIP="#{SUBNET}.4"

Vagrant.configure VAGRANTFILE_API_VERSION do |config|
  config.vm.provider "virtualbox" do |v|
    v.memory = 1024
    v.cpus = 1
  end
  config.vm.box = "geerlingguy/centos7"  
  config.vm.provision :hosts do |prov|
    prov.autoconfigure = true
    prov.sync_hosts = true
    prov.add_localhost_hostnames = false
    prov.add_host '10.10.109.208', ['github.rackspace.com']
  end
  config.vm.provision "shell", inline: <<-EOF

    echo "generating dummy ssl certificate"
    openssl req \
      -x509 \
      -nodes \
      -days 365 \
      -newkey rsa:2048 \
      -keyout /etc/ssl/localtest.key \
      -out /etc/ssl/localtest.crt \
      -subj '/C=DE/ST=Town/L=Baz/O=BAR/OU=FOO/CN=IT'
    cat /etc/ssl/localtest.crt /etc/ssl/localtest.key > /etc/ssl/localtest.pem
EOF
  # don't change this destination, it's handled in bootstrap_centos.sh
  config.vm.provision "file", source: "#{GITHUB_KEY}", destination: "/tmp/id_rsa"
  config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"
  # workaround because of this Vagrant 1.8.5 issue (only on rhel-like distribs) => https://github.com/mitchellh/vagrant/issues/7610
  config.ssh.insert_key = false
  config.vm.define :puppetmaster do |pm|
    pm.vm.hostname = "#{MASTERNAME}.#{DOMAIN}"
    pm.vm.network :private_network, ip: "#{MASTERIP}"
    pm.vm.synced_folder "r10k/", "/etc/puppetlabs/code/environments/production"
#    pm.vm.synced_folder "r10k/", "/opt/r10k"
#    pm.vm.provision "file", source: "./r10k", destination: "/opt/r10k"
#    pm.vm.network :forwarded_port, guest: 5000, host: 5000
    pm.vm.provision :shell, :path => "bootstrap_centos.sh"
    pm.vm.provider "virtualbox" do |v|
      v.memory=2048
      v.cpus=2
    end
  end

#  config.vm.define :puppetdb do |pm|
#    pm.vm.hostname = "#{DBNAME}.#{DOMAIN}"
#    pm.vm.network :private_network, ip: "#{DBIP}" 
#    pm.vm.provision :shell, :path => "install_agent_centos.sh"
#    pm.vm.provision :hosts do |prov|
#      prov.vm.provision.autoconfigure = true
#      prov.vm.provision.sync_hosts = true
#      prov.add_host '10.10.109.208', ['github.rackspace.com']
#    end
#  end

#  config.vm.define :puppetreports do |pm|
#    pm.vm.hostname = "#{REPORTSNAME}.#{DOMAIN}"
#    pm.vm.network :private_network, ip: "#{REPORTSIP}" 
#    pm.vm.network :forwarded_port, guest: 5000, host: 5001
#    pm.vm.provision :shell, :path => "install_agent_centos.sh"
#    pm.vm.provision :hosts do |prov|
#      prov.vm.provision.autoconfigure = true
#      prov.vm.provision.sync_hosts = true
#      prov.add_host '10.10.109.208', ['github.rackspace.com']
#    end
#  end

  AGENTS.each_with_index do |agent,index|
    config.vm.define "#{agent}".to_sym do |ag|
        ag.vm.hostname = "#{agent}.#{DOMAIN}"
        ag.vm.network :private_network, ip: "#{SUBNET}.#{index+10}"
        ag.vm.provision :shell, :path => "install_agent_centos.sh"
        #ag.vm.synced_folder "~/.ssh", "/home/vagrant/.ssh"
    end
  end  

end
