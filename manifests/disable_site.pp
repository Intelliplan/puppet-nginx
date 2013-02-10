# Define: disable_site
#
# remove nginx vhost from sites-enabled directory
# This definition is private, not intended to be called directly
#
define nginx::disable_site {

  exec { "/bin/rm -f /etc/nginx/sites-enabled/${name}":
    onlyif  => "/bin/sh -c '[ -L /etc/nginx/sites-enabled/${name} ] && \
      [ /etc/nginx/sites-enabled/$name -ef /etc/nginx/sites-available/${name} ]'",
    notify  => Service['nginx'],
    require => Package['nginx'],
  }

} # end nginx::remove_site() 
