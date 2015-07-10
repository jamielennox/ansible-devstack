class rdoinstall::nova_network {

  # $overrides = {}
  # $overrides['force_dhcp_release'] = false

  nova_config {
    'DEFAULT/auto_assign_floating_ip': value => false;
  }

  class { '::nova::network':
    enabled           => true,
    # private_interface => force_interface('eth1', $use_subnets),
    # public_interface  => force_interface('eth0', $use_subnets),
    fixed_range       => '192.168.32.0/22',
    floating_range    => '10.3.4.0/22',
    # config_overrides  => $overrides,
  }

  package { 'dnsmasq':
    ensure => present,
  }

}

