#
# Cookbook Name:: commvaultvmworld
# recipe:: commserve
# Author:: Luke Walker <lwalker@commvault.com>
#
# COPYRIGHT here <todo>
#

unless node['platform_family'] == 'windows'
  return "commvaultvmworld::commserve assumes windows platform, not #{node['platform_family']}"
end

directory 'C:\\Install' do
	action :create
	notifies :run, 'powershell_script[download_package]', :immediately
end

template "C:\\Install\\#{node['commvaultvmworld']['xml']['csinstall']}" do
	source "#{node['commvaultvmworld']['xml']['csinstall']}.erb"
end


if node.default['commvaultvmworld']['buildmethod'] == "s3"
	powershell_script "download_package" do
		code <<-EOH
		Import-Module AWSPowershell

		Write-Host "download_package: Building with method #{node['commvaultvmworld']['buildmethod']}"

		Copy-S3Object -BucketName #{node['commvaultvmworld']['buildbucket']['bucket']} -Key #{node['commvaultvmworld']['buildbucket']['CS']} -LocalFile C:\\Install\\#{node['commvaultvmworld']['buildbucket']['FS_MA_VSA']}

		Add-Type -Assembly "System.IO.Compression.Filesystem"
		[io.compression.zipfile]::ExtractToDirectory("C:\\Install\\#{node['commvaultvmworld']['buildbucket']['CS']}", "C:\\Install")

		Remove-Item C:\\Install\\#{node['commvaultvmworld']['buildbucket']['CS']}
		EOH

		notifies :run, 'powershell_script[install_commserve]', :immediately
		notifies :run, 'powershell_script[cleanup]', :delayed
	end

	# We've made some assumptions as to how the zip file has been packaged up...
	powershell_script "install_commserve" do
		cwd Chef::Config[:file_cache_path]
		timeout 7200
		code <<-EOH
		$stream = [System.IO.StreamWriter] "install.log"
		$deploy = Start-Process C:\\Install\\DownloadPackageLocation2_WinX64\\Setup.exe -ArgumentList '/silent /play "C:\\Install\\#{node['commvaultvmworld']['xml']['csinstall']}"' -verb RunAs -Wait

		$stream.WriteLine($deploy)
		$stream.close()
		EOH

		action :nothing
	end
	
elsif node.default['commvaultvmworld']['buildmethod'] == "vagrantfolder"
	powershell_script "download_package" do
		code <<-EOH
		Write-Host "download_package: Building with method #{node['commvaultvmworld']['buildmethod']}"

		if (!(Test-Path "C:\\Install\\DownloadPackageLocation_WinX64\\Setup.exe")) {
			Add-Type -Assembly "System.IO.Compression.Filesystem"
			[io.compression.zipfile]::ExtractToDirectory("C:\\Packages\\#{node['commvaultvmworld']['buildvagrant']['CS_folder']}\\#{node['commvaultvmworld']['buildvagrant']['CS']}", "C:\\Install")
		} else {
			Write-Host "download_package: Setup.exe already exists, assuming package already extracted"
		}
		EOH

		notifies :run, 'powershell_script[install_commserve]', :immediately
		notifies :run, 'powershell_script[cleanup]', :delayed
	end

	# We've made some assumptions as to how the zip file has been packaged up...
	powershell_script "install_commserve" do
		timeout 7200
		code <<-EOH
		$stream = [System.IO.StreamWriter] "install.log"
		$deploy = Start-Process C:\\Install\\DownloadPackageLocation_WinX64\\Setup.exe -ArgumentList '/silent /play "C:\\Install\\#{node['commvaultvmworld']['xml']['csinstall']}"' -verb RunAs -Wait

		$stream.WriteLine($deploy)
		$stream.close()
		EOH

		action :nothing
	end

elsif node.default['commvaultvmworld']['buildmethod'] == "local_path_extracted"
	powershell_script "download_package" do
		# While we're not downloading anything, we can at least check if the package exists and clear any blockers
		timeout 7200
		code <<-EOH

		Write-Host "download_package: Building with method #{node['commvaultvmworld']['buildmethod']}"

		if(![System.IO.File]::Exists("#{node['commvaultvmworld']['buildlocal']['path']}\\#{node['commvaultvmworld']['buildlocal']['CS_folder']}\\DownloadPackageLocation_WinX64\\Setup.exe")) {
			Write-Host "download_package: Something wrong with package path - please manually check"
		}

		# Get-ChildItem -Path "#{node['commvaultvmworld']['buildlocal']['path']}\\#{node['commvaultvmworld']['buildlocal']['CS_folder']}\\DownloadPackageLocation_WinX64" -Recurse | Unblock-File
		EOH

		notifies :run, 'powershell_script[install_commserve]', :immediately
		notifies :run, 'powershell_script[cleanup]', :delayed		
	end

	powershell_script "install_commserve" do
		cwd Chef::Config[:file_cache_path]
		timeout 7200
		code <<-EOH
		$env:SEE_MASK_NOZONECHECKS = 1
		$stream = [System.IO.StreamWriter] "install.log"
		$deploy = Start-Process "#{node['commvaultvmworld']['buildlocal']['path']}\\#{node['commvaultvmworld']['buildlocal']['CS_folder']}\\DownloadPackageLocation_WinX64\\Setup.exe" -ArgumentList '/silent /play C:\\Install\\#{node['commvaultvmworld']['xml']['csinstall']}' -verb RunAs -Wait

		$stream.WriteLine($deploy)
		$stream.close()
		Remove-Item env:\\SEE_MASK_NOZONECHECKS
		EOH

		action :nothing
	end
end

powershell_script "cleanup" do
	code <<-EOH
	Remove-Item -Recurse -Force C:\\Install
	EOH
	
	only_if { ::File.exists?("C:\\Install") }
	action :nothing
end