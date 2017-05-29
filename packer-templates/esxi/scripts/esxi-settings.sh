set -ex

esxcli network firewall ruleset set -e true -r httpClient
esxcli system settings advanced set -o /Net/GuestIPHack -i 1

# https://pubs.vmware.com/vsphere-60/index.jsp?topic=%2Fcom.vmware.vcli.examples.doc%2Fcli_manage_users.9.5.html

sed -e 's/^\(password\s*requisite\s*.*\)$/#\1/' \
    -e 's/^\(password\s*required\s*.*\)$/#\1/' \
    -e 's/^\(password\s*sufficient\s*.*\) use_authtok \(.*\)$/\1 \2/' \
    -i /etc/pam.d/passwd

esxcli system account add -i vagrant -p vagrant -c vagrant

sed -e 's/^#\(password\s*requisite\s*.*\)$/\1/' \
    -e 's/^#\(password\s*required\s*.*\)$/\1/' \
    -e 's/^\(password\s*sufficient\s*.*pam_unix.so\) \(.*\)$/\1 use_authtok \2/' \
    -i /etc/pam.d/passwd

# http://kblnrz.blogspot.ba/2016/11/vcap-dcv-addedit-remove-users-on-esxi_21.html
esxcli system permission set -i vagrant -r Admin

# Remove unsupported SSHD option
sed -e 's/^\(PrintLastLog .*\)$/#\1/' -i /etc/ssh/sshd_config

# vagrant insecure key is authorized on every boot in /etc/rc.d/local.sh
