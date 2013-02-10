# XXX doc me
# XXX this needs a lot more love, just trying to get it out of the middle of
# nginx::site for now
# XXX - ${nginx::site::real_server_name} might error out.. dunno, untested. may
# need to pass in as input param
define nginx::create_ssl_cert {

  exec { "generate-${name}-certs":
    command => "/usr/bin/openssl req -new -inform PEM -x509 -nodes -days 999 -subj \
    '/C=ZZ/ST=AutoSign/O=AutoSign/localityName=AutoSign/commonName=${nginx::site::real_server_name}/organizationalUnitName=AutoSign/emailAddress=AutoSign/' \
    -newkey rsa:2048 -out /etc/nginx/ssl/${name}.pem -keyout /etc/nginx/ssl/${name}.key",
    unless  => "/usr/bin/test -f /etc/nginx/ssl/${name}.pem",
    require => File['/etc/nginx/ssl'],
    notify  => Service['nginx'],
  }

} # end nginx::create_ssl_cert()
