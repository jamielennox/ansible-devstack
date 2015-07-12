class rdoinstall::glance {

  class { '::glance::db::mysql':
    password      => 'glance',
    host          => 'localhost',
    allowed_hosts => 'localhost',
  }

  class { '::glance::api':
    auth_uri            => "http://$::fqdn:5000/",
    identity_uri        => "http://$::fqdn:35357",
    keystone_tenant     => 'services',
    keystone_user       => hiera('glance_user'),
    keystone_password   => hiera('glance_password'),
    pipeline            => 'keystone',
    database_connection => "mysql://glance:glance@localhost/glance",
  }

  class { '::glance::registry':
    auth_uri            => "http://$::fqdn:5000/",
    identity_uri        => "http://$::fqdn:35357",
    keystone_tenant     => 'services',
    keystone_user       => hiera('glance_user'),
    keystone_password   => hiera('glance_password'),
    database_connection => "mysql://glance:glance@localhost/glance",
  }

  class { '::glance::keystone::auth':
    password         => hiera('glance_password'),
    public_address   => $::fqdn,
    admin_address    => $::fqdn,
    internal_address => $::fqdn,
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
