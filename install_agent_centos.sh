master="puppetmaster.vm.local"

echo "Installing puppet"
release=`cat /etc/centos-release | cut -d " " -f 4 | cut -d "." -f 1`

echo "Configuring puppetlabs repo"
sudo rpm -Uvh http://yum.puppet.com/puppet6/puppet6-release-el-7.noarch.rpm
echo "Updating yum cache"
sudo yum check-update > /dev/null
echo "Installing puppet-agent"
sudo yum install -y puppet-agent > /dev/null 2>&1
useradd puppet
chown -R puppet:puppet /etc/puppetlabs

echo "Run puppet"
sudo /opt/puppetlabs/puppet/bin/puppet agent -t --server $master
echo "Bootstrap done"
echo "If you saw a cert issue, sign it on master and rerun puppet agent -t --server $master"

echo "Delete iptables rules"
sudo iptables --flush > /dev/null 2>&1
sudo service iptables save > /dev/null 2>&1
