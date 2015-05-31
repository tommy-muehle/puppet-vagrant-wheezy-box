Exec { path => [ "/bin/", "/sbin/", "/usr/bin/", "/usr/sbin/", "/usr/local/bin" ]}
File { owner => 0, group => 0, mode => 0644}

import "dotdeb.pp"

stage { "pre":
  before => Stage["main"],
}

class { "apt":
  stage => "pre",
  update => {
    frequency => "daily",
  }
}
class { "apt::source::dotdeb":
  stage => "pre"
}

package {[ "vim", "php5-cli", "php5-cgi", "php5-xdebug"
]:
  ensure  => "installed",
}

class { "ohmyzsh": }
ohmyzsh::install { ["root", "vagrant"]: }
ohmyzsh::theme { ["root", "vagrant"]: theme => "avit" }
ohmyzsh::plugins { "root": plugins => "git composer colorize rsync" }
ohmyzsh::plugins { "vagrant": plugins => "git composer colorize rsync" }

class { "::mysql::server":
  root_password => "start100",
  remove_default_accounts => true
}
mysql::db { "tm":
  user => "tm",
  password => "start100",
  host => "localhost",
  grant => ["ALL"],
}

class { "apache": }
class { "apache::mod::rewrite": }
class { "apache::mod::fcgid":
  options => {
    "AddHandler" => "fcgid-script .php",
  },
}

apache::vhost { "tommy-muehle.dev":
  port => "80",
  docroot => "/var/www/tommy-muehle_dev/web",
  directories => {
    path => "/var/www/tommy-muehle_dev",
    options => ["ExecCGI", "FollowSymLinks"],
    allow_override => ["All"],
    fcgiwrapper => {
      command => "/usr/bin/php5-cgi",
    }
  },
  require => [ Package["php5-cgi"] ]
}

file { "/usr/bin/php":
  ensure => "link",
  target => "/usr/bin/php5",
  require => Package["php5-cli"]
}

file { "/etc/php5/cgi/conf.d/99-overwrites.ini":
  target => "/vagrant/files/php/99-overwrites.ini",
  require => Package["php5-cli"]
}
