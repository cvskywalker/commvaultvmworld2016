#
# Cookbook Name:: commvaultvmworld
# recipe:: commserveconfig
# Author:: Luke Walker <lwalker@commvault.com>
#
# COPYRIGHT here <todo>
#

unless node['platform_family'] == 'windows'
  return "commvaultvmworld::commserveconfig assumes windows platform, not #{node['platform_family']}"
end

directory 'C:\\Install' do
	action :create
end

template "C:\\Install\\#{node['commvaultvmworld']['xml']['csstoragelibrary']}" do
	source "#{node['commvaultvmworld']['xml']['csstoragelibrary']}.erb"
end

template "C:\\Install\\#{node['commvaultvmworld']['xml']['csstoragepolicy']}" do
	source "#{node['commvaultvmworld']['xml']['csstoragepolicy']}.erb"
end

powershell_script "qlogin" do
	code <<-EOH
	# Necessary because previous commserve recipe completes fast, this executes quickly but MA isn't registered yet
	Start-Sleep -s 600
	& "C:\\Program Files\\Commvault\\ContentStore\\Base\\qlogin.exe" -csn #{node['commvaultvmworld']['qsdk']['commserve_clientname']} -u \"#{node['commvaultvmworld']['qsdk']['user']}\" -ps \"#{node['commvaultvmworld']['qsdk']['encpass']}\"
	EOH

	notifies :run, 'powershell_script[cs_create_storagelib]', :immediately
end

# Set SP, and subclient content
powershell_script "cs_create_storagelib" do
	code <<-EOH
	& "C:\\Program Files\\Commvault\\ContentStore\\Base\\qoperation.exe" execute -af "C:\\Install\\#{node['commvaultvmworld']['xml']['csstoragelibrary']}"
	& "C:\\Program Files\\Commvault\\ContentStore\\Base\\qoperation.exe" execute -af "C:\\Install\\#{node['commvaultvmworld']['xml']['csstoragepolicy']}"
	EOH

	action :nothing
	notifies :run, 'powershell_script[qlogout]', :delayed
end

powershell_script "qlogout" do
	code <<-EOH

	& "C:\\Program Files\\Commvault\\ContentStore\\Base\\qlogout.exe"
	EOH

	action :nothing
end