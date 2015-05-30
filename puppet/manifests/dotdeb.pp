class apt::source::dotdeb {

  exec { "add-dotdeb-key":
    command => "curl -L --silent 'http://www.dotdeb.org/dotdeb.gpg' | apt-key add -",
    unless  => "apt-key list | grep -q dotdeb"
  }

  apt::source { "dotdeb":
    location => "http://packages.dotdeb.org",
    release => "wheezy-php55",
    repos => "all",
    require => Exec["add-dotdeb-key"]
  }
}