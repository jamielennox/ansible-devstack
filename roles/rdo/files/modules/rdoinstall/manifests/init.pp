class rdoinstall {
  # https://bugs.launchpad.net/puppet-openstacklib/+bug/1472837
  include ::mysql::server

  include ::rdoinstall::amqp
  include ::rdoinstall::cinder
  include ::rdoinstall::glance
  include ::rdoinstall::horizon
  include ::rdoinstall::keystone
  include ::rdoinstall::misc
  include ::rdoinstall::nova
  include ::rdoinstall::nova_network
}
