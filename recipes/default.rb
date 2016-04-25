#
# Cookbook Name:: delivery_server
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

# include_recipe 'delivery_build::credentials'

node['delivery_server']['packages'].each do |name, versioned_name|
  unless node['delivery_server']['use_package_manager']
    remote_file "/var/tmp/#{versioned_name}" do
      source "#{node['delivery_server']['base_package_url']}/#{versioned_name}"
    end
  end
  package name do
    unless node['delivery_server']['use_package_manager']
      source "/var/tmp/#{versioned_name}"
    end
    action :install
  end
end # Loop

# remote_file '/var/tmp/delivery-0.4.75-1.el7.x86_64.rpm' do
#   source 'file:///mnt/share/chef/delivery-0.4.75-1.el7.x86_64.rpm'
#   owner 'root'
#   group 'root'
# end
#
# package 'delivery' do
#   source '/var/tmp/delivery-0.4.75-1.el7.x86_64.rpm'
#   action :install
# end

# Getting and installing a license file

directory '/var/opt/delivery/license' do
  action :create
end


remote_file '/var/opt/delivery/license/delivery.license' do
  source "#{node['delivery_server']['base_package_url']}/delivery.license"
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
  source "#{node['delivery_server']['base_package_url']}/delivery.pem"
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
  ssh-keygen -f #{node['delivery_server']['organisation']}_ssh_key
  EOH
  not_if { ::File.exist? "/etc/delivery/#{node['delivery_server']['organisation']}_ssh_key" }
end

# copy credentials somewhere safe, needs more work,
# will be fine in testkitchen, but nowhere else

remote_file "/mnt/share/chef/#{node['delivery_server']['organisation']}_ssh_key.pub" do
  # source 'http://myfile'
  source "file:///etc/delivery/#{node['delivery_server']['organisation']}_ssh_key.pub"
  owner 'root'
  group 'root'
  mode 00755
  # checksum 'abc123'
end

remote_file "/mnt/share/chef/#{node['delivery_server']['organisation']}_ssh_key" do
  # source 'http://myfile'
  source "file:///etc/delivery/#{node['delivery_server']['organisation']}_ssh_key"
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
  delivery-ctl create-enterprise #{node['delivery_server']['organisation']} --ssh-pub-key-file=/etc/delivery/#{node['delivery_server']['organisation']}_ssh_key.pub > /etc/delivery/passwords.txt
  EOH
  not_if "delivery-ctl list-enterprises |grep #{node['delivery_server']['organisation']}"
end
