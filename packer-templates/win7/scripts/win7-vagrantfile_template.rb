# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.require_version ">= 1.6.2"

Vagrant.configure("2") do |config|

    # Vagrant doesn't support insert key on ESXi so let's stick with the unsecure
    # key for now.
    config.ssh.insert_key = false

    config.vm.communicator = "winrm"

    # Admin user name and password
    config.winrm.username = "vagrant"
    config.winrm.password = "vagrant"

    config.vm.guest = :windows
    config.windows.halt_timeout = 15

    config.vm.network :forwarded_port, guest: 3389, host: 3389, id: "rdp", auto_correct: true
    config.vm.network :forwarded_port, guest: 22, host: 2222, id: "ssh", auto_correct: true

    config.vm.provider :virtualbox do |v, override|
        #v.gui = true
        v.customize ["modifyvm", :id, "--memory", 2048]
        v.customize ["modifyvm", :id, "--cpus", 2]
        v.customize ["setextradata", "global", "GUI/SuppressMessages", "all" ]
    end

    %w('vmware_fusion', 'vmware_workstation'').each do |p|
        config.vm.provider p do |v|
            #v.gui = true
            v.vmx["memsize"] = "2048"
            v.vmx["numvcpus"] = "2"
            v.vmx["ethernet0.virtualDev"] = "vmxnet3"
            v.vmx["RemoteDisplay.vnc.enabled"] = "false"
            v.vmx["RemoteDisplay.vnc.port"] = "5900"
            v.vmx["scsi0.virtualDev"] = "lsisas1068"
        end
    end
end
