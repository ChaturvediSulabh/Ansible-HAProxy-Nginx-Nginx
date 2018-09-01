# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  
  config.vm.synced_folder ".", "/vagrant", :nfs => { :mount_options => ["dmode=777","fmode=777"] }
    

  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--nictype1", "virtio"]        
 end  

  # Ansible
  config.vm.define :controller do |controller|
      controller.vm.box = "centos/6"
      controller.vm.hostname = "controller"
      controller.vm.network :private_network, ip: "192.168.30.4"
      controller.vm.provider "virtualbox" do |vb|
        vb.memory = "256"
      end
      controller.vm.provision :shell, path: "ansible-bootstrap.sh"
      controller.vm.provision :shell, path: "common-bootstrap.sh"
      controller.vm.provision :file, source: "/Users/schaturvedi/Desktop/CELERAONE_APP_TASK_SUBMISSION/Production", destination: "/home/vagrant/"

  end

  # HAProxy
  config.vm.define :loadbalancer do |loadbalancer|
      loadbalancer.vm.box = "centos/6"
      loadbalancer.vm.hostname = "Test1"
      loadbalancer.vm.network :private_network, ip: "192.168.30.1"
      loadbalancer.vm.network "forwarded_port", guest: 80, host: 8001
      loadbalancer.vm.provider "virtualbox" do |vb|
        vb.memory = "256"
      end
      loadbalancer.vm.provision :shell, path: "common-bootstrap.sh"
  end

  # NGINX
  (2..3).each do |i|
    config.vm.define "webserver#{i}" do |webserver|
        webserver.vm.box = "centos/6"
        webserver.vm.hostname = "Test#{i}"
        webserver.vm.network :private_network, ip: "192.168.30.#{i}"
        webserver.vm.network "forwarded_port", guest: 8000, host: "800#{i}"
        webserver.vm.provider "virtualbox" do |vb|
          vb.memory = "256"
        end
        webserver.vm.provision :shell, path: "common-bootstrap.sh"
    end
  end
end
