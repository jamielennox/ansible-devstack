class rdoinstall::horizon {

  class { '::horizon':
    secret_key            => '76985f45fc444683b552fef512046c4f',
    keystone_url          => "http://$::fqdn:5000/v2.0",
    keystone_default_role => '_member_',
    server_aliases        => [$::fqdn, 'localhost', '10.3.10.8'],
    allowed_hosts         => '*',
    hypervisor_options    => {'can_set_mount_point' => false, },
    django_debug          => 'False',
    file_upload_temp_dir  => '/var/tmp',
    listen_ssl            => false,
  }

  firewall { "001 horizon ${firewall_port} incoming":
    proto  => 'tcp',
    dport  => '80',
    action => 'accept',
  }

}
