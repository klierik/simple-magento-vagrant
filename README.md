This is ultra light Vagrant box for running Magento CMS from box.

Based on Ubuntu precise 64.

Requirements:
+ Vagrant Host Manager (https://github.com/smdahlen/vagrant-hostmanager)

Default configuration.

File system:
nfs: true
mount_options: ["nolock", "async"]
bsd__nfs_options: ["alldirs","async","nolock"]
config.nfs.map_uid = 0
config.nfs.map_gid = 0

VirtualBox settings:
Memory by defauylt: vb.customize ["modifyvm", :id, "--memory", "512"]
Network host-guest configuration: config.vm.network :forwarded_port, guest: 80, host: 8999

Magento configuration.

Magento version include: 1.8.1.0
DataBase name: magentodb
DataBase user name: magentouser
DataBase user password: password

Magento sample data inckude: 1.6.1.0

Web server configuration.

Server name: simple-magento-vagrant.dev

How to use and/or customize.
# Change domain name
1. Open Vagrantfile and use find/replace tool to change "simple-magento-vagrant" ==> "my-personal-magento-site-name" or something like that
2. Open bootstrap.sh and use find/replace tool to change "simple-magento-vagrant" ==> "my-personal-magento-site-name" or something like that

# Change network private ip
Open Vagrant file and find `node.vm.network :private_network, ip: '192.168.68.69'` ==> change ip

# Change forwarded port
Opan Vagrantvile and find `config.vm.network :forwarded_port, guest: 80, host: 8999` ==> change host port
