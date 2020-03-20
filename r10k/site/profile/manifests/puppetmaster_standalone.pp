# == Class: profiles::puppetmaster_standalone
#
#  Install and configure puppetmaster 
#
# === Parameters
#
# [*use_puppetdb*]
#
# Install puppetdb on the master node?
# Default value is looked up in hiera and set as "false" if nothing is found
#
# [*use_puppetboard*]
#
# Install puppetboard on the master node?
# Default value is looked up in hiera and set as "false" if nothing is found
#
# === Examples
#
#  class { 'profiles::puppetmaster':
#    user_puppetdb  => true
#  }
#
# === Authors
#
# Laurent Bernaille
#
# === Copyright
#
# Copyright 2013 Your name here, unless otherwise noted.
#

class profile::puppetmaster_standalone(
    $use_puppetdb=lookup('profiles::puppetmaster::use_puppetdb',undef,undef,false),
    $use_puppetboard=lookup('profiles::puppetmaster::use_puppetboard',undef,undef,false)
) {

  class { 'puppetserver':
    config => {
      'java_args'     => {
        'xms'   => '512m',
        'xmx'   => '512m'
      }
    }
  }

  class { '::puppetserver::hiera::eyaml':
    require => Class['puppetserver::install'],
  }

  $confdir = $::settings::confdir
  file { "${confdir}/autosign.conf":
    ensure  => file,
    content => epp('profile/puppetmaster/autosign.conf.epp',{ 'autosign_hosts' => lookup('profiles::puppetmaster::autosign_hosts',undef,undef,[])}),
  }

  if $use_puppetdb {
    class { 'puppetdb': }

    # No anchor in puppetdb module
    # We need ssl certificates to start jetty
    # puppdb ssl-setup is performed at package installaion and requires ssl certificates for the node
    Class['puppetserver']->Package['puppetdb']


    class { 'puppetdb::master::config':
      manage_routes           => true,
      manage_storeconfigs     => true,
      manage_report_processor => true,
      enable_reports          => true,
      strict_validation       => false
    }

    if $use_puppetboard {
      class { 'apache': }
      class { 'apache::mod::wsgi': }

      class { 'puppetboard':
        manage_virtualenv => "latest"
      }

      class { 'puppetboard::apache::vhost':
        vhost_name => lookup('profiles::puppetmaster::puppetboard_vhost',undef,undef,$::fqdn)
      }
    }
  }
}
