# ESXi vagrant box

Packer template for building vagrant ESXi box for VirtualBox.

# Build

Install VirtualBox 5.1 or newer and install HashiCorp packer tool from official website then run:

    packer build -var iso_path=iso/VMware-VMvisor-Installer-201701001-4887370.x86_64.iso esxi-iso.json
    mv ./packer_esxi_virtualbox.box ~/vmboxes/

# Usage

Add box to vagrant:

    vagrant box add --name bravostudiodev/esxi ~/vmboxes/packer_esxi_virtualbox.box
    vagrant init bravostudiodev/esxi

This box contains ESXi in evaluation mode but you can set your free license key when provisioning vagrant instance:

    vagrant --license-key=xxxxx-xxxxx-xxxxx-xxxxx-xxxx up
