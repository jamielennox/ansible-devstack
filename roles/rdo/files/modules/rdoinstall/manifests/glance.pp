class rdoinstall::glance {

  $glance_user = hiera('glance_user')
  $glance_password = hiera('glance_password')
  $glance_db_user = hiera('glance_db_user')
  $glance_db_password = hiera('glance_db_password')

  class { '::glance::db::mysql':
    password      => $glance_db_password,
    host          => 'localhost',
    allowed_hosts => 'localhost',
  }

  class { '::glance::api':
    auth_uri            => "http://$::fqdn:5000/",
    identity_uri        => "http://$::fqdn:35357",
    keystone_tenant     => $services_project,
    keystone_user       => $glance_user,
    keystone_password   => $glance_password,
    pipeline            => 'keystone',
    database_connection => "mysql://$glance_db_user:$glance_db_password@localhost/glance",
    debug               => $::rdoinstall::debug,
  }

  class { '::glance::registry':
    auth_uri            => "http://$::fqdn:5000/",
    identity_uri        => "http://$::fqdn:35357",
    keystone_tenant     => $services_project,
    keystone_user       => $glance_user,
    keystone_password   => $glance_password,
    database_connection => "mysql://$glance_db_user:$glance_db_password@localhost/glance",
    debug               => $::rdoinstall::debug,
  }

  class { '::glance::keystone::auth':
    auth_name        => $glance_user,
    password         => $glance_password,
    public_address   => $::fqdn,
    admin_address    => $::fqdn,
    internal_address => $::fqdn,
  }

  class { '::glance::notify::rabbitmq':
    rabbit_host        => 'localhost',
    rabbit_port        => '5672',
    rabbit_use_ssl     => false,
    rabbit_userid      => $::rdoinstall::amqp::amqp_user,
    rabbit_password    => $::rdoinstall::amqp::amqp_pass,
  }

  class { '::glance::backend::file':
    filesystem_store_datadir => '/var/lib/glance/images/',
  }

}
