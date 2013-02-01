{% if grains['os_family'] == 'RedHat' %}
openssh:
  pkg:
    - installed
  service.running:
    - name: sshd
    - enable: True
    - watch:
      - file: /etc/ssh/sshd_config
      - pkg: openssh
{% elif grains['os'] == 'Debian' %}
ssh:
  pkg:
    - installed
  service.running:
    - enable: True
    - watch:
      - file: /etc/ssh/sshd_config
      - pkg: ssh
{% endif %}

/etc/ssh/sshd_config:
  file.managed:
    - name: /etc/ssh/sshd_config
    - source: salt://sshd/sshd_config
    - template: jinja
