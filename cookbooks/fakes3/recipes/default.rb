package "rubygems"

script "install-fakes3" do
  interpreter "bash"

  code <<-EOF
    sudo su - #{node['fakes3']['user']} -c 'gem install fakes3 --no-rdoc --no-ri'
  EOF

  not_if "sudo su - #{node['fakes3']['user']} -c 'gem which fakes3'"
end

template "/etc/init/fakes3.conf" do
  source "upstart-fakes3.conf.erb"
  owner "root"
  group "root"
  mode 0644
end

service "fakes3" do
  provider Chef::Provider::Service::Upstart
  supports :restart => true, :start => true, :stop => true
  action [:enable, :start]
end
