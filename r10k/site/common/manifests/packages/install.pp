# == Class: packages::install
#
# Adds, modifies or removes the package install as needed
#
# === Parameters
#
# [*packages*]
#   A hash specifying all needed params for the package type
#
# === Examples
#
#  class { 'packages::install': }
#
# === Hiera
#
#  packages:
#    wget:
#      ensure:  present
#      provider: xxx
#

class common::packages::install( $packages = lookup('packages', { merge => hash }) ) {
    if ( $packages ) {
        create_resources( package, $packages )
    }
}
