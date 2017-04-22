#!/bin/bash

echo ">>>Shadowsocks install start"
echo "installing setuptools..."
yum install python-setuptools && easy_install pip

if [ $? -eq 0 ]; then
	#shadowsocks
	echo "installing shadowsocks..."
	pip install shadowsocks
	if [ $? -eq 0 ]; then
		#config.json
		echo "setting config file..."
		
		if [ ! -d /etc/shadowsocks ];then
			mkdir -p /etc/shadowsocks
		fi
		
		if [ ! -e /etc/shadowsocks/config.json ];then
			cat > /etc/shadowsocks/config.json << EOF
{
    "server":"0.0.0.0",
    "local_address":"127.0.0.1",
    "local_port":1080,
    "port_password":{
         "8080":"ss11501",
         "8081":"ss11501",
         "8082":"ss11501",
         "8083":"ss11501"
    },
    "timeout":300,
    "method":"rc4-md5",
    "fast_open":false
}
EOF
		fi
		
		#shadowsocks.service
		echo "make service file..."
		if [ ! -e /etc/systemd/system/shadowsocks.service ];then
			cat > /etc/systemd/system/shadowsocks.service << EOF
[Unit]
Description=Shadowsocks server
After=network.target
Wants=network.target

[Service]
Type=forking
PIDFile=/var/run/shadowsocks.pid
ExecStart=/usr/bin/ssserver --pid-file /var/run/shadowsocks.pid -c /etc/shadowsocks/config.json -d start
ExecStop=/usr/bin/ssserver --pid-file /var/run/shadowsocks.pid -c /etc/shadowsocks/config.json -d stop
ExecReload=/bin/kill -HUP $MAINPID
KillMode=process
Restart=always

[Install]
WantedBy=multi-user.target
EOF
		fi
		
		#add port
		echo "adding port..."
		firewall-cmd --permanent --add-port=8080-8083/tcp
		firewall-cmd --reload
		
		#start && start on boot
		echo "Shadowsocks starting..."
		systemctl enable shadowsocks.service && systemctl start shadowsocks.service
		if [ $? -eq 0 ]; then
			echo "successed! shadowsocks is running!"
		fi
	else
		exit 1
	fi
else
	exit 1
fi