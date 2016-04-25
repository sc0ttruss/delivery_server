# the default location for files for our kitchen setup is in a local share
# ~/chef-kits/chef.  This is mounted to /mnt/share/chef on the target vm
# if you alreddy have these in an rpm repo, set source_files to false
# You can also replae file:// with https:// for remote repos.
default['delivery_server']['use_package_manager'] = false
default['delivery_server']['base_package_url'] = 'file:///mnt/share/chef'
# note the package "name" must match the name used by yum/rpm etc.
# get your package list here https://packages.chef.io/stable/el/7/
default['delivery_server']['organisation'] = 'myorg'
default['delivery_server']['packages']['delivery'] = 'delivery-0.4.75-1.el7.x86_64.rpm'

default['delivery_server']['delivery_license'] = 'delivery.license'
default['delivery_server']['delivery_user_private_key'] = 'delivery.pem'
default['delivery_server']['delivery_org_key'] = "#{node['delivery_server']['organisation']}_ssh_key"