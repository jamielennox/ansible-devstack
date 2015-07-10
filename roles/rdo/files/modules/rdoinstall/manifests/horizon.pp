class rdoinstall::horizon {

  package { ['python-memcached', 'python-netaddr']:
    ensure => present,
  }

  class {'::horizon':
    secret_key            => '76985f45fc444683b552fef512046c4f',
    keystone_url          => 'http://localhost:5000/v2.0',
    keystone_default_role => '_member_',
    server_aliases        => [$::fqdn, 'localhost', '10.3.10.111'],
    allowed_hosts         => '*',
    hypervisor_options    => {'can_set_mount_point' => false, },
    django_debug          => 'False',
    file_upload_temp_dir  => '/var/tmp',
    listen_ssl            => false,
    #neutron_options       => {
    #  'enable_lb'       => hiera('CONFIG_HORIZON_NEUTRON_LB'),
    #  'enable_firewall' => hiera('CONFIG_HORIZON_NEUTRON_FW'),
    #},
  }

  # apache::listen { '5000': }
  # apache::listen { '35357': }

  class { '::memcached':
    max_memory => '10%%',
  }

  $firewall_port = '80'

  firewall { "001 horizon ${firewall_port}  incoming":
    proto  => 'tcp',
    dport  => [$firewall_port],
    action => 'accept',
  }

}
