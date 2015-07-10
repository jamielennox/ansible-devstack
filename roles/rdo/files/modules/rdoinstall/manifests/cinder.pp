class rdoinstall::cinder {

  cinder_config {
    'DEFAULT/glance_host': value => 'localhost';
  }

  class { '::cinder::api':
    keystone_password  => 'cinder',
    keystone_tenant    => 'services',
    keystone_user      => 'cinder',
    auth_uri           => 'http://localhost:5000',
    identity_uri       => 'http://localhost:35357',
  }

  class { '::cinder::scheduler': }

  class { '::cinder::volume': }

  class { '::cinder::client': }

  # Cinder::Type requires keystone credentials
  Cinder::Type {
    os_password    => 'cinder',
    os_tenant_name => 'services',
    os_username    => 'cinder',
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
      content => '[Unit]
Description=Setup cinder-volume loop device
DefaultDependencies=false
Before=openstack-cinder-volume.service
After=local-fs.target

[Service]
Type=oneshot
ExecStart=/usr/bin/sh -c \'/usr/sbin/losetup -j /var/lib/cinder/cinder-volumes | /usr/bin/grep /var/lib/cinder/cinder-volumes || /usr/sbin/losetup -f /var/lib/cinder/cinder-volumes\'
ExecStop=/usr/bin/sh -c \'/usr/sbin/losetup -j /var/lib/cinder/cinder-volumes | /usr/bin/cut -d : -f 1 | /usr/bin/xargs /usr/sbin/losetup -d\'
TimeoutSec=60
RemainAfterExit=yes

[Install]
RequiredBy=openstack-cinder-volume.service',
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
    rabbit_userid       => 'amqp_user',
    rabbit_password     => 'amqp_pass',
    database_connection => "mysql://cinder:cinder@localhost/cinder",
  }

  class { '::cinder::db::mysql':
    password      => 'cinder',
    allowed_hosts => 'localhost',
    charset       => 'utf8',
  }

  class { '::cinder::keystone::auth':
    password         => 'cinder',
    public_address   => 'localhost',
    admin_address    => 'localhost',
  }

}
