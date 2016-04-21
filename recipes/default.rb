#
# Cookbook Name:: delivery_server
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

remote_file '/var/tmp/delivery-0.4.75-1.el7.x86_64.rpm' do
  source 'file:///mnt/share/chef/delivery-0.4.75-1.el7.x86_64.rpm'
  owner 'root'
  group 'root'
end

package 'delivery' do
  source '/var/tmp/delivery-0.4.75-1.el7.x86_64.rpm'
  action :install
end

# Getting and installing a license file

directory '/var/opt/delivery/license' do
  action :create
end


remote_file '/var/opt/delivery/license/delivery.license' do
  source 'file:///mnt/share/chef/delivery.license'
  owner 'root'
  group 'root'
end

directory '/etc/delivery' do
  owner 'root'
  group 'root'
  mode 00755
  recursive true
  action :create
end

# Create a basic Delivery Configuration

template '/etc/delivery/delivery.rb' do
  source 'delivery.rb.erb'
  owner 'root'
  group 'root'
  mode 00755
end

remote_file '/etc/delivery/delivery.pem' do
  # source 'http://myfile'
  source 'file:///mnt/share/chef/delivery.pem'
  owner 'root'
  group 'root'
  mode 00755
  # checksum 'abc123'
end

bash 'reconfigure delivery' do
  user 'root'
  cwd '/var/tmp'
  code <<-EOH
  delivery-ctl reconfigure
  EOH
end

# Creating the Delivery Enterprise/Org(s)

bash 'generate Enterprise SSH credentials' do
  user 'root'
  cwd '/var/tmp'
  code <<-EOH
  cd /etc/delivery
  ssh-keygen -f myorg_ssh_key
  EOH
end

# copy credentials somewhere safe, needs more work,
# will be fine in testkitchen, but nowhere else

remote_file '/mnt/share/chef/myorg_ssh_key.pub' do
  # source 'http://myfile'
  source 'file:///etc/delivery/myorg_ssh_key.pub'
  owner 'root'
  group 'root'
  mode 00755
  # checksum 'abc123'
end

remote_file '/mnt/share/chef/myorg_ssh_key' do
  # source 'http://myfile'
  source 'file:///etc/delivery/myorg_ssh_key'
  owner 'root'
  group 'root'
  mode 00755
  # checksum 'abc123'
end

# Create the Enterprise

bash 'create the delivery Enterprise' do
  user 'root'
  cwd '/tmp'
  code <<-EOH
  delivery-ctl create-enterprise myorg --ssh-pub-key-file=/etc/delivery/myorg_ssh_key.pub >> /etc/delivery/passwords.txt
  EOH
end
