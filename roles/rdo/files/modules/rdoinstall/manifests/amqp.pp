class rdoinstall::amqp {

  package { 'erlang':
    ensure => 'installed',
  }

  class { '::rabbitmq':
    ssl              => false,
    default_user     => hiera('amqp_user'),
    default_pass     => hiera('amqp_pass'),
    package_provider => 'yum',
    admin_enable     => false,
    config_variables => {
      'tcp_listen_options' => '[binary,{packet, raw},{reuseaddr, true},{backlog, 128},{nodelay, true},{exit_on_close, false},{keepalive, true}]',
      'loopback_users'     => '[]',
    },
  }

  Package['erlang'] -> Class['rabbitmq']

}
