########
# KOHA DUMMY CIRCULATION DATA
########

https://github.com/digibib/LibrioTools:
  git.latest:
    - rev: master
    - target: /usr/local/src/LibrioTools

/usr/local/src/LibrioTools/sim/circulation.yaml:
  file.managed:
    - source: salt://files/circulation.yaml
    - stateful: True

# run circulation
circulate:
  cmd.run:
    - name: KOHA_CONF=/etc/koha/sites/{{ opts['kohaname'] }}/koha-conf.xml PERL5LIB=/usr/share/koha/lib perl circ.pl -v -f {{ opts['circulationstart'] }} -r {{ opts['daybeforereturn'] }} -c circulation.yaml
    - cwd: /usr/local/src/LibrioTools/sim
    - require:
      - file: /usr/local/src/LibrioTools/sim/circulation.yaml
      - git: https://github.com/digibib/LibrioTools
    - watch: 
      - file: /usr/local/src/LibrioTools/sim/circulation.yaml

returnfromsep2013:
  cmd.run:
    - name: KOHA_CONF=/etc/koha/sites/{{ opts['kohaname'] }}/koha-conf.xml PERL5LIB=/usr/share/koha/lib perl circ.pl -v -z -c circulation.yaml
    - cwd: /usr/local/src/LibrioTools/sim
    - require:
      - file: /usr/local/src/LibrioTools/sim/circulation.yaml
      - git: https://github.com/digibib/LibrioTools
    - watch: 
      - cmd: circulate

rebuildholdsqueue:
  cmd.run:
    - name: koha-foreach --enabled /usr/share/koha/bin/cronjobs/holds/build_holds_queue.pl
    - watch: 
      - cmd: returnfromsep2013