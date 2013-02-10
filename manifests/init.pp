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
  $user               = hiera('user', $nginx::params::user), 
  $group              = hiera('group', $nginx::params::group),
  $worker_processes   = hiera('worker_processes', $nginx::params::worker_processes), 
  $worker_connections = hiera('worker_connections', $nginx::params::worker_connections),
  $includes_dir       = hiera('includes_dir', $nginx::params::includes_dir),
  $conf               = hiera('conf', $nginx::params::conf),
  $etc_dir            = hiera('etc_dir', $nginx::params::etc_dir),
  $proxy_params       = hiera('proxy_params', $nginx::params::proxy_params),
  $data_dir           = hiera('data_dir', $nginx::params::data_dir),
  $sites_enabled      = hiera('sites_enabled', $nginx::params::sites_enabled),
  $sites_available    = hiera('sites_available', $nginx::params::sites_available)
) inherits nginx::params {

  if ! defined(Package['nginx']) { package { 'nginx': ensure => installed }}

  #restart-command is a quick-fix here, until http://projects.puppetlabs.com/issues/1014 is solved
  service { 'nginx':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    require    => File["${etc_dir}/nginx.conf"],
    restart    => '/etc/init.d/nginx reload'
  }
  file {
    "${etc_dir}/nginx.conf":
      ensure  => present,
      mode    => '0644',
      owner   => 'root',
      group   => 'root',
      content => template('nginx/nginx.conf.erb'),
      notify  => Service['nginx'],
      require => Package['nginx'],
  }
  file {
    $conf:
      ensure  => directory,
      mode    => '0644',
      owner   => 'root',
      group   => 'root',
      require => Package['nginx'],
  }
  file {
    "${etc_dir}/ssl":
      ensure  => directory,
      mode    => '0644',
      owner   => 'root',
      group   => 'root',
      require => Package['nginx'];

    $includes_dir:
      ensure  => directory,
      mode    => '0644',
      owner   => 'root',
      group   => 'root',
      require => Package['nginx'];
  }
  file {
    "${etc_dir}/fastcgi_params":
      ensure  => absent,
      require => Package['nginx'];

    $proxy_params:
      ensure  => present,
      mode    => '0644',
      owner   => 'root',
      group   => 'root',
      content => template('nginx/includes/proxy_params'),
      notify  => Service['nginx'],
      require => Package['nginx'];

    $data_dir:
      ensure  => directory,
      mode    => '0755',
      owner   => 'root',
      group   => $group,
      require => Package['nginx'];
  }
  file {    
    [ $sites_available , $sites_enabled ]:
      ensure => directory,
      mode => '0755',
      owner => 'root',
      group => 'root',
      require => Package['nginx'];
  } # end litany of file resources
} # end init.pp
