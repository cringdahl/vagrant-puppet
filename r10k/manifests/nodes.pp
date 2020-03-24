node 'default' {
  include role::agent

  notify { 'Default class for unknown node; define nodes in manifests/nodes.pp': }
}

node 'puppetmaster.vm.local' {
  include role::master_standalone
}

#node 'puppetdb' {
#  include role::puppetdb
#}

#node 'puppetreports' {
#  include role::puppetreports
#}

node 'websrv.vm.local' {
  include role::agent
  include role::nginx
  include jenkins
}
