##########
# KOHA IMPORT 15000_eximport STATE
##########

include:
  - koha.salt.roots.salt.koha-create

# marcxml file with 15000 records and items
/tmp/15000_eximport.xml:
  file.managed:
    - source: {{ pillar['filerepo'] }}/15000_eximport.xml
    - source_hash: md5=c18b2c01d143a93a7ecdb608169bab08  

import15000ex:
  cmd.run:
    - name: sudo koha-shell knakk -c "perl -I /usr/share/koha/lib/ /usr/share/koha/bin/migration_tools/bulkmarcimport.pl -m marcxml -file /tmp/15000_eximport.xml"
    - user: {{ pillar['kohaname'] }}-koha
    - require:
      - file: /tmp/15000_eximport.xml
      - cmd: createkohadb

rebuildzebra:
  cmd.run:
    - name: sudo koha-rebuild-zebra --full --quiet {{ pillar['kohaname'] }}
    - watch: 
      - cmd: import15000ex