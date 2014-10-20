## Usage:
#
# $keepalive      - Activate cache for (number) connections to upstream servers.
#                   Default: 0 (disabled)
#
# $balancing_mode - Load balancing mode used to distribute requests within the
#                   upstream group. Default: 'weighted'
#                   Balancing modes:
#                   weighted   - Only server $weight is considered
#                   ip_hash    - First three octects of client IP addresses are
#                                hashed and used, server $weight is also considered
#                   least_conn - Prefer servers with least Number of active connections,
#                                server $weight is also considered
#
# $servers        - Hash specifying servers in the upstream group.
#                   E.g:
#                   {
#                     'prod-web-iis-01:80' => { },
#                     'prod-web-iis-02:80' => { backup => true },
#                   }
#                   Server options:
#                   $weight       - Relative weight of server when balancing. Default: 1
#                   $max_fails    - Number of retries before server is deemed unavailable. Default: 1
#                   $fail_timeout - period of time (in seconds) during which $max_fails happens,
#                                   also period of time server remains unavailable after $max_fails.
#                                  Default: 10
#                   $backup       - Marks server as backup, will only get requests when primary are
#                                   unavailable. Default: false
#                   $down         - Marks server as permanently unavailable. Default: false
define nginx::upstream(
  $ensure          = 'present',
  $keepalive       = 0,
  $balancing_mode  = 'weighted',
  $hash            = '',
  $hash_again      = 0,
  $servers         = {},
  $owner           = $nginx::user,
  $group           = $nginx::group,
  $sites_available = $nginx::sites_available,
  $sites_enabled   = $nginx::sites_enabled,
) {
  $available_config = "${sites_available}/${title}.conf"
  $enabled_config   = "${sites_enabled}/${title}.conf"
  case $ensure {
    'present' : {
      case $balancing_mode {
        'weighted': { $balancing = '' }
        'ip_hash','least_conn' : { $balancing = $balancing_mode }
        default: { err ("Invalid balancing_mode specified: '$balancing_mode'") }
      }
      unless $keepalive >= 0 {
        err ("Invalid value for keepalive: '$keepalive'" )
      }
      file { $available_config:
        ensure  => 'present',
        content => template('nginx/upstream.erb'),
        mode    => '0644',
        owner   => $owner,
        group   => $group,
      }
      file { $enabled_config:
        ensure  => 'link',
        target  => $available_config,
        notify  => Service['nginx'],
        require => File[$available_config],
      }
    }
    'absent' : {
      file { $enabled_config:
        ensure => 'absent',
        notify => Service['nginx'],
      }
      file { $available_config:
        ensure  => 'absent',
        require => File[$enabled_config],
      }
    }
    default: { err ("Unknown ensure value: '$ensure'") }
  }
}
