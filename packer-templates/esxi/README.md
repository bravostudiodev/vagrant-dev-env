# vagrant-dev-env

Packer template for building vagrant ESXi box of VirtualBox.

# How to use

Install HashiCorp tool packer from official website.

    packer build -var iso_path=iso/VMware-VMvisor-Installer-201701001-4887370.x86_64.iso esxi-iso.json

This build evalutaion box in which you can later set your free license key by invoking command:

    ssh root@x.x.x.x "vim-cmd vimsvc/license --set xxxxx-xxxxx-xxxxx-xxxxx-xxxx"
