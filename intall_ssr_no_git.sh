#!/bin/bash

echo ">>>ShadowsocksR install start"
cd /
if [ $? -eq 0 ]; then
	#shadowsocks.json
	echo "setting config file..."
	if [ ! -e /etc/shadowsocks.json ];then
		cat > /etc/shadowsocks.json << EOF
{
    "server":"0.0.0.0",
    "server_ipv6": "[::]",
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
    "protocol": "auth_sha1_v4_compatible",
    "protocol_param": "4",
    "obfs": "http_simple_compatible",
    "obfs_param": "",
    "redirect": "",
    "dns_ipv6": false,
    "fast_open": false,
    "workers": 1
}
EOF
	fi

	#shadowsocks.service
	echo "make service file..."
	if [ ! -e /etc/systemd/system/shadowsocks.service ];then
		cat > /etc/systemd/system/shadowsocks.service << EOF
[Unit]
Description=ShadowsocksR server
After=network.target
Wants=network.target

[Service]
Type=forking
PIDFile=/var/run/shadowsocks.pid
ExecStart=/usr/bin/python /shadowsocksr/shadowsocks/server.py --pid-file /var/run/shadowsocks.pid -c /etc/shadowsocks.json -d start
ExecStop=/usr/bin/python /shadowsocksr/shadowsocks/server.py --pid-file /var/run/shadowsocks.pid -c /etc/shadowsocks.json -d stop
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
		echo "successed! shadowsocksR is running!"
	fi
else
	exit 1
fi
