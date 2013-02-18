define nginx::site::location(
  $ensure           = present,
  $location         = undef,
  $site             = undef,
  $location_options = undef,
  $sites_enabled    = hiera('sites_enabled', $nginx::params::sites_enabled)
) {
  if ! $site {
    fail("Nginx::Site::Location[site]:
      parameter must be defined")
  }
  if ! $location {
    fail("Nginx::Site::Location[location]:
      parameter must be defined")
  }
  if $name !~ /^[a-zA-Z][a-zA-Z0-9_-]*$/ {
    fail("Nginx::Site::Location[${name}]:
      parameter must be alphanumeric")
  }

  file { "${sites_enabled}/${site}/${name}.conf":
    ensure  => present,
    content => template('nginx/location.erb'),
    notify  => Service['nginx'],
  }
}
