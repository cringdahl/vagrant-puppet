# == Class: profile::nginx
#
#  Install and configure nginx reverse proxy
#
# === Parameters
#
# === Authors
#
# Cory Ringdahl
#
# === Copyright
#
# Copyright 2020
#

class profile::nginx(
  $host,
  $proxy,
  $listen_ip,
  $listen_port,
  $ssl,
  $ssl_protocols,
  $ssl_port,
  $ssl_cert,
  $ssl_key,
  $ssl_trusted_cert,
  $proxy_set_header,
) {
  class {'nginx':
    confd_purge => true,
  }
  nginx::resource::server { $host: 
    ssl              => $ssl,
    ssl_protocols    => $ssl_protocols,
    ssl_port         => $ssl_port,
    listen_port      => $listen_port,
    listen_ip        => $listen_ip,
    ssl_cert         => $ssl_cert,
    ssl_key          => $ssl_key,
    ssl_trusted_cert => $ssl_trusted_cert,
    proxy            => $proxy,
    proxy_set_header => $proxy_set_header,
  }
}
