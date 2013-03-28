#!/bin/bash

# This is used by non-vagrant environments.

PATH=$PATH:/var/lib/gems/1.9.1/bin

chef_version="10.20"

function add_rukosan_user {
	sudo useradd -d /home/rukosan -m rukosan -s /bin/bash -c Rukosan &&
	sudo su - -c "echo \"rukosan ALL=(ALL) NOPASSWD: ALL\" >> /etc/sudoers"
}

if [ "$TRAVIS" != "true" ]; then

	# Are we on a vanilla system?
	if (! command -v chef-solo >/dev/null 2>&1) || (! chef-solo --version | grep $chef_version); then

		# After an apt-get update the kernel and Vbox modules can get out of sync, so use apt pinning to
		# prevent updates to the kernel.
		if [[ "$(whoami)" = "vagrant" ]]; then

			sudo cat > /etc/apt/preferences <<-EOF
			Package: linux-generic linux-headers-generic linux-image-generic linux-restricted-modules-generic
			Pin: version 3.2.0-23
			Pin-Priority: 1001
			EOF

		fi

		export DEBIAN_FRONTEND=noninteractive
		# Upgrade headlessly (this is only safe-ish on vanilla systems)
		sudo aptitude update &&
		sudo apt-cache policy &&

		# Everything works fine without upgrading. Besides it upgrades the kernel, which means that
		# the existing Vbox modules get out of sync. Not to mention that updating everytime introduces
		# time-dependent variables that don't make this box future-proof and idempotent.
		#sudo apt-get -o Dpkg::Options::="--force-confnew" \
		#  --force-yes -fuy dist-upgrade &&

		# Install Ruby and Chef
		sudo aptitude install -y ruby1.9.1 ruby1.9.1-dev make &&
		sudo gem1.9.1 install --no-rdoc --no-ri chef --version $chef_version &&
		add_rukosan_user
		export GEM_HOME=/home/rukosan/.gem/ruby/1.9.1
		export PATH=$PATH:~/.gem/ruby/1.9.1/bin/

		# If the Vagrant shared folder mounts create /home/rukosan before the user has been created
		# then root will own /home/rukosan and chef will complain about permission issues.
		sudo chown rukosan:rukosan /home/rukosan

	fi &&

	sudo_command=sudo

else

	echo "Travis CI environment detected."
  sudo apt-get update

	# Remove exsiting Postgres installation
	sudo /etc/init.d/postgresql stop
	sudo apt-get --force-yes -fuy remove --purge postgresql postgresql-9.1 postgresql-client lxc

	sudo mkdir -p /var/log/postgresql

	gem install --no-rdoc --no-ri chef --version $chef_version
	add_rukosan_user

	# rvmsudo is the only way to give chef the needed permissions
	sudo_command=rvmsudo
fi

$sudo_command chef-solo -c solo.rb -j solo.json
