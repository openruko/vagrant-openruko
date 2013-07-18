# Various repos are combined here so that we can define a Dynohost as a separate server
package "lxc"

# Packages to run php projects
package "libpq5"
package "libltdl7"
package "libjpeg62"

# Mysql packages
package "libmysqlclient-dev"

#############
# Codonhooks
#############
git "#{node['openruko']['home']}/codonhooks" do
  user node['user']
  group node['group']
  repository node['openruko']['repositories']['codonhooks']
  action :checkout
  revision node["versions"]["codonhooks"]
end


##########
# Rukorun
##########
git "#{node['openruko']['home']}/rukorun" do
  user node['user']
  group node['group']
  repository node['openruko']['repositories']['rukorun']
  action :checkout
  revision node["versions"]["rukorun"]
end

bash "setup-rukorun" do
  user node['user']
  group node['group']
  cwd   "#{node['openruko']['home']}/rukorun"
  environment Hash['HOME' => node['home']]

  code <<-EOF
  make init
  EOF
end


###########
# Dynohost
###########
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

template "/etc/profile.d/openruko-dynohost.sh" do
  source "profile-openruko-dynohost.erb"
  owner "root"
  group "root"
  mode 0755
end

service "openruko-dynohost" do
  provider Chef::Provider::Service::Upstart
  supports :restart => true, :start => true, :stop => true
  action [:enable, :start]
end
