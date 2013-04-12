root  = File.expand_path(File.dirname(__FILE__))

ENV["CHEF_GLOBAL"] = ENV["CHEF_GLOBAL"] || File.join(root, "solo.json")
ENV["CHEF_LOCAL"]  = ENV["CHEF_LOCAL"]  || File.join(root, "solo.local.json")

def rmerge(hash, other_hash)
  r = {}
  hash.merge(other_hash) do |key, oldval, newval|
    r[key] = oldval.class == hash.class ? rmerge(oldval, newval) : newval
  end
end

def proxy_set(chef)
  if ENV["HTTP_PROXY"]
    chef.add_recipe 'proxy'
    chef.json = rmerge(chef.json || {}, {
      :proxy => {
        :http_proxy => ENV['HTTP_PROXY'],
        :https_proxy => ENV['HTTPS_PROXY'],
        :no_proxy => "mymachine.me," + (ENV['NO_PROXY'] || '')
      }
    })
  end
end

def json_load(chef)
  chef.json = chef.json || {}
  files = [ENV["CHEF_GLOBAL"], ENV["CHEF_LOCAL"]]
  files.each do |file_json|
    if File.exists?(file_json)
      chef.json = rmerge(chef.json, JSON.parse(File.open(file_json, &:read)))
    end
  end
  
  (chef.json.delete("reject_run") || []).each do |recipe|
    chef.json["run_list"].delete(recipe)
  end
end