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
