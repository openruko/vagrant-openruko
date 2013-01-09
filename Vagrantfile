# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant::Config.run do |config|
  config.vm.box = "precise64"
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"

#  For i686 prefer a 32bit VM
#  config.vm.box = "openruko32"
#  config.vm.box_url = "http://files.vagrantup.com/precise32.box"

  # Leave this as a separate part, it allows chef
  # to reload its env on the next part
  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = 'cookbooks'

    chef.add_recipe 'proxy'
    chef.json = {
      :proxy => {
        :http_proxy => ENV['HTTP_PROXY'],
        :https_proxy => ENV['HTTPS_PROXY'],
        :no_proxy => "mymachine.me," + (ENV['NO_PROXY'] || '')
      }
    }
  end

  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = 'cookbooks'

    chef.add_recipe 'apt'
    chef.add_recipe 'build-essential'
    chef.add_recipe 'openssl'
    chef.add_recipe 'postgresql::client'
    chef.add_recipe 'postgresql::server'
    chef.add_recipe 'git'
    chef.add_recipe 'nvm'
    chef.add_recipe 'fakes3'

    chef.json = {
      :postgresql => {
        :version  => "9.1",
        :listen_addresses => "*",
        :hba => [
          { :method => "trust", :address => "0.0.0.0/0" },
          { :method => "trust", :address => "::1/0" },
        ],
        :password => {
          :postgres => "password"
        }
      }
    }
  end

  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = 'cookbooks'

    chef.add_recipe 'openruko'
    chef.add_recipe 'heroku-toolbelt'
    chef.json = {
      :apiserver_key => "ec1a8eb9-18a6-42c2-81ec-c0f0f615280c",
      :s3 => {
        :s3_key => ENV['S3_KEY'] || '123',
        :s3_secret => ENV['S3_SECRET'] || '123',
        :s3_bucket => ENV['S3_BUCKET'] || 'openruko',
    		:s3_hostname => 'mymachine.me',
    		:s3_port => 4567
      }
    }
  end
end
