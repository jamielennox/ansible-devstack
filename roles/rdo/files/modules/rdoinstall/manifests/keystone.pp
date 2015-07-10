class rdoinstall::keystone {

  class { '::keystone':
    admin_token         => 'ADMIN',
    database_connection => 'mysql://keystone:keystone@localhost/keystone',
    service_name        => 'httpd',
  }

  class { '::keystone::wsgi::apache':
    ssl => false,
  }

  class { '::keystone::db::mysql':
    user          => 'keystone',
    password      => 'keystone',
    dbname        => 'keystone',
    allowed_hosts => ['localhost'],
  }

  class { '::keystone::roles::admin':
    admin        => 'admin',
    password     => 'password',
    email        => 'admin@admin',
    admin_tenant => 'admin',
  }

  class { '::keystone::endpoint':
    public_url => 'http://localhost:5000',
    admin_url => 'http://localhost:35357',
  }

#  keystone::resource::service_identity { 'keystone':
#    public_url          => 'http://localhost:5000/v2.0',
#    internal_url        => 'http://localhost:5000/v2.0',
#    admin_url           => 'http://localhost:35357/v2.0',
#    service_type        => 'identity',
#    service_description => 'OpenStack Identity Service',
#    configure_user      => false,
#    configure_user_role => false,
#  }

  # Run token flush every minute (without output so we won't spam admins)
  cron { 'token-flush':
    ensure  => 'present',
    command => '/usr/bin/keystone-manage token_flush >/dev/null 2>&1',
    minute  => '*/1',
    user    => 'keystone',
    require => [User['keystone'], Group['keystone']],
  } ->
  service { 'crond':
    ensure => 'running',
    enable => true,
  }
}
