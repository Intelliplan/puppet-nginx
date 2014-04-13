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
  $user               = 'nginx',
  $group              = 'nginx',
  $worker_processes   = '1',
  $worker_connections = '1024',
  $etc_dir            = '/etc/nginx',
  $log_dir            = '/var/log/nginx',
  $data_dir           = '/var/www',
  $pid_file           = '/var/run/nginx.pid',
  $includes_dir       = "${etc_dir}/includes",
  $conf               = "${etc_dir}/conf.d",
  $proxy_params       = "${includes_dir}/proxy_params",
  $sites_enabled      = "${etc_dir}/sites-enabled",
  $sites_available    = "${etc_dir}/sites-available"
) {

  package { 'nginx': 
    ensure  => latest, # http://nginx.org/en/security_advisories.html
  }

  group { $group:
    ensure  => present,
    system  => true,
  }

  user { $user:
    ensure  => present,
    gid     => $group,
    system  => true,
    home    => $data_dir,
    shell   => '/sbin/nologin',
    require => Group[$group],
  }

  #restart-command is a quick-fix here, until http://projects.puppetlabs.com/issues/1014 is solved
  service { 'nginx':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    restart    => '/etc/init.d/nginx reload',
    require    => File["${etc_dir}/nginx.conf"],
  }

  File {
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['nginx'],
  }

  file {
    "${etc_dir}/nginx.conf":
      ensure  => present,
      content => template('nginx/nginx.conf.erb'),
      notify  => Service['nginx'];

    $conf:
      ensure  => absent,
      force   => true;

    "${etc_dir}/ssl":
      ensure  => directory;

    $includes_dir:
      ensure  => directory;

    "${etc_dir}/fastcgi_params":
      ensure  => absent;

    $proxy_params:
      content => template('nginx/includes/proxy_params'),
      notify  => Service['nginx'];

    $data_dir:
      ensure  => directory,
      mode    => '0644',
      owner   => $user,
      group   => $group;

    $log_dir:
      ensure  => directory,
      mode    => '0640',
      require => Package['nginx'];

    $sites_available:
      ensure => directory;

    $sites_enabled:
      ensure => directory;
  } # end litany of file resources
} # end init.pp
