git "#{node['openruko']['home']}/integration-tests" do
  user node['user']
  group node['group']
  repository node['openruko']['repositories']['integration-tests']
  action :checkout
  revision node["versions"]["integration-tests"]
end
