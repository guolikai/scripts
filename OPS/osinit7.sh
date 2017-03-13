cat >> /etc/sysctl.conf << EOF
net.ipv4.ip_forward = 0
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.default.accept_source_route = 0
kernel.sysrq = 0
kernel.core_uses_pid = 1
net.ipv4.tcp_syncookies = 1
kernel.msgmnb = 65536
kernel.msgmax = 65536
kernel.shmmax = 68719476736
kernel.shmall = 4294967296
net.ipv4.tcp_max_tw_buckets = 6000
net.ipv4.tcp_sack = 1
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_rmem = 4096 87380 4194304
net.ipv4.tcp_wmem = 4096 16384 4194304
net.core.wmem_default = 8388608
net.core.rmem_default = 8388608
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.core.netdev_max_backlog = 262144
net.core.somaxconn = 65535
net.ipv4.tcp_max_orphans = 3276800
net.ipv4.tcp_max_syn_backlog = 262144
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_synack_retries = 1
net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_mem = 94500000 915000000 927000000
net.ipv4.tcp_fin_timeout = 1
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.ip_local_port_range = 25000 65535
vm.swappiness = 1
kernel.hung_task_timeout_secs = 0
vm.dirty_background_ratio = 5
vm.dirty_ratio = 10
vm.overcommit_memory = 1
EOF
sysctl -p

cat >> /etc/security/limits.conf << EOF
*           soft   nofile       102400
*           hard   nofile       102400
*           soft   nproc        102400
*           hard   nproc        102400
EOF

cat >> /etc/profile << EOF
ulimit -SHn 102400
alias grep='grep --color=auto'
export HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S "
EOF

sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
setenforce 0

#cat >> /etc/resolv.conf << EOF
#nameserver 192.168.90.1 
#nameserver 192.168.10.8
#EOF

systemctl restart network

sed -i 's/.*UseDNS yes/UseDNS no/' /etc/ssh/sshd_config
sed -i 's/.*GSSAPIAuthentication yes/GSSAPIAuthentication no/' /etc/ssh/sshd_config
systemctl restart sshd


mkdir -p /App/script/{SRT,OPS} /App/src/{SRT,OPS} /App/build/{SRT,OPS} /App/install/{SRT,OPS} /App/conf/{SRT,OPS} /App/log/{SRT,OPS} /App/opt/{SRT,OPS} /App/mnt/{UGC,RES} /App/data /App/backup/HOST

mount --bind /dev/shm /tmp
echo "/bin/mount --bind /dev/shm /tmp" >> /etc/rc.local
#yum -y --skip-broken install wget

#mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bak
#wget http://mirrors.aliyun.com/repo/Centos-7.repo -O /etc/yum.repos.d/CentOS-Base.repo
rpm -ivh http://mirrors.aliyun.com/epel/epel-release-latest-7.noarch.rpm

yum -y --skip-broken install ntpdate screen wget rsync curl gcc vim-enhanced xz iftop sysstat dstat htop iotop lrzsz

cat > /var/spool/cron/root << EOF
0  *  *  *  *  /usr/sbin/ntpdate time.nist.gov &> /dev/null
EOF

#wget http://192.168.10.6/vim/molokai.vim -O /usr/share/vim/vim74/colors/molokai.vim
#wget -r http://192.168.10.6/zabbix_init/ -O /App/src/OPS/
#wget http://192.168.10.6/ipinit7.sh -O /App/script/OPS/ipinit.sh

#mkdir -p /root/.ssh
#echo 'ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAxWNKngBgnhFsNgNLb1gmo99UwUvBxQU4qIJtrAOM5c+uf1FJXoeWyXp7oHEBcGjCPI9C/lQ6gJLKhz59TeondyNfBC6YzEqdwmOxNChm8UwpuiZlyNQz3KzFgZOvxXiqnq6iKgVQrKh/V4d4mroqojVu2i19e3CAfbgwom4uosHsD4uMZlqJ5Z7/LI/ZymVOphzR1tgBAhA25dlxa0gJOMEKfYjFUG7SFMVKWJfzKdL2g2UsjzRUWBxHdnyFyt3hMXThLsAF+gBv5KqMjVXfXxfqEVeiDE6xijRzZ42keKc/JPRU5bmiVcVTxrwlMnMXbT02EM9twB/yrlBcPHvxdw== root@localhost.localdomain' >> /root/.ssh/authorized_keys
#chmod 600 /root/.ssh/authorized_keys

#curl -k 'http://192.168.11.3/api/duty/duty_pool.php?key=logapp&type=2'




cat >> /etc/vimrc << EOF
set fenc=utf-8 "设定默认解码
set fencs=utf-8,usc-bom,euc-jp,gb18030,gbk,gb2312,cp936
set nocp "或者 set nocompatible 用于关闭VI的兼容模式
set number "显示行号
set ai "或者 set autoindent vim使用自动对齐，也就是把当前行的对齐格式应用到下一行
set si "或者 set smartindent 依据上面的对齐格式，智能的选择对齐方式
set tabstop=4 "设置tab键为4个空格
set sw=4 "或者 set shiftwidth 设置当行之间交错时使用4个空格
set ruler "设置在编辑过程中,于右下角显示光标位置的状态行
set incsearch "设置增量搜索,这样的查询比较smart
set showmatch "高亮显示匹配的括号
set matchtime=5 "匹配括号高亮时间(单位为 1/10 s)
set ignorecase "在搜索的时候忽略大小写
syntax on
filetype plugin indent on
syntax enable
set cursorline
set t_Co=256
colorscheme molokai
autocmd BufNewFile,BufRead * :syntax match cfunctions "\<[a-zA-Z_][a-zA-Z_0-9]*\>[^()]*)("me=e-2
autocmd BufNewFile,BufRead * :syntax match cfunctions "\<[a-zA-Z_][a-zA-Z_0-9]*\>\s*("me=e-1"))"
hi cfunctions ctermfg=81
hi Type ctermfg=118 cterm=none
hi Structure ctermfg=118 cterm=none
hi Macro ctermfg=161 cterm=bold
hi PreCondit ctermfg=161 cterm=bold
EOF
%end
