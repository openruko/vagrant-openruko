package "curl"
package "wget"
package "socat"
package "postgresql-server-dev-9.1"
package "postgresql-contrib-9.1"
package "uuid-dev"
package "python"
package "python-dev"
package "python-virtualenv"
package "lxc"

directory "/home/vagrant/openruko" do
  owner "vagrant"
  group "vagrant"
  mode 0700
end

include_recipe "openruko::gitmouth"
include_recipe "openruko::apiserver"
include_recipe "openruko::dynohost"
include_recipe "openruko::logplex"
include_recipe "openruko::rukorun"
include_recipe "openruko::codonhooks"
include_recipe "openruko::client"