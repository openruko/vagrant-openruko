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
