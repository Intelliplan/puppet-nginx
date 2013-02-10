# Define: nginx::config::include
#
# Define a site config include in /etc/nginx/includes
#
# Parameters :
# * ensure: typically set to "present" or "absent". Defaults to "present"
# * content: include definition (should be a template).
# * includes_dir: directory for includes, such as parameters
#
define nginx::config::include(
  $ensure  = 'present',
  $content = '',
  $includes_dir = hiera('includes_dir', $nginx::params::includes_dir)
) {
  file { "${includes_dir}/${name}.inc":
    ensure  => $ensure,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => $content,
    require => File[$includes_dir],
    notify  => Service['nginx'],
  }
} # end nginx:config::include class
