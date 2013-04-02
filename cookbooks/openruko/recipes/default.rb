include_recipe "apt"
include_recipe "build-essential"
include_recipe "git"
include_recipe "nodejs::install_from_package"

package "libssl0.9.8"
package "uuid-dev"
package "curl"
package "wget"
package "ruby1.9.1"


bash "setup-local-domains" do
  user  "root"
  code <<-EOF
  echo "#{node['openruko']['apiserver_ip']} #{node['openruko']['apiserver_host']}" >> /etc/hosts
  echo "#{node['openruko']['apiserver_ip']} openruko.#{node['openruko']['apiserver_host']} # fakes3 host" >> /etc/hosts
  EOF

  not_if "grep '#{node['openruko']['apiserver_host']}' /etc/hosts"
end

bash "setup-apiserver" do
  code <<-EOF
  sudo su - -c "echo \\"rukosan ALL=(ALL) NOPASSWD: ALL\\" >> /etc/sudoers"
  EOF
end

group node['group'] do
end

user node['user'] do
  gid node['group']
  home "/home/" + node['user']
  supports :manage_home => true
  shell "/bin/bash"
  comment "Rukosan"
end

directory node['openruko']['home'] do
  owner node['user']
  group node['group']
  mode 0755
end

directory "/var/log/openruko" do
  owner node['user']
  group node['group']
  mode 0755
end
