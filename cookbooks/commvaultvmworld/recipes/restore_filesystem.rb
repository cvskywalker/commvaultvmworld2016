#
# Cookbook Name:: commvaultvmworld
# recipe:: example2_restore
# Author:: Luke Walker <lwalker@commvault.com>
#
# COPYRIGHT here <todo>
#

if platform?("windows")
	template "C:/tmp/#{node['commvaultvmworld']['xml']['restore_filesystem']}" do
		source "#{node['commvaultvmworld']['xml']['restore_filesystem']}.erb"
	end

	powershell_script "configure_and_execute" do
		code <<-EOH
		& "C:\\Program Files\\Commvault\\ContentStore\\Base\\qlogin.exe" -csn #{node['commvaultvmworld']['qsdk']['commserve_clientname']} -u \"#{node['commvaultvmworld']['qsdk']['user']}\" -ps \"#{node['commvaultvmworld']['qsdk']['encpass']}\"
		& "C:\\Program Files\\Commvault\\ContentStore\\Base\\qoperation.exe" execute -af "C:/tmp/#{node['commvaultvmworld']['xml']['restore_filesystem']}"
		& "C:\\Program Files\\Commvault\\ContentStore\\Base\\qlogout.exe"
		EOH
	end
else
	template "/tmp/#{node['commvaultvmworld']['xml']['restore_filesystem']}" do
		source "#{node['commvaultvmworld']['xml']['restore_filesystem']}.erb"
	end

	bash "configure_and_execute" do
		user 'root'
		code <<-EOH
		/opt/commvault/Base/qlogin -u admin -ps "#{node['commvaultvmworld']['qsdk']['encpass']}"
    	/opt/commvault/Base/qoperation execute -af /tmp/#{node['commvaultvmworld']['xml']['restore_filesystem']}
    	/opt/commvault/Base/qlogout
		EOH
	end
end