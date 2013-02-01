base:
  "*":
    - sshd
    - vim
  "lepp.*":
    - nginx
    - postgresql
    - php_fpm
    - sites.vagrant
  "yoursitehere.com":
    - nginx
    - postgresql
    - php_fpm
    - sites.yoursitehere
