#
# Cookbook Name:: commvaultvmworld
# recipe:: convert_to_frel
# Author:: Luke Walker <lwalker@commvault.com>
#
# COPYRIGHT here <todo>
#

unless node['platform_family'] == 'debian'
  return "commvaultvmworld::convert_to_frel assumes debian family, not #{node['platform_family']}"
end

apt_package 'xfsprogs' do
	:install
end

directory '/etc/CommVaultRegistry/Galaxy/Instance001/3Dfs' do
	action :create
end

file '/etc/CommVaultRegistry/Galaxy/Instance001/3Dfs/.properties' do
	action :create_if_missing
end

append_line "/etc/CommVaultRegistry/Galaxy/Instance001/3Dfs/.properties" do
	line "s3dfsRootDir #{node['commvaultvmworld']['xml']['frelconversion_directory']}"
end

directory node['commvaultvmworld']['xml']['frelconversion_directory'] do
	action :create
end

append_line "/etc/CommVaultRegistry/Galaxy/Instance001/Session/.properties" do
	line "nFBRDELAYEDINIT 1"
end

append_line "/etc/CommVaultRegistry/Galaxy/Instance001/Session/.properties" do
	line "nFBRSkipFsck 1"
end

append_line "/etc/CommVaultRegistry/Galaxy/Instance001/Session/.properties" do
	line "sLNFBR /opt/commvault/Base/libCvBlkFBR.so"
end

append_line "/etc/CommVaultRegistry/Galaxy/Instance001/Session/.properties" do
	line "dFBRDIR #{node['commvaultvmworld']['xml']['frelconversion_directory']}"
end

# at this point, we're going to cheat here and stuff this in a file
bash "create_fake_xfs_layer" do
    user 'root'
    code <<-EOH
    rm -f /opt/commvault/3Dfs.fake
    dd if=/dev/zero of=/opt/commvault/3Dfs.fake bs=1M count=8192
    mkfs.xfs /opt/commvault/3Dfs.fake
    mount /opt/commvault/3Dfs.fake /opt/commvault/3Dfs
    EOH
end

append_line "/etc/fstab" do
	line "/opt/commvault/3Dfs.fake  /opt/commvault/3Dfs  xfs  defaults  0  0"
end

# necessary, as script is interactive only .. until this patch
replace_line "/opt/commvault/Base/cvfbr_validate.sh" do
	replace "./qlogin_cmd"
	with "./qlogin_cmd -u admin -ps #{node['commvaultvmworld']['qsdk']['encpass']}"
end

execute 'frel_validate' do
	user 'root'
	command '/opt/commvault/Base/cvfbr_validate.sh -instance Instance001'
end
