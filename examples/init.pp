class { 'nginx':
  user => 'apache',
}

## Example site with location options
nginx::site { 'test.example.com':
  ensure  => present,
  listen    => '80',
}

nginx::site::location { 'testlocation':
  site             => 'test.example.com',
  location         => '/testlocation',
  location_options => {
    'rewrite'      => '^ http://www.google.be permanent',
    'expires'      => 'max',
  }
}

nginx::site::fastcgi { 'test.example.com':
  options => [
    'fastcgi_pass   unix:/tmp/php-fpm.sock;',
    'fastcgi_index  index.php;',
  ]
}
