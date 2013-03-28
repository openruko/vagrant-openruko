git "#{node['openruko']['home']}/httprouting" do
  user node['user']
  group node['group']
  repository node['openruko']['repositories']['httprouting']
  action :checkout
  revision node["versions"]["httprouting"]
end

bash "setup-httprouting" do
  user node['user']
  group node['group']
  cwd   "#{node['openruko']['home']}/httprouting"
  environment Hash['HOME' => node['home']]

  code <<-EOF
  set -e
  make init
  echo -e '\n\n\n\n\n\n\n\n' | make certs
  EOF
end

template "/etc/init/openruko-httprouting.conf" do
  source "upstart-openruko-httprouting.conf.erb"
  owner "root"
  group "root"
  mode 0644
end
