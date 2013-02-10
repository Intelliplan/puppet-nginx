class nginx::params {

  $user = 'www-data'
  $group = 'root'

  $worker_processes = '1'
  $worker_connections = '1024'

  $etc_dir = '/etc/nginx'
  $data_dir = '/var/www'
  $log_dir  = '/var/log/nginx'
  $pid_dir  = '/var/run/nginx.pid'

  $includes_dir = "${etc_dir}/includes"
  $proxy_params = "${includes_dir}/proxy_params"
  $conf = '${etc_dir}/conf.d'
  $sites_enabled = '${etc_dir}/sites-enabled'
  $sites_available = '${etc_dir}/sites-available'
}
