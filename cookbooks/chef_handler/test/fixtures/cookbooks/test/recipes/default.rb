include_recipe 'chef_handler::default'

cookbook_file "#{node['chef_handler']['handler_path']}/my_handler.rb" do
  source 'my_handler.rb'
end

chef_handler 'MyCorp::MyHandler' do
  source "#{node['chef_handler']['handler_path']}/my_handler.rb"
  action [:enable, :disable]
end

chef_handler 'MyCorp::MyLibraryHandler' do
  action :enable
end
