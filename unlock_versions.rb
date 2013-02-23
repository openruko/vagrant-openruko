# This script unlocks all the openruko dependencies in solo.json from their tagged versions.
# This allows us to manually trigger Travis builds to test the bleeding edge versions of the dependencies.

require 'json'

file = File.dirname(__FILE__) + '/solo.json'

data = JSON.parse(IO.read(file))

data['versions'].each do |repo, version|
  data['versions'][repo] = 'master'
end

File.open(file,"w") do |f|
  f.write(data.to_json)
end
