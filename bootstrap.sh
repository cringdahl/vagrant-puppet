echo "Configuring EPEL repo"
rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
echo "Configuring puppetlabs repo"
rpm -Uvh http://yum.puppet.com/puppet6/puppet6-release-el-7.noarch.rpm
echo "Updating yum cache"
yum check-update > /dev/null
echo "Installing puppet-agent and git"
yum install -y puppet-agent git > /dev/null 2>&1


### eyaml configuration
echo "Copying keys /var/lib/puppet/secure"
mkdir -p /var/lib/puppet/secure
cp -r /vagrant/keys /var/lib/puppet/secure
useradd puppet
chown -R puppet:puppet /var/lib/puppet/secure
chmod 0500 /var/lib/puppet/secure/keys
chmod 0400 /var/lib/puppet/secure/keys/*

echo "Establishing SSH keys for github"
touch /tmp/id_rsa # in case one hasn't been created by Vagrantfile
mkdir -p /root/.ssh 
cp /tmp/id_rsa /root/.ssh/id_rsa 
echo -e "Host *\n\tStrictHostKeyChecking no\n" >> ~/.ssh/config
chown -R root:root /root/.ssh

echo "Installing hiera-eyaml gem"
/opt/puppetlabs/puppet/bin/gem install hiera-eyaml --no-ri --no-rdoc > /dev/null

echo "Installing r10k gem"
/opt/puppetlabs/puppet/bin/gem install r10k --no-ri --no-rdoc > /dev/null

echo "Deploying with r10k"
/opt/puppetlabs/puppet/bin/r10k puppetfile install -v --puppetfile=/etc/puppetlabs/code/environments/production/Puppetfile --moduledir=/etc/puppetlabs/code/environments/production/modules

echo "Performing first puppet run"
# And remove default puppet.conf which raises warnings
/opt/puppetlabs/puppet/bin/puppet apply /etc/puppetlabs/code/environments/production/manifests --modulepath=/etc/puppetlabs/code/environments/production/modules:/etc/puppetlabs/code/environments/production/site

echo "Delete iptables rules"
sudo iptables --flush > /dev/null 2>&1

