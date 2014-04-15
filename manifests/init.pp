class kibana (
    $home_path = "/usr/local/nginx/conf/vhost",
    $vhost_conf = "/usr/local/nginx/conf/vhost/kibana.conf",
    $htpasswdfile = "/usr/local/nginx/conf/vhost/kibana.htpasswd",
    $vhost = "kibana.xx.com",
    $htpassuser = "root",
    $htpasspwd  = "xxx",
) {

    file {$home_path:
        ensure  => directory,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
    }

    htpasswd {$htpassuser:
        cryptpasswd => $htpasspwd,
        target      => $htpasswdfile,
        require => file[$home_path],
    }

    file {"kibana_vhost":
       ensure  => present,
       owner   => 'root',
       group   => 'root',
       mode    => '0644',
       require => file[$home_path],
       path    => $vhost_conf,
       content => template('kibana/vhost.erb'),
       notify  => Service["nginxd"],
    }

   file {"kibana":
        ensure => present,
        owner => 'root',
        group => 'root',
        mode => '0644',
        path => '/tmp/kibana-3.0.1-1.x86_64.rpm',
        source => 'puppet:///modules/kibana/kibana-3.0.1-1.x86_64.rpm', 
        require => File["kibana_vhost"],
    }

    package {"kibana":
        ensure  => present,
        provider => rpm,
        source   => "/tmp/kibana-3.0.1-1.x86_64.rpm",
        require => File["kibana"],
    } 

    file {"config.js":
        ensure => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => Package["kibana"],
        path    => '/var/www/html/kibana/config.js',
        content => template('kibana/config.erb'),
    }

    service { "nginxd":
        ensure  => running,
        enable  => true,
        subscribe => File['kibana_vhost'],
    }

}
