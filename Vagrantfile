# -*- mode: ruby -*-
VAGRANTFILE_API_VERSION = '2'
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.provider :virtualbox do |vbox, override|
    override.vm.box = 'trusty-amd64'
    vbox.customize ["modifyvm", :id, "--memory", 512]
  end

  config.vm.host_name = 'db.local'

  config.vm.provision :ansible do |ansible|
    ansible.playbook = 'site.yml'
    ansible.inventory_path = 'vagrant_ansible_inventory'
    ansible.limit = 'all'
    ansible.host_key_checking = false
#    ansible.verbose = 'vvvv'
  end

end
