# -*- mode: ruby -*-
# vi: set ft=ruby :

# add or remove nodes here
#AGENTS=["test"]
AGENTS=[]
# Define one node for SSL web, localhost:8443
AGENT_8443="websrv"

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
  # creating dummy ssl certs for use by application software (e.g. nginx)
  config.vm.provision "shell", inline: <<-EOF

    echo "generating dummy san config"
    cat > /tmp/req.conf << THIS
[req]
distinguished_name = req_distinguished_name
x509_extensions = v3_req
prompt = no
[req_distinguished_name]
C = US
ST = MN
L = Localcity
O = LocalCo
OU = Localdiv
CN = localhost
[v3_req]
keyUsage = keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names
[alt_names]
DNS.1 = www.localhost
THIS

    echo "generating dummy ssl certificate"
    openssl req \
      -x509 \
      -nodes \
      -days 365 \
      -newkey rsa:2048 \
      -config /tmp/req.conf \
      -extensions 'v3_req' \
      -keyout /etc/ssl/localtest.key \
      -out /etc/ssl/localtest.crt
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
    pm.vm.synced_folder "r10k/", "/opt/r10k"
#    pm.vm.network :forwarded_port, guest: 5000, host: 5000
    pm.vm.provision :shell, :path => "bootstrap_centos.sh"
    pm.vm.provider "virtualbox" do |v|
      v.memory=2048
      v.cpus=2
    end
  end

# In the unlikely event you want a separate puppetdb node, uncomment the following
#  config.vm.define :puppetdb do |pm|
#    pm.vm.hostname = "#{DBNAME}.#{DOMAIN}"
#    pm.vm.network :private_network, ip: "#{DBIP}" 
#    pm.vm.provision :shell, :path => "install_agent_centos.sh"
#    end
#  end

# In the unlikely event you want a puppetreports server, uncomment the following
#  config.vm.define :puppetreports do |pm|
#    pm.vm.hostname = "#{REPORTSNAME}.#{DOMAIN}"
#    pm.vm.network :private_network, ip: "#{REPORTSIP}" 
#    pm.vm.network :forwarded_port, guest: 5000, host: 5001
#    pm.vm.provision :shell, :path => "install_agent_centos.sh"
#    end
#  end
  config.vm.define "#{AGENT_8443}".to_sym do |ag|
      ag.vm.hostname = "#{AGENT_8443}.#{DOMAIN}"
      ag.vm.network :private_network, ip: "#{SUBNET}.9"
      ag.vm.network :forwarded_port, guest: 8443, host: 8443
      ag.vm.provision :shell, :path => "install_agent_centos.sh"
  end
  AGENTS.each_with_index do |agent,index|
    config.vm.define "#{agent}".to_sym do |ag|
        ag.vm.hostname = "#{agent}.#{DOMAIN}"
        ag.vm.network :private_network, ip: "#{SUBNET}.#{index+10}"
        ag.vm.provision :shell, :path => "install_agent_centos.sh"
    end
  end
end
