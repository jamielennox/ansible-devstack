class rdoinstall::keystone {

  $admin_token = hiera('admin_token')

  $admin_user = hiera('admin_user')
  $admin_password = hiera('admin_password')
  $admin_project_name = hiera('admin_project_name')

  $services_project_name = hiera('services_project_name')

  $keystone_db_user = hiera('keystone_db_user')
  $keystone_db_password = hiera('keystone_db_password')

  class { '::keystone':
    admin_token         => $admin_token,
    database_connection => "mysql://$keystone_db_user:$keystone_db_password@localhost/keystone",
    service_name        => 'httpd',
    debug               => $::rdoinstall::debug,
#    cache_backend       => 'keystone.cache.memcache_pool',
  }

  class { '::keystone::wsgi::apache':
    ssl => false,
  }

  class { '::keystone::db::mysql':
    user          => $keystone_db_user,
    password      => $keystone_db_password,
    dbname        => 'keystone',
    allowed_hosts => ['localhost'],
  }

  class { '::keystone::roles::admin':
    admin          => $admin_user,
    password       => $admin_password,
    email          => "$admin_user@$admin_project_name",
    admin_tenant   => $admin_project_name,
    service_tenant => $services_project_name,
  }

  class { '::keystone::endpoint':
    public_url => "http://$::fqdn:5000",
    admin_url => "http://$::fqdn:35357",
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
