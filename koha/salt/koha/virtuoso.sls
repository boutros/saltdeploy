########
# VIRTUOSO 
# NOT USED P.T. !!
########

virtuoso_pkgs:
  pkg.latest:
    - pkgs:
      - libssl-dev
      - gawk
      - gperf 
      - flex 
      - build-essential
      - automake
      - autoconf
      - bison
      - libtool

virtuoso-user:
  user.present:
    - name: {{ pillar['koha']['instance'] }}-virtuoso
    - shell: /bin/bash

{{ pillar['virtuoso']['installdir'] }}:
  file.directory:
    - user: {{ pillar['koha']['instance'] }}-virtuoso
    - makedirs: True
    - recurse:
      - user

/usr/local/src/virtuoso7:
  file.directory:
    - user: {{ pillar['koha']['instance'] }}-virtuoso
    - makedirs: True

/usr/local/src/virtuoso7.tar.gz:
  file.managed:
    - source: {{ pillar['filerepo'] }}/virtuoso7.tar.gz
    - source_hash: md5=fec308b5583ab956e5b96fe7e5a0e017

unpack_virtuoso:
  cmd.run:
    - cwd: /usr/local/src/
    - user: {{ pillar['koha']['instance'] }}-virtuoso
    - unless: test -f /usr/local/src/virtuoso7/INSTALL
    - name: tar zxvf virtuoso7.tar.gz -C /usr/local/src/virtuoso7
    - require:
      - file: /usr/local/src/virtuoso7
      - file: /usr/local/src/virtuoso7.tar.gz

autogen_virtuoso:
  cmd.run:
    - cwd: /usr/local/src/virtuoso7
    - user: {{ pillar['koha']['instance'] }}-virtuoso
    - unless: test -f {{ pillar['virtuoso']['installdir'] }}/bin/virtuoso-t
    - name: CFLAGS="-O2 -m64" ./autogen.sh
    - require:
      - cmd: unpack_virtuoso

build_virtuoso:
  cmd.run:
    - cwd: /usr/local/src/virtuoso7
    - user: {{ pillar['koha']['instance'] }}-virtuoso
    - unless: test -f {{ pillar['virtuoso']['installdir'] }}/bin/virtuoso-t
    - name: CFLAGS="-O2 -m64" ./configure --prefix={{ pillar['virtuoso']['installdir'] }} --disable-dbpedia-vad --disable-demo-vad --disable-fct-vad --disable-isparql-vad --disable-ods-vad --disable-rdfmappers-vad --disable-rdb2rdf-vad --disable-sparqldemo-vad --disable-syncml-vad --disable-tutorial-vad --disable-bpel-vad --with-port=1111
    - require:
      - cmd: autogen_virtuoso
      - file: {{ pillar['virtuoso']['installdir'] }}

install_virtuoso:
  cmd.run:
    - cwd: /usr/local/src/virtuoso7
    - user: {{ pillar['koha']['instance'] }}-virtuoso
    - unless: test -f {{ pillar['virtuoso']['installdir'] }}/bin/virtuoso-t
    - name: make install
    - require:
      - cmd: build_virtuoso

{{ pillar['virtuoso']['installdir'] }}/database/virtuoso.ini:
  file.managed:
    - user: {{ pillar['koha']['instance'] }}-virtuoso
    - source: {{ pillar['saltfiles'] }}/virtuoso/virtuoso.ini.minimal
    - template: jinja
    - makedirs: True    

/etc/init/virtuoso7.conf:
  file.managed:
    - source: {{ pillar['saltfiles'] }}/virtuoso/virtuoso.conf
    - template: jinja

virtuoso7:
  service.running:
    - enable: True
    - require:
      - file: {{ pillar['virtuoso']['installdir'] }}/database/virtuoso.ini
      - file: /etc/init/virtuoso7.conf