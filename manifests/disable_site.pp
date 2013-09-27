# Define: disable_site
#
# remove nginx vhost from sites-enabled directory
# This definition is private, not intended to be called directly
#
define nginx::disable_site {

  file {
    "/etc/nginx/sites-enabled/${name}.conf":
      ensure => absent,
      notify  => Service['nginx'],
      require => Package['nginx'];
    "/etc/nginx/sites-available/${name}.conf":
      ensure  => absent,
      require => File["/etc/nginx/sites-enabled/${name}.conf"];
  }

} # end nginx::remove_site() 
