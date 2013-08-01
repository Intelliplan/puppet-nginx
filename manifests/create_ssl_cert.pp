define nginx::create_ssl_cert(
  $server_name
) {
  exec { "generate-${name}-certs":
    command => "/usr/bin/openssl req -new -inform PEM -x509 -nodes -days 999 -subj \
    '/C=ZZ/ST=AutoSign/O=AutoSign/localityName=AutoSign/commonName=$server_name/organizationalUnitName=AutoSign/emailAddress=AutoSign/' \
    -newkey rsa:2048 -out /etc/nginx/ssl/${name}.pem -keyout /etc/nginx/ssl/${name}.key",
    unless  => "/usr/bin/test -f /etc/nginx/ssl/${name}.pem",
    require => File['/etc/nginx/ssl'],
    #notify  => Service['nginx'],
  }
}
