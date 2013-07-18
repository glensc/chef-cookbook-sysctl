#
# Cookbook Name:: sysctl
# Recipe:: default
#
# Copyright 2013, OneHealth Solutions, Inc.
# Copyright 2013, Elan Ruusamäe <glen@delfi.ee>
#

apply_sysctl = "#{Chef::Config[:file_cache_path]}/apply-sysctl"
cookbook_file apply_sysctl do
	source "apply-sysctl"
	mode 00755
	action :create
end

bash "apply-sysctl" do
  code apply_sysctl
  action :nothing
end

sysctl_path = if(node['sysctl']['conf_dir'])
  directory node['sysctl']['conf_dir'] do
    owner "root"
    group "root"
    mode 0755
    action :create
  end
  File.join(node['sysctl']['conf_dir'], '99-chef-attributes.conf')
else
  node['sysctl']['allow_sysctl_conf'] ? '/etc/sysctl.conf' : nil
end

if(sysctl_path)
  template sysctl_path do
    action :nothing
    source 'sysctl.conf.erb'
    mode '0644'
    notifies :start, "bash[apply-sysctl]", :immediately
    only_if do
      node['sysctl']['params'] && !node['sysctl']['params'].empty?
    end
  end

  ruby_block 'sysctl config notifier' do
    block do
      true
    end
    notifies :create, "template[#{sysctl_path}]", :delayed
  end
end
