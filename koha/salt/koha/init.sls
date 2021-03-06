##########
# KOHA Development server
# BASED ON UBUNTU RARING SERVER 64bit
# PACKAGES
##########

koharepo:
  pkgrepo.managed:
    - name: deb http://debian.koha-community.org/koha squeeze main
    - key_url: http://debian.koha-community.org/koha/gpg.asc
    - require_in: koha-common

installpkgs:
  pkg.latest:
    - pkgs:
      - language-pack-nb
      - git
      - build-essential
      - curl
      - imagemagick
      - screen
      - libav-tools
      - sqlite3
      - libsqlite3-dev
      - openssh-server
      - python-software-properties
      - software-properties-common
      - libnet-ssleay-perl 
      - libcrypt-ssleay-perl
      - openssh-server
      - lynx
      - apache2
      - mysql-client
      - mysql-server
      - koha-common
    - skip_verify: True
    - require:
      - pkgrepo: koharepo

########
# APACHE
########

/etc/apache2/ports.conf:
  file.append:
    - text:
      - Listen 8080
      - Listen 8081
    - stateful: True

apacheconfig:
  file.managed:
    - name: /etc/apache2/sites-available/{{ pillar['koha']['instance'] }}.conf
    - source: {{ pillar['saltfiles'] }}/apache.tmpl
    - template: jinja
    - context:
      OpacPort: 8080
      IntraPort: 8081
      ServerName: {{ pillar['koha']['instance'] }}

sudo a2enmod rewrite:
  cmd.run:
    - require:
      - pkg: installpkgs

sudo a2dismod mpm_event:
  cmd.run:
    - require:
      - pkg: installpkgs

sudo a2dismod mpm_itk:
  cmd.run:
    - require:
      - pkg: installpkgs

sudo a2dismod mpm_prefork:
  cmd.run:
    - require:
      - pkg: installpkgs

sudo a2enmod mpm_itk:
  cmd.run:
    - require:
      - pkg: installpkgs

sudo a2enmod cgi:
  cmd.run:
    - require:
      - pkg: installpkgs

sudo a2dissite 000-default:
  cmd.run:      
    - require:
      - pkg: installpkgs

apache2:
  service:
    - running
    - require:
      - pkg: installpkgs
      - cmd: sudo a2enmod rewrite
      - cmd: sudo a2enmod cgi
      - cmd: sudo a2dissite 000-default
      - file: /etc/apache2/ports.conf

##########
# MYSQL
##########

mysqlrepl1:
  file.replace:
    - name: /etc/mysql/my.cnf
    - pattern: max_allowed_packet.+$
    - repl: max_allowed_packet = 64M

mysqlrepl2:
  file.replace:
    - name: /etc/mysql/my.cnf
    - pattern: wait_timeout.+$
    - repl: wait_timeout = 6000

mysql:
  service:
    - running
    - require:
      - pkg: installpkgs
    - watch:
      - file: /etc/mysql/my.cnf

