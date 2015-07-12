class rdoinstall::nova {

  nova_config {
    'DEFAULT/metadata_host':         value => '127.0.0.1';
    'DEFAULT/default_floating_pool': value => 'nova';

  #   # OpenStack doesn't include the CoreFilter (= CPU Filter) by default
  #   'DEFAULT/scheduler_default_filters':
  #       value => 'RetryFilter,AvailabilityZoneFilter,RamFilter,ComputeFilter,ComputeCapabilitiesFilter,ImagePropertiesFilter,CoreFilter';
  #   'DEFAULT/cpu_allocation_ratio': value => '16.0';
  #   'DEFAULT/ram_allocation_ratio' :value => '1.5';
  }

  class { '::nova':
    glance_api_servers     => 'localhost:9292',
    rabbit_host            => 'localhost',
    rabbit_port            => '5672',
    rabbit_use_ssl         => false,
    rabbit_userid          => hiera('amqp_user'),
    rabbit_password        => hiera('amqp_pass'),
    verbose                => true,
    database_connection    => 'mysql://nova:nova@localhost/nova',
  }

  class { '::nova::api':
    enabled        => true,
    auth_uri       => 'http://localhost:5000',
    identity_uri   => 'http://localhost:35357',
    admin_password => 'nova',
    enabled_apis   => 'osapi_compute,metadata',
  }

  class { '::nova::compute':
    enabled         => true,
    vnc_enabled     => false,
    neutron_enabled => false,
  }

  # Firewall <| |> -> Class['nova::compute::libvirt']

  # Ensure Firewall changes happen before libvirt service start
  # preventing a clash with rules being set by libvirt

  if str2bool($::is_virtual) {
    $libvirt_virt_type = 'qemu'
    $libvirt_cpu_mode = 'none'
  } else {
    $libvirt_virt_type = 'kvm'
  }

  # We need to preferably install qemu-kvm-rhev
  exec { 'qemu-kvm':
    path    => '/usr/bin',
    command => 'yum install -y -d 0 -e 0 qemu-kvm',
    onlyif  => 'yum install -y -d 0 -e 0 qemu-kvm-rhev &> /dev/null && exit 1 || exit 0',
    before  => Class['nova::compute::libvirt'],
  }

  class { '::nova::compute::libvirt':
    libvirt_virt_type        => $libvirt_virt_type,
    libvirt_cpu_mode         => $libvirt_cpu_mode,
    migration_support        => false,
    libvirt_inject_partition => '-1',
  }

  exec { 'load_kvm':
    user    => 'root',
    command => '/bin/sh /etc/sysconfig/modules/kvm.modules',
    onlyif  => '/usr/bin/test -e /etc/sysconfig/modules/kvm.modules',
  }

  Class['nova::compute'] -> Exec['load_kvm']

  file_line { 'libvirt-guests':
    path    => '/etc/sysconfig/libvirt-guests',
    line    => 'ON_BOOT=ignore',
    match   => '^[\s#]*ON_BOOT=.*',
    require => Class['nova::compute::libvirt'],
  }

  # Remove libvirt's default network (usually virbr0) as it's unnecessary and
  # can be confusing
  exec {'virsh-net-destroy-default':
    onlyif  => '/usr/bin/virsh net-list | grep default',
    command => '/usr/bin/virsh net-destroy default',
    require => Service['libvirt'],
  }

  exec {'virsh-net-undefine-default':
    onlyif  => '/usr/bin/virsh net-list --inactive | grep default',
    command => '/usr/bin/virsh net-undefine default',
    require => Exec['virsh-net-destroy-default'],
  }

  class { '::nova::cert':
    enabled => true,
  }

  class { '::nova::conductor':
    enabled => true,
  }

  class { '::nova::scheduler':
    enabled => true,
  }

  # class { '::nova::vncproxy':
  #   enabled => true,
  # }

  class { '::nova::consoleauth':
    enabled => true,
  }

  class { '::nova::db::mysql':
    password      => 'nova',
    allowed_hosts => 'localhost',
  }

  class { '::nova::keystone::auth':
    password         => 'nova',
    public_address   => 'localhost',
    admin_address    => 'localhost',
    internal_address => 'localhost',
  }

#  $libvirt_debug = hiera('CONFIG_DEBUG_MODE')
#  if $libvirt_debug {
#
#    file_line { '/etc/libvirt/libvirt.conf log_filters':
#      path   => '/etc/libvirt/libvirtd.conf',
#      line   => 'log_filters = "1:libvirt 1:qemu 1:conf 1:security 3:event 3:json 3:file 1:util"',
#      match  => 'log_filters =',
#      notify => Service['libvirt'],
#    }
#
#    file_line { '/etc/libvirt/libvirt.conf log_outputs':
#      path   => '/etc/libvirt/libvirtd.conf',
#      line   => 'log_outputs = "1:file:/var/log/libvirt/libvirtd.log"',
#      match  => 'log_outputs =',
#      notify => Service['libvirt'],
#    }
#
#  }

}
