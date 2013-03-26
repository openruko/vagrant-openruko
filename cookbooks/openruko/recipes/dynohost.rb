git "#{node['openruko']['home']}/dynohost" do
  user node['user']
  group node['group']
  repository node['openruko']['repositories']['dynohost']
  action :checkout
  revision node["versions"]["dynohost"]
end

bash "setup-dynohost" do
  user node['user']
  group node['group']
  cwd   "#{node['openruko']['home']}/dynohost"
  environment Hash['HOME' => node['home']]

  code <<-EOF
  set -e
  make init
  echo -e '\n\n\n\n\n\n' | make certs
  EOF
end

template "/etc/init/openruko-dynohost.conf" do
  source "upstart-openruko-dynohost.conf.erb"
  owner "root"
  group "root"
  mode 0644
end
