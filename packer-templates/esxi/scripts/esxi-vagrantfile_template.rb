Vagrant.require_version '>= 1.6.2'

Vagrant.configure('2') do |config|
  # Set default shell to SH.
  config.ssh.shell = 'sh'

  # Vagrant doesn't support insert key on ESXi so let's stick with the unsecure
  # key for now.
  config.ssh.insert_key = false

  # Do not sync default /vagrant folder on ESXi.
  config.vm.synced_folder '.', '/vagrant', disabled: true

  # We don't have NFS working inside ESXi so we flag this just in case.
  config.nfs.functional = false

  %w('vmware_fusion', 'vmware_workstation', 'vmware_appcatalyst').each do |p|
    config.vm.provider p do |v|
      v.vmx['memsize'] = '4096'
      v.vmx['numvcpus'] = '2'
      # Use paravirtualized virtual hardware on VMW hypervisors.
      v.vmx['ethernet0.virtualDev'] = 'vmxnet3'
      # Enable nested virtualization.
      v.vmx['vhv.enable'] = 'true'
    end
  end

  %w('virtualbox').each do |p|
    config.vm.provider p do |v|
      v.memory = '4096'
      v.cpus = 2
    end
  end

  config.vm.provider :vcenter do |vcenter|
    vcenter.num_cpu = 2
    vcenter.memory = 4096
    vcenter.enable_vm_customization = false
  end

  cmdline_args = ARGV
  cmdline_args.each do |optarg|
    opt, arg = optarg.split('=', 2)
    case opt
    when '--license-key'
      config.vm.provision :shell do |s|
        s.args = arg
        s.privileged = false
        s.inline = <<-SHELL
          vim-cmd vimsvc/license --set $1
        SHELL
      end
    end
  end
    
end
