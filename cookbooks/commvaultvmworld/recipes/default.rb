#
# Cookbook Name:: commvaultvmworld
# recipe:: default
# Author:: Luke Walker <lwalker@commvault.com>
#
# COPYRIGHT here <todo>
#
if platform?("windows")

	include_recipe 'chocolatey'

	# vcredist2010 - skipped due to empty checksum
	%w{googlechrome 7zip DotNet3.5 DotNet4.0 DotNet4.5}.each do |pkgname|
		chocolatey pkgname
	end
else

	apt_package 'vim' do
		:install
	end

	apt_package 'cifs-utils' do
		:install
		not_if { node['commvaultvmworld']['buildmethod'] == "vagrantfolder" }
	end
end