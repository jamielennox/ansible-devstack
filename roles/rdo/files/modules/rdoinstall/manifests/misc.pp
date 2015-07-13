class rdoinstall::misc {

  # Tune the host with a virtual hosts profile
  package { 'tuned':
    ensure => present,
  }

  service { 'tuned':
    ensure  => running,
    require => Package['tuned'],
  }

  exec { 'tuned-virtual-host':
    unless  => '/usr/sbin/tuned-adm active | /bin/grep virtual-host',
    command => '/usr/sbin/tuned-adm profile virtual-host',
    require => Service['tuned'],
  }

  package { ['python-memcached', 'python-netaddr']:
    ensure => present,
  }

  class { '::memcached':
    max_memory => '10%%',
  }

}
