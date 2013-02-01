{% if grains['os_family'] == 'RedHat' %}
  {% set pgver = "92" %}
  {% set pgservice = "-9.2" %}
  {% set pgdata = "/var/lib/pgsql/9.2/data/" %}
  {% set pgroot = "/var/lib/pgsql/9.2/data" %}
  {% set ssl = "false" %}
{% elif grains['os_family'] == 'Debian' %}
  {% set pgdata = "/var/lib/postgresql/9.1/main/" %}
  {% set pgroot = "/etc/postgresql/9.1/main" %}
  {% set pgver = "" %}
  {% set pgservice = "" %}
  {% set ssl = "true" %}
{% endif %}

postgres:  
  user.present:
    - shell: /bin/bash
    - home: False
    - system: True

{% if grains['os_family'] == 'RedHat' %}
postgres-pkgs:
  cmd:
    - run
    - name: rpm -Uvh http://yum.postgresql.org/9.2/redhat/rhel-6-i386/pgdg-centos92-9.2-6.noarch.rpm
    - unless: test -e /etc/yum.repos.d/pgdg-92-centos.repo
{% endif %}

postgresql{{ pgver }}:
  pkg:
    - installed
    {% if grains['os_family'] == 'RedHat' %}
    - require:
        - cmd: postgres-pkgs
    {% endif %}

{% if grains['os_family'] == 'RedHat' %}
postgresql{{ pgver }}-contrib:
  pkg:
    - installed

postgresql{{ pgver }}-server:
  pkg:
    - installed
    - require:
        - pkg: postgresql{{ pgver }}
        - pkg: postgresql{{ pgver }}-contrib
{% endif %}

{% if grains['os_family'] == 'Debian' %}
postgres-stopped:
  cmd.run:
    - name: service postgresql{{ pgservice }} stop 
    - unless: test -e {{ pgroot }}/recreated
    - require:
      - pkg: postgresql{{ pgver }}
{% endif %}

pg-rundir:
  file.directory:
    - names:
      - /var/run/postgresql
    - user: postgres
    - group: postgres
    - makedirs: True

postgres-init:
  cmd.run:
    {% if grains['os_family'] == 'RedHat' %}
    - name: service postgresql{{ pgservice }} initdb
    - unless: test -e {{ pgroot }}/base
    - require:
        - pkg: postgresql{{ pgver }}-server
    {% elif grains['os_family'] == 'Debian' %}
    - require:
        - cmd: postgres-stopped
    - name: rm -rf {{ pgdata }} {{ pgroot }} && pg_createcluster -d {{ pgdata }} --locale 'en_US.UTF-8' -e 'UTF-8' 9.1 main
    - unless: test -e {{ pgroot }}/recreated
    {% endif %}

postgres-postinit:
  cmd.run:
    - name: service postgresql{{ pgservice }} restart && touch {{ pgroot }}/recreated
    - unless: test -e {{ pgroot }}/recreated
    - require:
      - file: {{ pgroot }}/pg_hba.conf
      - file: {{ pgroot }}/postgresql.conf

postgresql-service:
  service.running:
    - name: postgresql{{ pgservice }}
    - enable: True
    - reload: True
    - require:
      - user: postgres
      - pkg: postgresql{{ pgver }}
      - cmd: postgres-postinit 
      {% if grains['os_family'] == 'RedHat' %}
      - pkg: postgresql{{ pgver }}-server
      {% endif %}
    - watch:
      - file: {{ pgroot }}/pg_hba.conf
      - file: {{ pgroot }}/postgresql.conf

{{ pgroot }}/postgresql.conf:
  file.managed:
    - source: salt://postgresql/postgresql.conf
    - name: {{ pgroot }}/postgresql.conf
    - template: jinja
    - user: postgres
    - group: postgres
    - mode: 644
    - defaults:
        wal_e: False
        shared_buffers: 24MB
        work_mem: 1MB
        maintenance_work_mem: 16MB
        effective_cache_size: 128MB
        pgdata: {{ pgdata }}
        pgroot: {{ pgroot }}
        ssl: {{ ssl }}
    - require:
      - user: postgres
      - pkg: postgresql{{ pgver }}
      - cmd: postgres-init
      - file: /var/run/postgresql

{{ pgroot }}/pg_hba.conf:
  file.managed:
    - source: salt://postgresql/pg_hba.conf
    - name: {{ pgroot }}/pg_hba.conf
    - user: postgres
    - group: postgres
    - mode: 644
    - require:
      - user: postgres
      - pkg: postgresql{{ pgver }}
      - cmd: postgres-init

{% for db in pillar['pg']['dbs'] %}
postgres-user-{{ db.owner }}:
  postgres_user.present:
    - name: {{ db.owner }}
    - password: {{ db.password }}
    - runas: postgres
    - require:
      - user: postgres
      - service: postgresql{{ pgservice }}
      - cmd: postgres-init

postgresql-database-{{ db.name }}:
  postgres_database.present:
    - name: {{ db.name }}
    - owner: {{ db.owner }}
    - encoding: UTF8
    - lc_ctype: en_US.UTF8
    - lc_collate: en_US.UTF8
    - template: template0
    - runas: postgres
    - require:
      - postgres_user: postgres-user-{{ db.owner }}
      - service: postgresql{{ pgservice }}
      - cmd: postgres-init
{% endfor %}
