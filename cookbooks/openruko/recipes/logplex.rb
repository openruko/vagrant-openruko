git "#{node['openruko']['home']}/logplex" do
  user node['user']
  group node['group']
  repository node['openruko']['repositories']['logplex']
  action :checkout
  revision node["versions"]["logplex"]
end

bash "setup-logplex" do
  user node['user']
  group node['group']
  cwd   "#{node['openruko']['home']}/logplex"
  environment Hash['HOME' => node['home']]

  code <<-EOF
  make init
  EOF
end

template "/etc/init/openruko-logplex.conf" do
  source "upstart-openruko-logplex.conf.erb"
  owner "root"
  group "root"
  mode 0644
end
