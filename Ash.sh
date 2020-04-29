#!/bin/bash


cent_start(){
yum -y install wget gcc gcc-c++ yum-fastestmirror

# install axel
cd /tmp/ && wget https://raw.githubusercontent.com/eterntl/yum/master/axel-2.4.tar.gz
tar -xvf axel-2.4.tar.gz && cd axel-2.4
./configure && make && make install && cd
wget -O /etc/yum/pluginconf.d/axelget.conf https://raw.githubusercontent.com/eterntl/yum/master/axelget.conf
wget -O /usr/lib/yum-plugins/axelget.py https://raw.githubusercontent.com/eterntl/yum/master/axelget.py

# add epel
 wget -O /etc/yum.repos.d/epel.repo https://raw.githubusercontent.com/eterntl/yum/master/epel.repo
 
# yum gcc_rely
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bak && wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-6.repo
yum clean all
yum makecache
yum -y install vim unzip  pcre* lrzsz  libaio*  openssh-clients rdate

# ntpdate
rm -rf /etc/localtime && ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
rdate -s time.nist.gov

# disable selinux
sed -ri '7s/enforcing/disabled/i' /etc/selinux/config && sed -n '7p' /etc/selinux/config

# Start iptables
service iptables status || service iptables start 

# Modify ssh Port
grep '\<Port 57657\>' /etc/ssh/sshd_config || sed -i '14a Port 57657' /etc/ssh/sshd_config && sed -n '15p' /etc/ssh/sshd_config 


# Delete system login kernel prompt
if [  -s /etc/issue ];then
/bin/cp /etc/issue /etc/issue.bak && >/etc/issue 
fi

# Modify history
grep -i 'HISTSIZE=30' /etc/profile || sed -i '48s/HISTSIZE=1000/HISTSIZE=30/' /etc/profile && source /etc/profile

# Shielding ping request
#echo "1" > /proc/sys/net/ipv4/icmp_echo_ignore_all && echo "Shielding ping request success" || echo "Shielding ping request fail"
#echo ""

# setup file ulimit
ulimit -SHn 655355
grep -i 'ulimit -SHn 655355' /etc/rc.local || echo "ulimit -SHn 65535" >> /etc/rc.local && source /etc/rc.local
grep '655355' /etc/security/limits.conf
if [ ! $? -eq 0 ];then
cat >> /etc/security/limits.conf << UFO
*	soft	nofile	655355
*	hard	nofile	655355
UFO
fi

# setup key login
cat >> /root/.ssh/authorized_keys << UFO
ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA0oRZeMk7RGzcD6HMMtBjdfJo7uKJnBRioIUV08KKvEtvFs5jALnmrF242xOMcRaCNcqxZp5IU62lM27AnC4f1oiu6E0FNTk+LdKZTgokEfqG+F2qEcWQAWN7wBLGU91Lg9os0UGaxWd6VBFgPg98OTevko9jSNwmzZnSYJhvowhm2J71DyuP5iW39AzVkODSuJqdMKGx0aiSXqwoU1lrarB5tQ7tk2PFQ2F6HlLyOwAaXQp8+XoYZz0ukE4cL8kWYnDA5wnXicvl9RYQSimZUEGqFhPYlTDBUZXjhqy3mOf1u+ZLiOwExZuDvXxYkYgCYTqkSYPqwYQ9Qojk2YCX5Q== bjb
ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAtrRMfy84y/XeqQwZOxJnZ+XuV8dzmDMigseVtR0tqGXGwUe3Ul7OMocQTetSr5VPiU2lPMEgCo7zufn++FULkSG3z4shs0uRihk/lY0MsmmorzFom+Avnoai+XSMB69Oc6Vjsk+5mHaeKPX3H2X1wzY2sY3rw8Cpuq36apmWL4zIh6+htfFzYjWS+rmsLs4xY1O2bJvFXpcnXyEgcf0wX9pGySIYS508y8RkGg4zx3QxbCOgDiQYpaa0jPAsM4h4pexT00yvtenADtRficwKhafxTqKN4y5WqwY6i1dGalsnuYLj9XTE3YbQUmLJscv3Tvr5S5ky3idOMHFCwf2EkQ== Mr.zy
UFO
sed -i 's/#RSAAuthentication yes/RSAAuthentication yes/' /etc/ssh/sshd_config 
sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config 
sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config && service sshd restart 

# system optimize
grep -E 'net.ipv4.tcp_synack_retries =2|net.ipv4.tcp_max_syn_backlog = 200000' /etc/sysctl.conf
if [ ! $? -eq 0 ];then
cat >> /etc/sysctl.conf << UFO
net.ipv4.tcp_synack_retries =2
net.ipv4.tcp_max_syn_backlog = 200000
fs.file-max = 655355
net.ipv4.ip_conntrack_max = 655355
net.ipv4.netfilter.ip_conntrack_max = 655355
net.core.somaxconn = 20480
net.core.rmem_max = 1024123000
net.core.wmem_max = 16777216
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_tw_reuse=1
UFO
fi

# login log
grep 'ngux' /etc/profile
if [ ! $? -eq 0 ];then
cat >> /etc/profile << 'UFO'
history
USER_IP=`who -u am i 2>/dev/null| awk '{print $NF}'|sed -e 's/[()]//g'`
if [ "$USER_IP" = "" ]
then
USER_IP=`hostname`
fi
if [ ! -d /tmp/.ngux ]
then
mkdir /tmp/.ngux
chmod 644 /tmp/.ngux
fi
if [ ! -d /tmp/.ngux/${LOGNAME} ]
then
mkdir  /tmp/.ngux/${LOGNAME}
fi
if [ ! -d /tmp/.ngux/${LOGNAME}/${USER_IP} ]
then
mkdir  /tmp/.ngux/${LOGNAME}/${USER_IP}
chmod -R 600 /tmp/.ngux/${LOGNAME}
fi
export HISTSIZE=4096
DT=`date "+%Y-%m%d-%H%M"`
export HISTFILE="/tmp/.ngux/${LOGNAME}/${USER_IP}/$DT"
chmod -R 600 /tmp/.ngux/${LOGNAME}/${USER_IP}/* 2>/dev/null
UFO
source /etc/profile
fi

########################
### iptables相关策略 ###
########################
iptables -F
> /etc/sysconfig/iptables
if [ ! -s /etc/sysconfig/iptables ];then
cat >> /etc/sysconfig/iptables << UFO
*filter
:INPUT DROP [0:0]
:FORWARD DROP [0:0]
:OUTPUT ACCEPT [464:26100]
:PING_OF_DEATH - [0:0]
:STEALTH_SCAN - [0:0]
:SYN_FLOOD - [0:0]
-A INPUT -i lo -j ACCEPT
-A INPUT -p icmp -j ACCEPT
-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
-A INPUT -p tcp -m multiport --dports 57657 -j ACCEPT
-A INPUT -p tcp -m multiport --dports 10050 -j ACCEPT
#-A INPUT -s 192.168.83.0/24 -p tcp -m multiport --dports 7777,10000,10001,10002,8090 -j ACCEPT
-A INPUT -p tcp -m tcp --dport 80 -m recent --update --seconds 60 --hitcount 20 --name BAD_HTTP_ACCESS --rsource -j REJECT --reject-with icmp-port-unreachable
-A INPUT -p tcp -m tcp --dport 80 -m recent --set --name BAD_HTTP_ACCESS --rsource -j ACCEPT
-A INPUT -p tcp -m tcp --dport 443 -m recent --update --seconds 60 --hitcount 20 --name BAD_HTTP_ACCESS --rsource -j REJECT --reject-with icmp-port-unreachable
-A INPUT -p tcp -m tcp --dport 443 -m recent --set --name BAD_HTTP_ACCESS --rsource -j ACCEPT
-A INPUT -p icmp -m icmp --icmp-type 8 -j PING_OF_DEATH
-A INPUT -p icmp -m limit --limit 3/sec -j LOG --log-prefix "ICMP packet IN: " --log-level 6
-A INPUT -p icmp -j DROP
-A INPUT -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK SYN -j SYN_FLOOD
-A INPUT -p tcp -m tcp --tcp-flags SYN,ACK SYN,ACK -m state --state NEW -j STEALTH_SCAN
-A INPUT -p tcp -m tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG NONE -j STEALTH_SCAN
-A INPUT -p tcp -m tcp --tcp-flags FIN,SYN FIN,SYN -j STEALTH_SCAN
-A INPUT -p tcp -m tcp --tcp-flags SYN,RST SYN,RST -j STEALTH_SCAN
-A INPUT -p tcp -m tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG FIN,SYN,RST,ACK,URG -j STEALTH_SCAN
-A INPUT -p tcp -m tcp --tcp-flags FIN,RST FIN,RST -j STEALTH_SCAN
-A INPUT -p tcp -m tcp --tcp-flags FIN,ACK FIN -j STEALTH_SCAN
-A INPUT -p tcp -m tcp --tcp-flags PSH,ACK PSH -j STEALTH_SCAN
-A INPUT -p tcp -m tcp --tcp-flags ACK,URG URG -j STEALTH_SCAN
-A FORWARD -p icmp -j ACCEPT
-A FORWARD -m state --state ESTABLISHED -j ACCEPT
-A PING_OF_DEATH -p icmp -m icmp --icmp-type 8 -m hashlimit --hashlimit-upto 1/sec --hashlimit-burst 10 --hashlimit-mode srcip --hashlimit-name t_PING_OF_DEATH --hashlimit-htable-expire 300000 -j RETURN
-A PING_OF_DEATH -j LOG --log-prefix "ping_of_death_attack: "
-A PING_OF_DEATH -j DROP
-A STEALTH_SCAN -j LOG --log-prefix "stealth_scan_attack: "
-A STEALTH_SCAN -j DROP
-A SYN_FLOOD -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK SYN -m hashlimit --hashlimit-upto 200/sec --hashlimit-burst 3 --hashlimit-mode srcip --hashlimit-name t_SYN_FLOOD --hashlimit-htable-expire 300000 -j RETURN
-A SYN_FLOOD -j LOG --log-prefix "syn_flood_attack: "
-A SYN_FLOOD -j DROP
COMMIT
UFO
service iptables restart  
fi
}



cent_start
#正式开始初始化
