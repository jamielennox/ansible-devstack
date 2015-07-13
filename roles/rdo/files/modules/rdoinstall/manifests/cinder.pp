class rdoinstall::cinder {

  $cinder_user = hiera('cinder_user')
  $cinder_password = hiera('cinder_password')
  $cinder_db_user = hiera('cinder_db_user')
  $cinder_db_password = hiera('cinder_db_password')

  cinder_config {
    'DEFAULT/glance_host': value => 'localhost';
  }

  class { '::cinder::api':
    keystone_password  => $cinder_password,
    keystone_user      => $cinder_user,
    keystone_tenant    => $services_project,
    auth_uri           => 'http://localhost:5000',
    identity_uri       => 'http://localhost:35357',
  }

  class { '::cinder::scheduler': }

  class { '::cinder::volume': }

  class { '::cinder::client': }

  # Cinder::Type requires keystone credentials
  Cinder::Type {
    os_password    => $cinder_password,
    os_tenant_name => $services_project,
    os_username    => $cinder_username,
    os_auth_url    => 'http://localhost:5000/v2.0',
  }

  class { '::cinder::backends':
    enabled_backends => ['lvm'],
  }

  class { '::cinder::setup_test_volume':
    size            => '20G',
    loopback_device => '/dev/loop2',
    volume_path     => '/var/lib/cinder',
    volume_name     => 'cinder-volumes',
  }

  # Add loop device on boot
  $el_releases = ['RedHat', 'CentOS', 'Scientific']
  if $::operatingsystem in $el_releases and (versioncmp($::operatingsystemmajrelease, '7') < 0) {

    file_line{ 'rc.local_losetup_cinder_volume':
      path  => '/etc/rc.d/rc.local',
      match => '^.*/var/lib/cinder/cinder-volumes.*$',
      line  => 'losetup -f /var/lib/cinder/cinder-volumes && service openstack-cinder-volume restart',
    }

    file { '/etc/rc.d/rc.local':
      mode  => '0755',
    }

  } else {

    file { 'openstack-losetup':
      path    => '/usr/lib/systemd/system/openstack-losetup.service',
      before  => Service['openstack-losetup'],
      notify  => Exec['/usr/bin/systemctl daemon-reload'],
      source  => 'puppet:///modules/rdoinstall/openstack-losetup.service',
      owner   => 'root',
      group   => 'root',
    }

    exec { '/usr/bin/systemctl daemon-reload':
      refreshonly => true,
      before      => Service['openstack-losetup'],
    }

    service { 'openstack-losetup':
      ensure  => running,
      enable  => true,
      require => Class['cinder::setup_test_volume'],
    }

  }

  class { '::cinder':
    rabbit_host         => 'localhost',
    rabbit_port         => '5672',
    rabbit_use_ssl      => false,
    rabbit_userid       => $::rdoinstall::amqp::amqp_user,
    rabbit_password     => $::rdoinstall::amqp::amqp_pass,
    database_connection => "mysql://$cinder_db_user:$cinder_db_password@localhost/cinder",
  }

  class { '::cinder::db::mysql':
    user          => $cinder_db_user,
    password      => $cinder_db_password,
    allowed_hosts => 'localhost',
    charset       => 'utf8',
  }

  class { '::cinder::keystone::auth':
    auth_name        => $cinder_user,
    password         => $cinder_password,
    public_address   => $::fqdn,
    admin_address    => $::fqdn,
  }

}
