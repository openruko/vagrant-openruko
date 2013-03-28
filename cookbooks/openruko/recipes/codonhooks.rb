git "#{node['openruko']['home']}/codonhooks" do
  user node['user']
  group node['group']
  repository node['openruko']['repositories']['codonhooks']
  action :checkout
  revision node["versions"]["codonhooks"]
end
