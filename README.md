# Bootstrapping OpenRuko
[![Build Status](https://travis-ci.org/openruko/vagrant-openruko.png)](https://travis-ci.org/openruko/vagrant-openruko)

Chef recipes for bootstrapping [OpenRuko](https://github.com/openruko).

Both a Vagrantfile for running local development environments and, using Vagrant 1.1, for deploying to VPSs.

## Standalone Install

Useful for local dev environments or just single-server setups.

To generate a new VirtualBox VM with OpenRuko and all its dependencies already installed.

```
$ sudo apt-get install vagrant
$ git clone https://github.com/openruko/vagrant-openruko.git
$ cd vagrant-openruko/standalone
$ vagrant up
# wait ...
```

## Cluster Install

Openruko is designed to be scalable, so that you can have a central API server with mulitple dyno servers.

To generate a new VirtualBox VM with OpenRuko and all its dependencies already installed.

```
$ cd vagrant-openruko/cluster
$ vagrant up
# wait for both VMs to boot

```

You can ssh into each individual VM with `vagrant ssh api` and `vagrant ssh dynohost`

## Launch tests

Login to the server `vagrant ssh`, or `vagrant ssh api` if you're bootstrapping a cluster and run

```
$ cd ~/openruko/integration-tests
$ ./run.sh
```

See also [integration-tests](https://github.com/openruko/integration-tests)

## If you're behind a proxy

Export the following environment variable in the host machine:

```
export HTTP_PROXY=http://proxy.xxx:3128
export HTTPS_PROXY=http://proxy.xxx:3128
export NO_PROXY=localhost
```

Connect to the server with SSH, and create a new openruko user

```
$ ~/openruko/apiserver/bin/adduser
# email: openruko@openruko.com
# Password: rukosan
$ exit
```

Connect to the server with SSH, and create a new project (we will use node.js)

```
$ mkdir myapp
$ cd myapp
$ git init
$ npm init
$ cat > index.js << EOF
var http = require('http');
http.createServer(function (req, res) {
  res.writeHead(200, {'Content-Type': 'text/plain'});
  res.end('Hello World\n');
}).listen(process.env.PORT);
console.log('Server running');
EOF

$ cat > Procfile << EOF
web: node index.js
EOF

$ git add -A
$ git commit -m 'fisrt commit'

$ ~/openruko/client/openruko keys:add
# email: openruko@openruko.com
# Password: rukosan

$ ~/openruko/client/openruko create myapp

$ git push heroku master
$ curl http://myapp.mymachine.me:8080/
```

