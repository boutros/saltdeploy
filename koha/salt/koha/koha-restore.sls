##########
# KOHA RESTORE STATE
##########

include:
  - koha.koha-create

# # remove koha instance first
# removekohainstance:
#   cmd.run:
#     - name: koha-remove {{ pillar['koha']['instance'] }}

##########
# RESTORE FILES
##########

# 500ex database for knakk
/tmp/{{ pillar['koha']['instance'] }}-2013-10-22.sql.gz:
  file.managed:
    - source: {{ pillar['filerepo'] }}/{{ pillar['koha']['instance'] }}-2013-10-22.sql.gz
    - source_hash: md5=b3367bad920b42948322d3f735784a99

# 500ex file structure for knakk
/tmp/{{ pillar['koha']['instance'] }}-2013-10-22.tar.gz:
  file.managed:
    - source: {{ pillar['filerepo'] }}/{{ pillar['koha']['instance'] }}-2013-10-22.tar.gz
    - source_hash: md5=36bb6ce2496f2570ae8c22c4a038fe5f

##########
# RESTORE COMMANDS
##########

recreate_files:
  cmd.run:
    - name: tar -C / -xf /tmp/{{ pillar['koha']['instance'] }}-2013-10-22.tar.gz
    - require:
      - file: /tmp/{{ pillar['koha']['instance'] }}-2013-10-22.tar.gz

recreate_mysql:
  cmd.run:
    - name: zcat /tmp/{{ pillar['koha']['instance'] }}-2013-10-22.sql.gz | koha-mysql {{ pillar['koha']['instance'] }}
    - require: 
      - cmd: recreate_files
      - file: /tmp/{{ pillar['koha']['instance'] }}-2013-10-22.sql.gz
