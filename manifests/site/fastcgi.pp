define nginx::site::fastcgi (
  $ensure        = 'present',
  $options       = undef,
  $sites_enabled = hiera('sites_enabled')
) {
  file { "${sites_enabled}/${name}.d/fastcgi.inc":
    ensure  => $ensure,
    content => template('nginx/includes/fastcgi.erb'),
    notify  => Service['nginx'],
  }
}
