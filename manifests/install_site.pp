# Define: install_site
#
# Install nginx vhost
# This definition is private, not intended to be instantiated directly
#
define nginx::install_site(
  $sites_available = hiera('sites_available'),
  $sites_enabled   = hiera('sites_enabled'),
  $group           = hiera('group'),
  $content         = undef,
  $source          = undef,
  $root            = undef,
) {
  # first, make sure the site config exists
  case $content {
    undef: {
      case $source {
        undef: {
          file { "${sites_available}/${name}":
            ensure  => present,
            mode    => '0644',
            owner   => 'root',
            group   => 'root',
            alias   => "sites-${name}",
            notify  => Service['nginx'],
            require => Package['nginx'],
          }
        }
        default: {
          file { "${sites_available}/${name}":
            ensure  => present,
            mode    => '0644',
            owner   => 'root',
            group   => 'root',
            alias   => "sites-$name",
            source => $source,
            require => Package['nginx'],
            notify  => Service['nginx'],
          }
        }
      }
    }
    default: {
      file { "${sites_available}/${name}":
        ensure  => present,
        mode    => '0644',
        owner   => 'root',
        group   => 'root',
        alias   => "sites-$name",
        content => $content,
        require => Package['nginx'],
        notify  => Service['nginx'],
      }
    }
  }
  # now, enable it.
  exec { "ln -s ${sites_available}/${name} ${sites_enabled}/${name}":
    unless  => "/bin/sh -c '[ -L /${sites_enabled}/${name} ] && \
      [ ${sites_enabled}/${name} -ef ${sites_available}/${name} ]'",
    path    => ['/usr/bin/', '/bin/'],
    notify  => Service['nginx'],
    require => File["sites-${name}"],
  }
  if $root != undef {
    # ensure mkdir $root
    file { $root:
      ensure  => directory,
      mode    => '0750',
      owner   => 'root',
      group   => $group,
      require => Package['nginx'],
       notify  => Service['nginx'],
    } # end file   
  } # end conditional
}  # end nginx::install_site()
