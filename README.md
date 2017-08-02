# nanitor_agent

#### Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with nanitor_agent](#setup)
    * [Setup requirements](#setup-requirements)
    * [Beginning with nanitor_agent](#beginning-with-nanitor_agent)

## Description

This module installs the Nanitor Agent to devices.
This module is tested against CentOS and Ubuntu.

## Setup

### Setup Requirements
This module depends on the APT puppet module.

```
puppet module install puppetlabs-stdlib
puppet module install puppetlabs-apt
```

The signup process requires that the devices trust the certificate of the Nanitor server.
The signup process will fail if it doesn't. Make sure the root certificate of the signing CA
is trusted on the devices.

### Beginning with nanitor_agent
This is how to install the plugin onto the puppet master

```
yum -y install git
cd /etc/puppetlabs/code/environments/production/modules
git clone https://github.com/Nanitor/nanitor-agent-puppet.git nanitor_agent
```

Now we need to edit ```nanitor_agent/files/nanitor-agent-signup-key.txt``` to put in your Nanitor organization signup key.

Final step is to activate the plugin by adding ```class { 'nanitor_agent': }``` to ```/etc/puppetlabs/code/environments/production/manifests/site.pp```

Then run ```puppet agent -t```
