class rdoinstall::glance {

  class { '::glance::db::mysql':
    password      => 'glance',
    host          => 'localhost',
    allowed_hosts => 'localhost',
  }

  class { '::glance::api':
    auth_uri            => 'http://localhost:5000/',
    identity_uri        => 'http://localhost:35357',
    keystone_tenant     => 'services',
    keystone_user       => 'glance',
    keystone_password   => 'glance',
    pipeline            => 'keystone',
    database_connection => "mysql://glance:glance@localhost/glance",
  }

  class { '::glance::registry':
    auth_uri            => 'http://localhost:5000/',
    identity_uri        => 'http://localhost:35357',
    keystone_tenant     => 'services',
    keystone_user       => 'glance',
    keystone_password   => 'glance',
    database_connection => "mysql://glance:glance@localhost/glance",
  }

  class { '::glance::keystone::auth':
    password         => 'glance',
    public_address   => 'localhost',
    admin_address    => 'localhost',
    internal_address => 'localhost',
  }

  class { '::glance::notify::rabbitmq':
    rabbit_host        => 'localhost',
    rabbit_port        => '5672',
    rabbit_use_ssl     => false,
    rabbit_userid      => 'amqp_user',
    rabbit_password    => 'amqp_pass',
  }

  class { '::glance::backend::file':
    filesystem_store_datadir => '/var/lib/glance/images/',
  }

}
