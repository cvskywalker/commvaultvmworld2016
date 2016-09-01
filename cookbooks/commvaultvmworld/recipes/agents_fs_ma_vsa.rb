if platform?("windows")
	template "C:\\#{node['commvaultvmworld']['xml']['win_fsmavsa_install']}" do
		source "#{node['commvaultvmworld']['xml']['win_fsmavsa_install']}.erb"
	end

	directory 'C:\\Install' do
		action :create
		notifies :run, 'powershell_script[download_package]', :immediately
	end

	if node.default['commvaultvmworld']['buildmethod'] == "s3"
		powershell_script "download_package" do
			code <<-EOH
			Import-Module AWSPowershell

			Write-Host "download_package: Building with method #{node['commvaultvmworld']['buildmethod']}"

			Copy-S3Object -BucketName #{node['commvaultvmworld']['buildbucket']['bucket']} -Key #{node['commvaultvmworld']['buildbucket']['FS_MA_VSA']} -LocalFile C:\\Install\\#{node['commvaultvmworld']['buildbucket']['FS_MA_VSA']}

			Add-Type -Assembly "System.IO.Compression.Filesystem"
			[io.compression.zipfile]::ExtractToDirectory("C:\\Install\\#{node['commvaultvmworld']['buildbucket']['FS_MA_VSA']}", "C:\\Install")

			Remove-Item C:\\Install\\#{node['commvaultvmworld']['buildbucket']['FS_MA_VSA']}
			EOH
			
			notifies :run, 'powershell_script[install_fs_ma_vsa]', :immediately
			notifies :run, 'powershell_script[cleanup]', :delayed
		end
	elsif node.default['commvaultvmworld']['buildmethod'] == "vagrantfolder"
		powershell_script "download_package" do
			code <<-EOH
			Write-Host "download_package: Building with method #{node['commvaultvmworld']['buildmethod']}"

			if (!(Test-Path "C:\\Install\\DownloadPackageLocation_WinX64\\Setup.exe")) {
				Add-Type -Assembly "System.IO.Compression.Filesystem"
				[io.compression.zipfile]::ExtractToDirectory("C:\\Packages\\#{node['commvaultvmworld']['buildvagrant']['FS_MA_VSA_folder']}\\#{node['commvaultvmworld']['buildvagrant']['FS_MA_VSA_folder']}", "C:\\Install")
			} else {
				Write-Host "download_package: Setup.exe already exists, assuming package already extracted"
			}
			EOH

			notifies :run, 'powershell_script[install_fs_ma_vsa]', :immediately
			notifies :run, 'powershell_script[cleanup]', :delayed
		end
	elsif node.default['commvaultvmworld']['buildmethod'] == "local_path_extracted"
		powershell_script "download_package" do
			code <<-EOH

			Write-Host "download_package: Building with method #{node['commvaultvmworld']['buildmethod']}"

			if(![System.IO.File]::Exists("#{node['commvaultvmworld']['buildlocal']['path']}\\#{node['commvaultvmworld']['buildlocal']['FS_MA_VSA_folder']}\\DownloadPackageLocation_WinX64\\Setup.exe")) {
				Write-Host "download_package: Something wrong with package path - please manually check"
			}

			# Get-ChildItem -Path "#{node['commvaultvmworld']['buildlocal']['path']}\\#{node['commvaultvmworld']['buildlocal']['FS_MA_VSA_folder']}\\DownloadPackageLocation_WinX64" -Recurse | Unblock-File
			EOH

			notifies :run, 'powershell_script[install_fs_ma_vsa]', :immediately
			notifies :run, 'powershell_script[cleanup]', :delayed
		end
	end

	powershell_script "install_fs_ma_vsa" do
		cwd Chef::Config[:file_cache_path]
		timeout 7200
		code <<-EOH
		$stream = [System.IO.StreamWriter] "install.log"
		$deploy = Start-Process C:\\Install\\DownloadPackageLocation2_WinX64\\Setup.exe -ArgumentList '/silent /play C:\\Install\\#{node['commvaultvmworld']['xml']['install']}' -verb RunAs -Wait

		$stream.WriteLine($deploy)
		$stream.close()
		EOH
		
		action :nothing
	end

	powershell_script "cleanup" do
		code <<-EOH
		Remove-Item -Recurse -Force C:\\Install
		EOH

		only_if { ::File.exists?("C:\\Install") }
		action :nothing
	end

# If I'm not windows, I must be non-windows
else
	template "/tmp/#{node['commvaultvmworld']['xml']['linux_fsmavsa_install']}" do
		source "#{node['commvaultvmworld']['xml']['linux_fsmavsa_install']}.erb"
	end

	if node.default['commvaultvmworld']['buildmethod'] == "s3"
		puts "panic: s3: I didn't code this yet"

	elsif node.default['commvaultvmworld']['buildmethod'] == "vagrantfolder"
		bash "extract_package" do
			user 'root'
			code <<-EOH
			mkdir -p /tmp/cv_install
			tar -xC /tmp/cv_install -f #{node['commvaultvmworld']['buildvagrant']['unixpath']}/#{node['commvaultvmworld']['buildvagrant']['Linux_x8664']}
			EOH

			notifies :run, 'bash[install_module]', :immediately
			notifies :run, 'bash[cleanup]', :delayed
		end

		bash "install_module" do
		    user 'root'
		    code <<-EOH
		    
		    /tmp/cv_install/#{node['commvaultvmworld']['buildvagrant']['Linux_x8664_folder']}/DownloadPackageLocation/silent_install --xmlfile /tmp/#{node['commvaultvmworld']['xml']['linux_fsmavsa_install']}

		    EOH

		    action :nothing
		end

		bash "cleanup" do
			user 'root'
			code <<-EOH
			# mmm...
			rm -rf /tmp/cv_install
			EOH
			action :nothing
		end

	elsif node.default['commvaultvmworld']['buildmethod'] == "local_path_extracted"
		bash "mount_share" do
		    user 'root'
		    code <<-EOH
		    mkdir -p /tmp/cv_install;
		    mountpoint /tmp/cv_install && umount /tmp/cv_install
		    mount -t cifs -opassword=null #{node['commvaultvmworld']['buildlocal']['unixpath']} /tmp/cv_install;
		    EOH

		    notifies :run, 'bash[install_module]', :immediately
		    notifies :run, 'bash[unmount_share]', :delayed
		end

		bash "install_module" do
		    user 'root'
		    code <<-EOH
		    /tmp/cv_install/#{node['commvaultvmworld']['buildlocal']['Linux_x8664_folder']}/DownloadPackageLocation/silent_install --xmlfile /tmp/#{node['commvaultvmworld']['xml']['linux_fsmavsa_install']}
		    EOH

		    action :nothing
		end

		bash "unmount_share" do
		    user 'root'
		    code <<-EOH
		    umount -f /tmp/cv_install
		    rmdir /tmp/cv_install
		    EOH

		    action :nothing
		end
	end
end