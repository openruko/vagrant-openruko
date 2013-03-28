package "expect"
package "socat"
package "postgresql-server-dev-9.1"
package "postgresql-contrib-9.1"

bash "setup-ruby" do
  code <<-EOF
  sudo update-alternatives --set ruby /usr/bin/ruby1.9.1
  sudo update-alternatives --set gem /usr/bin/gem1.9.1
  EOF
end

git "#{node['openruko']['home']}/apiserver" do
  user node['user']
  group node['group']
  repository node['openruko']['repositories']['apiserver']
  action :checkout
  revision node["versions"]["apiserver"]
end

bash "setup-apiserver" do
  user node['user']
  group node['group']
  cwd   "#{node['openruko']['home']}/apiserver"
  environment Hash['HOME' => node['home']]

  code <<-EOF
  set -e
  make init
  echo -e '\n\n\n\n\n\n\n\n' | make certs
  echo -e '\ny' | ssh-keygen -t rsa -N ''
  EOF
end

bash "setup-postgres-user" do
  user  "postgres"
  code <<-EOF
  psql <<< "CREATE ROLE #{node['user']} ENCRYPTED PASSWORD '#{node['postgresql']['password'][node['user']]}' SUPERUSER CREATEDB CREATEROLE INHERIT LOGIN;"
  EOF
end

bash "setup-postgres-database" do
  user  node['user']
  group  node['group']
  code <<-EOF
  psql postgres <<< "CREATE DATABASE openruko;"
  EOF
end

template "/etc/init/openruko-apiserver.conf" do
  source "upstart-openruko-apiserver.conf.erb"
  owner "root"
  group "root"
  mode 0644
end

template "/etc/profile.d/openruko-apiserver.sh" do
  source "profile-openruko-apiserver.erb"
  owner "root"
  group "root"
  mode 0755
end

service "openruko-apiserver" do
  provider Chef::Provider::Service::Upstart
  supports :restart => true, :start => true, :stop => true
  action [:enable, :start]
end
