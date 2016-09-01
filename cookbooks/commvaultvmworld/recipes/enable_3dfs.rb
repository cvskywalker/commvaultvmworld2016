#
# Cookbook Name:: commvaultvmworld
# recipe:: enable_3dfs
# Author:: Luke Walker <lwalker@commvault.com>
#
# COPYRIGHT here <todo>
#

unless node['platform_family'] == 'debian'
  return "commvaultvmworld::enable_3dfs assumes debian family, not #{node['platform_family']}"
end

template "/tmp/#{node['commvaultvmworld']['xml']['enable_3dfs']}" do
	source "#{node['commvaultvmworld']['xml']['enable_3dfs']}.erb"
end

bash "enable_3dfs" do
    user 'root'
    code <<-EOH
    /opt/commvault/Base/qlogin -u admin -ps "#{node['commvaultvmworld']['qsdk']['encpass']}"
    /opt/commvault/Base/qoperation execute -af /tmp/#{node['commvaultvmworld']['xml']['enable_3dfs']}
    /opt/commvault/Base/qlogout
    EOH
end