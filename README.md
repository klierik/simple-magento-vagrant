# What is that? #
Simple-Magento-Vagrant -- ultra light Vagrant development environment for running Magento CMS, based on Ubuntu Precise 64.  
I create this repo for my self as easyest way install Magento and share with you.

After installation you will get clean Magento 1.8.1.0 with sample data 1.6.1.0.  
You can re-configure for personal use in you development. See __[How to use and/or customize](https://github.com/klierik/simple-magento-vagrant/blob/master/README.md#how-to-use-andor-customize)__ section for more information.

# What do i have? #
+ Ubuntu 12.04 + Apache2 + Php5 + MySQL 5.5.x
+ Magento 1.8.1.0 with sample data 1.6.1.0
+ [Adminer 3.7.1](http://www.adminer.org/)(formerly phpMinAdmin)

__Folders structure:__
```
.
..
magento-project-folder    - my project folder
vagrant                   - vagrant folder
```

## Requirements: ##
+ [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
+ [Vagrant](http://www.vagrantup.com/downloads.html)
+ [Vagrant Host Manager](https://github.com/smdahlen/vagrant-hostmanager)

## Default configuration ##

__File system:__
```
nfs: true
mount_options: ["nolock", "async"]
bsd__nfs_options: ["alldirs","async","nolock"]
config.nfs.map_uid = 0
config.nfs.map_gid = 0
```

__VirtualBox settings:__

Memory by default: `vb.customize ["modifyvm", :id, "--memory", "512"]`  
Network host-guest configuration: `config.vm.network :forwarded_port, guest: 80, host: 8999`

## Magento info and options ##
Magento version include: __1.8.1.0__  
Magento sample data include: __1.6.1.0__

DB name: __magentodb__  
DB user name: __magentouser__  
DB user password: __password__  

## Web server configuration ##

Server name: __simple-magento-vagrant.dev__

## How to use and/or customize. ##
It will be work out of box but you can edit configuration if you need.

__Change domain name__

1. Open Vagrantfile and use find/replace tool to change  
`"simple-magento-vagrant"` ==> `"my-personal-magento-site-name"` or what you need

2. Open bootstrap.sh and use find/replace tool to change  
`"simple-magento-vagrant"` ==> `"my-personal-magento-site-name"` or what you need

__Change network private ip__

Open Vagrant file and find `node.vm.network :private_network, ip: '192.168.68.69'` ==> change ip

__Change forwarded port__

Open Vagrantvile and find `config.vm.network :forwarded_port, guest: 80, host: 8999` ==> change host port

__Change Synced folder__

I prefere use different folders for vagrant and project. For example:

```
.
..
magento-project-folder    - my project folder
vagrant                   - vagrant folder
```
That\`s why i sync my folders in this way `config.vm.synced_folder "../magento-project-folder/", "/vagrant/httpdocs"`.  
Change `../magento-project-folder/` path to folder with your project (it\` can be relative or absolute url).

__Run Vagrant__

Run `$ vagrant up` in your vagrant options.

__PS: via installation you can be asked for password__

Now open http://simple-magento-vagrant.dev/ in your browser and install magento.

Tested on Mac Os X 10.9
