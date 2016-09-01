#
# You'll want vagrant plugins vagrant-hosts and vagrant-multi-putty (if on Windows) for this
#

Vagrant.configure("2") do |config|

    # Load common functions
    functions = File.expand_path('../functions.rb', __FILE__)
    load functions

    # Check if running on windows & vagrant-multi-putty is present
    if OS.windows?
        if Vagrant.has_plugin?("vagrant-multi-putty")
            config.putty.modal = true
            config.putty.after_modal do
                require 'win32/activate'
                Win32::Activate.active
            end
        end
    end
  
    # CommServe definition, based on 2012 R2 w/Chef
    config.vm.define :commserve do |commserve|
        commserve.vm.hostname = "vmw-v11-cs"
        commserve.vm.box = "eltuko/win2012r2-chef-pester"

        # Increase vRAM from 512MB to 1GB
        # Increase vCPU from 2 to 4
        commserve.vm.provider "virtualbox" do |vb|
            vb.cpus = 4
            vb.memory = 6144
            vb.gui = false
            vb.customize ['modifyvm', :id, '--clipboard', 'bidirectional']
        end

        commserve.vm.synced_folder SharedFolder.path, "/packages"

        # I wish there was a gateway: option
        commserve.vm.network "private_network", ip: "172.16.0.2"
        commserve.vm.network "forwarded_port", host: 9999, guest: 3389
        commserve.vm.communicator = "winrm"
        commserve.vm.provision "shell", inline: 'cmd.exe /c \'winrm s winrm/config/Service @{MaxConcurrentOperationsPerUser="1500"}\''
        commserve.vm.provision "shell", inline: 'cmd.exe /c \'netsh interface ipv4 set route 0.0.0.0/32 "Ethernet 2" 172.16.0.1\''
        # ^^^ without this, IP addr fails validation and we end up with auto-generated IP address

        commserve.vm.provision :hosts do |provisioner|
            provisioner.autoconfigure = true
            provisioner.sync_hosts = true
            provisioner.add_localhost_hostnames = false
            provisioner.exports = {
                'commserve' => [
                    ['172.16.0.2', ['@vagrant_hostnames']]
                ]
            }
            provisioner.imports = ['frel', 'production', 'test']
        end

        commserve.vm.provision "chef_solo" do |chef|
            chef.cookbooks_path="./cookbooks"
            chef.add_recipe "commvaultvmworld::default"
            chef.add_recipe "commvaultvmworld::commserve"
            chef.add_recipe "commvaultvmworld::commserveconfig"
        end

        # todo: vm.post_up_message for instructions
    end


    # config.vm.define :frel do |frel|
    #     frel.vm.hostname = "frel"
    #     frel.vm.box = "boxesio/trusty64-chef"

    #     frel.vm.network "private_network", ip: "172.16.0.3"
    #     frel.vm.provider "virtualbox" do |vb|
    #         vb.gui = false
    #     end

    #     frel.vm.synced_folder SharedFolder.path, "/packages"

    #     frel.vm.provision :hosts do |provisioner|
    #         provisioner.autoconfigure = true
    #         provisioner.sync_hosts = true
    #         provisioner.add_localhost_hostnames = false
    #         provisioner.exports = {
    #             'frel' => [
    #                 ['172.16.0.3', ['@vagrant_hostnames']]
    #             ]
    #         }
    #         provisioner.imports = ['commserve', 'production', 'test']
    #     end

    #     frel.vm.provision "chef_solo" do |chef|
    #         chef.cookbooks_path="./cookbooks"
    #         chef.add_recipe "commvaultvmworld::default"
    #         chef.add_recipe "commvaultvmworld::agents_fs_ma_vsa"
    #         chef.add_recipe "commvaultvmworld::convert_to_frel"
    #         chef.add_recipe "commvaultvmworld::enable_3dfs"
    #     end
    # end


    # Host used for second example, 14.04 LTS w/Chef
    config.vm.define :example1 do |helloworld|
        helloworld.vm.hostname = "helloworld"
        helloworld.vm.box = "boxesio/trusty64-chef"

        helloworld.vm.network "private_network", ip: "172.16.0.9"
        helloworld.vm.provider "virtualbox" do |vb|
            vb.gui = false
        end

        helloworld.vm.synced_folder SharedFolder.path, "/packages"

        helloworld.vm.provision :hosts do |provisioner|
            provisioner.autoconfigure = true
            provisioner.sync_hosts = true
            provisioner.add_localhost_hostnames = false
            provisioner.exports = {
                'helloworld' => [
                    ['172.16.0.9', ['@vagrant_hostnames']]
                ]
            }
            provisioner.imports = ['commserve', 'frel', 'production', 'test']
        end

        helloworld.vm.provision "chef_solo" do |chef|
            chef.cookbooks_path="./cookbooks"
            chef.add_recipe "commvaultvmworld::default"
            chef.add_recipe "commvaultvmworld::agents_filesystem"
        end
    end


    # Host used for second example, 14.04 LTS w/Chef
    config.vm.define :production do |production|
        production.vm.hostname = "production"
        production.vm.box = "boxesio/trusty64-chef"

        production.vm.network "private_network", ip: "172.16.0.10"
        production.vm.network "forwarded_port", guest: 80, host:8080
        production.vm.provider "virtualbox" do |vb|
            vb.gui = false
        end

        production.vm.synced_folder SharedFolder.path, "/packages"

        production.vm.provision :hosts do |provisioner|
            provisioner.autoconfigure = true
            provisioner.sync_hosts = true
            provisioner.add_localhost_hostnames = false
            provisioner.exports = {
                'production' => [
                    ['172.16.0.10', ['@vagrant_hostnames']]
                ]
            }
            provisioner.imports = ['commserve', 'frel', 'example', 'test']
        end

        production.vm.provision "chef_solo" do |chef|
            chef.cookbooks_path="./cookbooks"
            chef.add_recipe "nginx"
            chef.add_recipe "commvaultvmworld::default"
            chef.add_recipe "commvaultvmworld::agents_filesystem"
            chef.add_recipe "commvaultvmworld::configure_filesystem_baseline"
            chef.json = {
                "nginx" => {
                    "deploy_html" => "1"
                },
                "commvaultvmworld" => {
                    "fsconfig" => {
                        "content" => "/usr/share/nginx/html"
                    }
                }
            }
        end
    end

    # Host used for third example, also 14.04 LTS w/Chef
    config.vm.define :test do |test|
        test.vm.hostname = "test"
        test.vm.box = "boxesio/trusty64-chef"

        test.vm.network "private_network", ip: "172.16.0.11"
        test.vm.network "forwarded_port", guest: 80, host:8081
        test.vm.provider "virtualbox" do |vb|
            vb.gui = false
        end

        test.vm.synced_folder SharedFolder.path, "/packages"

        test.vm.provision :hosts do |provisioner|
            provisioner.autoconfigure = true
            provisioner.sync_hosts = true
            provisioner.add_localhost_hostnames = false
            provisioner.exports = {
                'production' => [
                    ['172.16.0.11', ['@vagrant_hostnames']]
                ]
            }
            provisioner.imports = ['commserve', 'frel', 'production', 'example']
        end

        test.vm.provision "chef_solo" do |chef|
            chef.cookbooks_path="./cookbooks"
            chef.add_recipe "nginx"
            chef.add_recipe "commvaultvmworld::default"
            chef.add_recipe "commvaultvmworld::agents_filesystem"
            chef.add_recipe "commvaultvmworld::restore_filesystem"
            #chef.add_recipe "test, test and test again"
            #chef.add_recipe "more testing"
            #chef.add_recipe "just a bit more testing for good measure"
            chef.json = {
                "nginx" => {
                    "deploy_html" => "0"
                },
                "commvaultvmworld" => {
                    "restore" => {
                        "original_client" => "production",
                        "original_path" => "/usr/share/nginx/html",
                        "inPlace" => "true"
                    }
                }
            }
        end
    end
end