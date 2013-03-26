git "#{node['openruko']['home']}/gitmouth" do
  user node['user']
  group node['group']
  repository node['openruko']['repositories']['gitmouth']
  action :checkout
  revision node["versions"]["gitmouth"]
end

bash "setup-gitmouth" do
  user node['user']
  group node['group']
  cwd   "#{node['openruko']['home']}/gitmouth"
  environment Hash['HOME' => node['home']]

  code <<-EOF
  set -e
  if [ ! -f ./bin/activate ]; then
	make init
  fi
  EOF
end

bash "setup-gitmouth-certs" do
  user node['user']
  group node['group']
  cwd   "#{node['openruko']['home']}/gitmouth"

  code <<-EOF
  rm -fr certs
  expect <<- EOH\nspawn make certs \nexpect "*passphrase*"\nsend -- "\r"\nexpect "*passphrase*"\nsend -- "\r"\ninteract\nEOH
  EOF
end

template "/etc/init/openruko-gitmouth.conf" do
  source "upstart-openruko-gitmouth.conf.erb"
  owner "root"
  group "root"
  mode 0644
end
