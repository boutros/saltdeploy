##########
# KOHA CREATE STATE
# ONLY FOR NEW BASE!
##########
include:
  - koha.koha-defaults

createkohadb:
  cmd.run:
    - name: koha-create --create-db {{ pillar['kohaname'] }}
    - unless: test $(id -u {{ pillar['kohaname'] }}-koha)

# increase memory limits on zebra index
/etc/koha/sites/{{ pillar['kohaname'] }}/zebra-biblios.cfg:
  file.replace:
    - name: /etc/koha/sites/{{ pillar['kohaname'] }}/zebra-biblios.cfg
    - pattern: biblios\/(register|shadow):.+$
    - repl: biblios/\1:100G
    - require:
      - cmd: createkohadb

# enable koha plugins
/etc/koha/sites/{{ pillar['kohaname'] }}/koha-conf.xml:
  file.replace:
    - name: /etc/koha/sites/{{ pillar['kohaname'] }}/koha-conf.xml
    - pattern: <enable_plugins>0
    - repl: <enable_plugins>1
    - require:
      - cmd: createkohadb

# make sure instance config has right permissions
/etc/koha/sites/{{ pillar['kohaname'] }}:
  file.directory:
    - group: {{ pillar['kohaname'] }}-koha
    - user: {{ pillar['kohaname'] }}-koha
    - recurse: 
      - group
      - user
    - watch:
      - file: /etc/koha/sites/{{ pillar['kohaname'] }}/zebra-biblios.cfg
      - file: /etc/koha/sites/{{ pillar['kohaname'] }}/koha-conf.xml

# make sure instance index has right permissions
/var/lib/koha/{{ pillar['kohaname'] }}:
  file.directory:
    - group: {{ pillar['kohaname'] }}-koha
    - user: {{ pillar['kohaname'] }}-koha
    - recurse: 
      - group
      - user
    - watch:
      - file: /etc/koha/sites/{{ pillar['kohaname'] }}/zebra-biblios.cfg
      - file: /etc/koha/sites/{{ pillar['kohaname'] }}/koha-conf.xml