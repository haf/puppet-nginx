# Define: nginx::site::fcgi
#
# Create a fcgi site config from template using parameters.
# You can use my php5-fpm class to manage fastcgi servers.
#
# XXX - consider making the php5-pfm module a dependency and used here?
#
# Parameters :
# * ensure: typically set to "present" or "absent". Defaults to "present"
# * root: document root (Required)
# * fastcgi_pass : port or socket on which the FastCGI-server is listening (Required)
# * server_name : server_name directive (could be an array)
# * listen : address/port the server listen to. Defaults to 80. Auto enable ssl if 443
# * access_log : custom acces logs. Defaults to /var/log/nginx/$name_access.log
# * include : custom include for the site (could be an array). Include files must exists
#   to avoid nginx reload errors. Use with nginx::site_include
# * ssl_certificate : ssl_certificate path. If empty auto-generating ssl cert
# * ssl_certificate_key : ssl_certificate_key path. If empty auto-generating ssl cert key
#   See http://wiki.nginx.org for details.
#
# Templates :
# * nginx/fcgi_site.erb
#
# Sample Usage :
#   nginx::site::fcgi { 'default':
#     root         => '/var/www/nginx-default',
#     fastcgi_pass => '127.0.0.1:9000',
#     server_name  => ['localhost', $hostname, $fqdn],
#   }
#
#   nginx::site::fcgi { 'default-ssl':
#     listen          => '443',
#     root            => '/var/www/nginx-default',
#     fastcgi_pass    => '127.0.0.1:9000',
#     server_name     => $fqdn,
#     template        => 'nginx/fcgi_mono_site.erb' 
#   }
#
define nginx::site::fcgi(
  $root                = undef,
  $fastcgi_pass        = undef,
  $ensure              = 'present',
  $index               = 'index.php',
  $include             = '',
  $listen              = '80',
  $server_name         = undef,
  $access_log          = undef,
  $ssl_certificate     = undef,
  $ssl_certificate_key = undef,
  $ssl_session_timeout = '5m',
  $template            = 'nginx/fcgi_site.erb') {

      # the stuff in this class ought to be brought in here..
      class { 'nginx::config::fcgi': }
    
      $real_server_name = $server_name ? {
        undef   => $name,
        default => $server_name,
      }
    
      $real_access_log = $access_log ? {
        undef   => "/var/log/nginx/${name}_access.log",
        default => $access_log,
      }
    
      # Autogenerating ssl certs
      if $listen == '443' and  $ensure == 'present' and ($ssl_certificate == undef or $ssl_certificate_key == undef) {
        nginx::create_ssl_cert { $name: }
      }
    
      $real_ssl_certificate = $ssl_certificate ? {
        undef   => "/etc/nginx/ssl/${name}.pem",
        default => $ssl_certificate,
      }
    
      $real_ssl_certificate_key = $ssl_certificate_key ? {
        undef   => "/etc/nginx/ssl/${name}.key",
        default => $ssl_certificate_key,
      }
    
      nginx::site { $name:
        ensure  => $ensure,
        content => template($template),
        root    => $root,
      }
}
