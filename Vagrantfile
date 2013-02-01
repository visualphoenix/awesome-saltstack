# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant::Config.run do |config|
  config.vm.define :salt do |salt_config|
    salt_config.vm.network :hostonly, "33.33.33.30"
    salt_config.vm.forward_port 80, 8080
    salt_config.vm.host_name  = "lepp.dev"
    salt_config.vm.box        = "precise32"
#    salt_config.vm.box        = "centos63-32"
    salt_config.ssh.timeout   = 300
    salt_config.ssh.max_tries = 300
    salt_config.vm.provision :shell, :inline => "grep '[ \t]salt' /etc/hosts || echo -e '127.0.0.1\t salt' >> /etc/hosts ; which salt-call 2>&1 1>/dev/null || wget --no-check-certificate -O - https://raw.github.com/visualphoenix/salt-bootstrap/fix-centos/bootstrap-salt-minion.sh | sudo sh -s -- git develop ; sudo cp -R /vagrant/* /srv/ ; sudo chown -R vagrant:vagrant /srv/* ; cd /srv ; ./refresh.sh"
    salt_config.vm.share_folder "v-root", "/vagrant", "./vagrant", {:nfs => true}
    salt_config.vm.share_folder "www", "/var/www", "./www", {:nfs => true}
  end
end
