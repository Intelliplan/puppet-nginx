# Class: nginx
#
# Install nginx.
#
# Parameters:
# * $user
# * $worker_processes
# * $worker_connections
#
# Create config directories :
# * /etc/nginx/conf.d for http config snippet
# * /etc/nginx/includes for sites includes
#
# Templates:
#   - nginx.conf.erb => /etc/nginx/nginx.conf
#
class nginx(
  $user               = $nginx::params::user,
  $group              = $nginx::params::group,
  $worker_processes   = $nginx::params::worker_processes, 
  $worker_connections = $nginx::params::worker_connections,
  $includes_dir       = $nginx::params::includes_dir,
  $conf               = $nginx::params::conf,
  $etc_dir            = $nginx::params::etc_dir,
  $log_dir            = $nginx::params::log_dir,
  $proxy_params       = $nginx::params::proxy_params,
  $data_dir           = $nginx::params::data_dir,
  $sites_enabled      = $nginx::params::sites_enabled,
  $sites_available    = $nginx::params::sites_available
) inherits nginx::params {

  anchor { 'nginx::start': }
  anchor { 'nginx::end': }

  if ! defined(Package['nginx']) { 
    package { 'nginx': 
      ensure => installed,
      require => Anchor['nginx::start'],
      before => Anchor['nginx::end'],
    }
  }

  group { $group:
    ensure => present,
    system => true,
    require => Anchor['nginx::start'],
    before  => Anchor['nginx::end'],
  }

  user { $user:
    ensure => present,
    gid    => $group,
    system => true,
    home   => $data_dir,
    shell  => '/sbin/nologin',
    require => Group[$group],
  }

  #restart-command is a quick-fix here, until http://projects.puppetlabs.com/issues/1014 is solved
  service { 'nginx':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    restart    => '/etc/init.d/nginx reload',
    require    => [
      Anchor['nginx::start'],
      File["${etc_dir}/nginx.conf"],
    ],
    before     => Anchor['nginx::end'],
  }

  file {
    "${etc_dir}/nginx.conf":
      ensure  => present,
      mode    => '0644',
      owner   => 'root',
      group   => 'root',
      content => template('nginx/nginx.conf.erb'),
      notify  => Service['nginx'],
      require => [
        Package['nginx'],
        Anchor['nginx::start'],
      ],
      before => Anchor['nginx::end'];

    $conf:
      ensure  => absent,
      force   => true,
      require => [
        Package['nginx'],
        Anchor['nginx::start'],
      ],
      before => Anchor['nginx::end'];

    "${etc_dir}/ssl":
      ensure  => directory,
      mode    => '0644',
      owner   => 'root',
      group   => 'root',
      require => [
        Package['nginx'],
        Anchor['nginx::start'],
      ],
      before => Anchor['nginx::end'];

    $includes_dir:
      ensure  => directory,
      mode    => '0644',
      owner   => 'root',
      group   => 'root',
      require => [
        Package['nginx'],
        Anchor['nginx::start'],
      ],
      before => Anchor['nginx::end'];

    "${etc_dir}/fastcgi_params":
      ensure  => absent,
      require => [
        Package['nginx'],
        Anchor['nginx::start'],
      ],
      before => Anchor['nginx::end'];

    $proxy_params:
      ensure  => present,
      mode    => '0644',
      owner   => 'root',
      group   => 'root',
      content => template('nginx/includes/proxy_params'),
      notify  => Service['nginx'],
      require => [
        Package['nginx'],
        Anchor['nginx::start'],
      ],
      before => Anchor['nginx::end'];

    $data_dir:
      ensure  => directory,
      mode    => '0755',
      owner   => $user,
      group   => $group,
      require => [
        Package['nginx'],
        Anchor['nginx::start'],
      ],
      before => Anchor['nginx::end'];

    $log_dir: 
      ensure  => directory,
      mode    => '0750',
      owner   => 'root',
      group   => 'root',
      require => [
        Package['nginx'],
        Anchor['nginx::start']
      ],
      before  => Anchor['nginx::end'];

    [ $sites_available , $sites_enabled ]:
      ensure => directory,
      mode => '0755',
      owner => 'root',
      group => 'root',
      require => [
        Package['nginx'],
        Anchor['nginx::start'],
      ],
      before => Anchor['nginx::end'];
  } # end litany of file resources
} # end init.pp
