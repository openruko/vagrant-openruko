git "#{node['openruko']['home']}/client" do
  user node['user']
  group node['group']
  repository node['openruko']['repositories']['client']
  action :checkout
  revision node["versions"]["client"]
end

template "#{node['home']}/.ssh/config" do
  source "ssh-config.erb"
  owner "root"
  group "root"
  mode 0644
end
