package 'nginx' do
	action :install
end

service 'nginx' do
	action [ :enable, :start ]
end

if node['nginx']['deploy_html'] == "1"
	remote_directory '/usr/share/nginx/html' do
		source 'html'
		owner 'root'
		group 'root'
		mode '0755'
		action :create
	end
end

service 'nginx' do
	action [ :restart ]
end