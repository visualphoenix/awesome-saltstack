include:
  - nginx

{% set root = "/var/www" %}
{% if grains['os_family'] == 'Debian' %}
  {% set sites_enabled = "/etc/nginx/sites-enabled" %}
{% elif grains['os_family'] == 'RedHat' %}
  {% set sites_enabled = "/etc/nginx/conf.d" %}
{% endif%}

vagrant:
  file.directory:
    - names:
      - {{ root }}/log
      - {{ root }}/public
    - user: {{ pillar['user'] }}
    - group: {{ pillar['user'] }}
    - makedirs: True

vagrant-nginx-available:
  file.managed:
    - name: /etc/nginx/sites-available/{{ pillar['user'] }}.conf
    - source: salt://sites/vagrant.conf
    - template: jinja
    - watch_in:
      - service: nginx
    - defaults:
        ssl: False

vagrant-nginx-enabled:
  file.symlink:
    - name: {{ sites_enabled }}/{{ pillar['user'] }}.conf
    - target: /etc/nginx/sites-available/{{ pillar['user'] }}.conf
    - watch_in:
      - service: nginx
