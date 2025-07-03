#!/bin/bash

Font_Black="\033[30m"
Font_Red="\033[31m"
Font_Green="\033[32m"
Font_Yellow="\033[33m"
Font_Blue="\033[34m"
Font_Purple="\033[35m"
Font_Cyan="\033[36m"
Font_White="\033[37m"
Back_Black="\033[40m"
Back_Red="\033[41m"
Back_Green="\033[42m"
Back_Yellow="\033[43m"
Back_Blue="\033[44m"
Back_Purple="\033[45m"
Back_Cyan="\033[46m"
Back_White="\033[47m"
Font_Suffix="\033[0m"

Font_Green_Bold="\033[1;32m"
Font_Yellow_Bold="\033[1;33m"
Font_Blue_Bold="\033[1;34m"

# 系统名
OS_NAME=$(grep "^ID=" /etc/os-release | cut -d'=' -f2 | tr -d '"')
# 发行版本
RELEASE=$(grep "^VERSION_CODENAME=" /etc/os-release | cut -d'=' -f2 | tr -d '"')
# cpu架构
ARCH=$(uname -m)

echo_info(){
    local info="$1"
    echo -e "${Font_Blue}$info${Font_Suffix}"
}

echo_red(){
    local info="$1"
    echo -e "${Font_Red}$info${Font_Suffix}"
}

echo_yellow(){
    local info="$1"
    echo -e "${Font_Yellow}$info${Font_Suffix}"
}

# 函数：检查错误并退出
# 参数 $1: 错误消息
check_error() {
    if [ $? -ne 0 ]; then
        echo_red "发生错误： $1"
        exit 1
    fi
}

# 函数：检查是否具有 root 权限
check_run_evn() {
    if [ "$(id -u)" != "0" ]; then
        echo_red "该脚本需要 root 权限。请使用sudo或以root用户身份运行。"
        exit 1
    fi
    if [[ "$OS_NAME" != "debian" && "$OS_NAME" != "ubuntu" ]]; then
        echo_red "该脚本仅适用于 Debian 或 Ubuntu 系统。"
        exit 1
    fi
}

# 函数：校验密码是否符合规则：12位包含字符、数字、特殊字符，首和末不能是特殊字符
# 参数 $1: 生成的密码
is_valid_password() {
    local password="$1"
    local special_chars='!#$%^&*()_-'
    if [[ "${password:0:1}" == *["$special_chars"*] ]]; then
        return 1
    fi
    if [[ "${password: -1}" == *["$special_chars"*] ]]; then
        return 1
    fi
    if [[ $password =~ [$special_chars] ]]; then
        return 0
    fi
    return 1
}

# 生成密码，直到符合要求
generate_valid_password() {
    while true; do
        # 生成12位随机密码
        local candidate=$(tr -dc 'a-zA-Z0-9!#$%^&*()_-' < /dev/urandom | fold -w 12 | head -n 1)
        if is_valid_password "$candidate"; then
            echo "$candidate"
            break
        fi
    done
}

modify_sshd_port() {
    local new_port="$1"

    port_regex="^([1-9]|[1-9][0-9]{1,3}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])$"

    if ! [[ $new_port =~ $port_regex ]]; then
        echo_red "输入端口不合法，跳过设置端口"
        return 1
    fi

    cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
    check_error "备份 sshd_config 文件时出错"

    if grep -q '^Port' /etc/ssh/sshd_config; then
        sed -i 's/^Port .*/Port '"$new_port"'/g' /etc/ssh/sshd_config
        check_error "修改 Port 时出错"
    else
        echo 'Port '"$new_port"'' | tee -a /etc/ssh/sshd_config > /dev/null
        check_error "修改 Port 时出错"
    fi

    echo_info "修改端口号完成，ssh端口号：$new_port"

    # 重启sshd服务
    restart_sshd_service
}

# 函数：修改 sshd_config 文件
# 参数 $1: 输入的端口
forbidden_root_login() {

    # 注释掉 Include /etc/ssh/sshd_config.d/*.conf 行
    sed -i 's/^Include \/etc\/ssh\/sshd_config.d\/\*\.conf/# &/' /etc/ssh/sshd_config
    check_error "注释掉 Include 行时出错"
    
    # 修改为PermitRootLogin no
    if grep -q '^PermitRootLogin' /etc/ssh/sshd_config; then
        sed -i 's/^PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
        check_error "修改 PermitRootLogin 时出错"
    else
        echo 'PermitRootLogin no' | tee -a /etc/ssh/sshd_config > /dev/null
        check_error "追加 PermitRootLogin 时出错"
    fi
    echo_info "禁止 Root 用户登录完成"
    # 修改为PasswordAuthentication yes
    if grep -q '^PasswordAuthentication' /etc/ssh/sshd_config; then
        sed -i 's/^PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
        check_error "修改 PasswordAuthentication 时出错"
    else
        echo 'PasswordAuthentication yes' | tee -a /etc/ssh/sshd_config > /dev/null
        check_error "追加 PasswordAuthentication 时出错"
    fi
    echo_info "开启密码登录完成"
}

# 函数：重启 SSHD 服务
restart_sshd_service() {
    echo_info "重启sshd服务"
    systemctl restart sshd
    check_error "重启 SSHD 服务时出错"
}

# 更新软件
update_install_software() {
    echo_info "正在更新软件包"
    apt update
    check_error "更新软件包列表时出错"

    apt install -y vim nano net-tools inetutils-ping telnet ufw wget sudo ntp
    check_error "安装软件包时出错"
    echo_info "更新软件包完成"
    echo ""
}

# 修改hostname
# 参数 $1: 新的主机名
modify_hostname() {
    local newhostname="$1"
    # 检查输入是否为空
    if [ -z "$newhostname" ]
    then
        echo_red "主机名输入无效,跳过更改"
        return 1
    fi

    chattr -i /etc/hostname
    # 修改主机名
    hostnamectl set-hostname $newhostname
    # 锁定主机名
    chattr +i /etc/hostname

    # 根据主机名修改相关文件
    echo "127.0.1.1       $newhostname" >> /etc/hosts

    systemctl restart systemd-hostnamed

    echo -e "${Font_Blue}主机名已修改为: ${Font_Suffix}${Font_Red}$newhostname${Font_Suffix}"
}

# 添加用户，自动生成密码
add_user() {
    local newuser="$1"

    if [ -z "$newuser" ]; then
        echo_red "输入用户为空，跳过新建用户"
        return 1
    fi

    if id "$newuser" &>/dev/null; then
        echo_red "用户：$newuser 已存在，跳过新建用户"
        return 1
    fi

    local password=$(generate_valid_password)
    
    # 创建用户
    adduser --disabled-password --gecos "" $newuser
    echo "$newuser:$password" | chpasswd
    check_error "创建用户时出错"

    # 添加用户到 sudo 组
    echo "$newuser ALL=(ALL:ALL) NOPASSWD: ALL" | EDITOR='tee -a' visudo

    echo_info "新建用户完成"
    echo -e "${Font_Blue}用户名:${Font_Suffix} ${Font_Red}$newuser${Font_Suffix}"
    echo -e "${Font_Blue}密  码:${Font_Suffix} ${Font_Red}$password${Font_Suffix}"

    # 修改sshd配置文件
    forbidden_root_login
    # 重启sshd服务
    restart_sshd_service
}

# 设置时区
set_timezone_shanghai(){
    echo_info '修改时区为上海开始'
    timedatectl set-timezone Asia/Shanghai
    current_time=$(date +"%Y-%m-%d %H:%M:%S")
    echo_info "当前时间：$current_time"
    echo_info '修改时区为上海完成'
    echo ""
}

# 开启bbr
enable_bbr(){
    echo_info "开启bbr开始"
    if ! grep -q '^net\.core\.default_qdisc=fq' /etc/sysctl.conf; then
        echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
    fi

    if ! grep -q '^net\.ipv4\.tcp_congestion_control=bbr' /etc/sysctl.conf; then
        echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
    fi

    sysctl -p
    echo_info "开启bbr完成"
    echo ""
}

# 设置ipv4优先
set_ipv4_priority(){
#    echo_info '设置IPv4优先开始'
#    if ! grep -q '^precedence ::ffff:0:0/96 100' /etc/gai.conf; then
#        echo 'precedence ::ffff:0:0/96 100' >> /etc/gai.conf
#    fi
#    echo_info '测试IPv4优先度:'
#    curl -s --connect-timeout 3 -m 5 ip.p3terx.com | head -n 1
    ipv4=$(curl -4 -s --connect-timeout 3 -m 5 ip.gs)
    ipv6=$(curl -6 -s --connect-timeout 3 -m 5 ip.gs)
#    echo_info '设置IPv4优先完成'
    echo -e "${Font_Blue}当前主机ipv4地址: ${Font_Suffix}${Font_Red}${ipv4}${Font_Suffix}"
    echo -e "${Font_Blue}当前主机ipv6地址: ${Font_Suffix}${Font_Red}${ipv6}${Font_Suffix}"
    echo ""
}

base_setting() {
    # 更新软件
    update_install_software

    # 开启BBR
    enable_bbr

    # 设置时区为上海
    set_timezone_shanghai

    # 设置IPV4优先
     set_ipv4_priority

    # 修改hostname
    read -p "请输入新的主机名(输入为空跳过): " newHostname
    modify_hostname $newHostname

    # 创建新用户
    read -p "请输入新的用户名(输入为空跳过): " newUser
    add_user $newUser

    # 修改ssh端口
    read -p "请输入新的ssh端口(输入为空跳过): " sshPort
    modify_sshd_port $sshPort
}

config_ufw() {
    local port="$1"
    if command -v ufw > /dev/null; then
        echo_info "配置防火墙, 放行端口: ${port}"
        ufw allow ${port}
    else
        echo_red "未找到 UFW 防火墙，跳过防火墙配置。"
    fi
}

install_nginx() {
    if command -v nginx >/dev/null 2>&1; then
        echo "NGINX 已安装, 版本: $(nginx -v)"
        return 1;
    fi

    apt update && apt install -y curl &&  apt install -y gnupg

    echo_info '导入Nginx官方签名密钥'
    curl -fsSL https://nginx.org/keys/nginx_signing.key | gpg --dearmor -o /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null

    echo_info '添加Nginx官方仓库'
    echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] \
    http://nginx.org/packages/${OS_NAME} ${RELEASE} nginx" \
        | tee /etc/apt/sources.list.d/nginx.list

    apt update

    apt install -y nginx

    systemctl start nginx

    echo_info "Nginx安装版本: $(nginx -v)"
    echo_info "安装信息:"
    echo_info "NGINX主程序: /usr/sbin/nginx"
    echo_info "配置文件目录: /etc/nginx/nginx.conf"
    echo_info "日志目录:"
    echo_info "  访问日志: /var/log/nginx/access.log"
    echo_info "  错误日志: /var/log/nginx/error.log"
    echo_info "默认网站根目录: /var/share/html"
    echo_info "pid文件: /var/run/nginx.pid"
    echo_info "默认启动用户: www-data"
}

install_fail2ban() {
    if command -V fail2ban-server >/dev/null 2>&1; then
        echo "Fail2ban 已安装, 版本: $(fail2ban-server -V)"
        return 1;
    fi

    apt update && apt install -y fail2ban
    # 默认端口
    default_port=22
    ssh_port=$default_port

    # 检查 SSH 配置文件是否存在
    if [ -f "$ssh_config_file" ]; then
        # 尝试从配置文件中获取端口号
        ssh_port=$(grep -i "^Port" "$ssh_config_file" | awk '{print $2}')
        # 检查端口号是否为空
        if [ -z "$ssh_port" ]; then
            ssh_port=$default_port
        fi
    else
        # 如果文件不存在，设置为默认端口
        ssh_port=$default_port
    fi

    echo -e "[sshd]
enabled = true
port    = ${ssh_port}
logpath = %(sshd_log)s
backend = %(sshd_backend)s
maxretry = 3
findtime = 60
bantime = -1
banaction = iptables-allports" > /etc/fail2ban/jail.d/sshd.conf

    systemctl start fail2ban

    echo_info "Fail2ban安装完成: $(fail2ban-server -V)"
    echo_info "状态: $(fail2ban-client ping)"
    echo_info "日志文件: /var/log/fail2ban.log"
    echo_info "查看ssh服务: fail2ban-client status sshd"
    echo_info "解除IP封禁: fail2ban-client set sshd unbanip 192.168.1.12"
}

install_qBittorrent() {
    if [[ -e ~/bin/qbittorrent-nox ]]; then
        echo "qBittorrent已安装, 版本: $(~/bin/qbittorrent-nox -v)"
        return 1
    fi

    mkdir -p ~/bin && source ~/.profile
    case $ARCH in
        x86_64|i686)
            wget -qO ~/bin/qbittorrent-nox https://github.com/userdocs/qbittorrent-nox-static/releases/download/release-4.6.6_v2.0.10/x86_64-qbittorrent-nox
            ;;
        armv7l|aarch64|arm64)
            wget -qO ~/bin/qbittorrent-nox https://github.com/userdocs/qbittorrent-nox-static/releases/download/release-4.6.6_v2.0.10/aarch64-qbittorrent-nox
            ;;
        *)
            echo_red "未知的系统架构: $ARCH，安装失败"
            ;;
    esac
    chmod 700 ~/bin/qbittorrent-nox
    echo -e "[Unit]
Description=qBittorrent-nox service
Wants=network-online.target
After=network-online.target nss-lookup.target
[Service]
Type=exec
User=root
ExecStart=/root/bin/qbittorrent-nox
Restart=on-failure
SyslogIdentifier=qbittorrent-nox
[Install]
WantedBy=multi-user.target" > /etc/systemd/system/qbittorrent.service

    systemctl daemon-reload

    systemctl enable qbittorrent

    systemctl start qbittorrent

    echo "等待qBittorrent启动中..."
    sleep 5

    systemctl stop qbittorrent
    echo "等待修改qBittorrent配置中..."
    sleep 5

    echo -e "[Application]
FileLogger\Age=1
FileLogger\AgeType=1
FileLogger\Backup=true
FileLogger\DeleteOld=true
FileLogger\Enabled=false
FileLogger\MaxSizeBytes=66560
FileLogger\Path=/root/.local/share/qBittorrent/logs

[BitTorrent]
Session%1BxcludedFileNames=
Session\DefaultSavePath=/data/Downloads
Session\ExcludedFileNames=
Session\MaxConnections=-1
Session\MaxConnectionsPerTorrent=-1
Session\MaxUploads=-1
Session\MaxUploadsPerTorrent=-1
Session\Port=31299
Session\QueueingSystemEnabled=false
Session\TempPath=/data/Downloads/temp

[Core]
AutoDeleteAddedTorrentFile=IfAdded

[Meta]
MigrationVersion=6

[Preferences]
General\Locale=zh_CN
MailNotification\req_auth=true
WebUI\AuthSubnetWhitelist=@Invalid()
WebUI\Password_PBKDF2=\"@ByteArray(q4NsB2hfJpoIAGb6aOoKNQ==:DCPLbiIJmyGMzKXdvpoW5YC/yKAr9p6nBLzDEpSst085f03omdFdRgoD7/3jbHnbQdu29uq751JEYD4ipj0CaQ==)\"
WebUI\Username=pengjy

[RSS]
AutoDownloader\DownloadRepacks=true
AutoDownloader\SmartEpisodeFilter=s(\\d+)e(\\d+), (\\d+)x(\\d+), \"(\\d{4}[.\\-]\\d{1,2}[.\\-]\\d{1,2})\", \"(\\d{1,2}[.\\-]\\d{1,2}[.\\-]\\d{4})\"" > /root/.config/qBittorrent/qBittorrent.conf

    config_ufw 31299
    systemctl start qbittorrent
    echo_info "qBittorrent安装完成: $(~/bin/qbittorrent-nox -v)"
    echo_info "WebUI端口: 8080"
    echo_info "P2P连接端口: 31299"
    echo_info "用户名: pengjy"
    echo_info "密码: "
}

install_realm(){
    if command -v realm >/dev/null 2>&1; then
        echo "Realm 已安装, 版本: $(realm -v)"
        return 1;
    fi

    mkdir -p ~/bin && source ~/.profile
    case $ARCH in
        x86_64|i686)
            wget -O realm.tar.gz https://github.com/zhboner/realm/releases/download/v2.6.0/realm-x86_64-unknown-linux-musl.tar.gz
            ;;
        armv7l|aarch64|arm64)
            wget -O realm.tar.gz https://github.com/zhboner/realm/releases/download/v2.6.0/realm-aarch64-unknown-linux-musl.tar.gz
            ;;
        *)
            echo_red "未知的系统架构: $ARCH，安装失败"
            ;;
    esac
    tar -zxvf realm.tar.gz
    install -m 755 realm /usr/local/bin/realm
    install -m 600 /dev/null /var/log/realm.log
    install -d /usr/local/etc/realm/
    echo "{}" > /usr/local/etc/realm/config.json
    echo -e "[Unit]
Description=realm
After=network-online.target
Wants=network-online.target systemd-networkd-wait-online.service

[Service]
Type=simple
User=root
Restart=on-failure
RestartSec=5s
ExecStart=/usr/local/bin/realm -c /usr/local/etc/realm/config.json

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/realm.service

    systemctl daemon-reload
    systemctl enable realm

    systemctl start realm

    rm realm
    rm realm.tar.gz

    echo_info "Realm安装版本: $(realm -v)"
    echo_info "Realm安装信息:"
    echo_info "Realm主程序: /usr/local/bin/realm"
    echo_info "Realm配置文件: /usr/local/etc/realm/config.json"
    echo_info "Realm日志文件: /var/log/realm.log"
}

main_option(){
    for i in {1..100}; do
        echo ""
        echo_yellow "请选择要执行的操作："
        echo "---------------基础设置---------------"
        echo_red "1. 一键初始化主机设置"
        echo "---------------常用软件---------------"
        echo "21. 安装Xray"
        echo "22. 安装Nginx"
        echo "23. 安装Realm"
        echo "24. 安装Docker"
        echo "26. 安装QBittorrent"
        echo "---------------常用功能---------------"
        echo "31. 查询Xray统计数据"
        echo "---------------常用检测---------------"
        echo "41. NodeQuality检测"
        echo "-------------------------------------"
        echo_yellow "0. 退出脚本"
        echo ""
        read -p "请输入数字 (0-9): " user_input

        case $user_input in
            1)
                base_setting
                ;;
            21)
                # 安装xray
                echo_info "安装Xray开始..."
                bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install
                echo_info "安装Xray完成"
                ;;
            22)
                # 安装Nginx
                echo_info "安装Nginx开始..."
                install_nginx
                echo_info "安装Nginx完成"
                ;;
            23)
                # 安装realm
                echo_info "安装Realm开始..."
                install_realm
                echo_info "安装Realm完成"
                ;;
            24)
               # 安装Docker
               echo_info "安装Docker开始..."
               curl -sSL https://get.docker.com/ | sh
               echo_info "安装docker-compose开始..."
               apt update && apt install -y docker-compose
               echo_info "安装Docker完成"
               ;;
#            25)
#               # 安装Fail2ban
#               echo_info "安装Fail2ban开始..."
#               install_fail2ban
#               echo_info "安装Fail2ban完成"
#               ;;
            26)
                # 安装QBittorrent
                echo_info "安装QBittorrent开始..."
                install_qBittorrent
                echo_info "安装QBittorrent完成"
                ;;
            31)
                # 查询Xray统计数据
                echo_info "查询Xray统计数据开始..."
                bash <(curl -sL https://raw.githubusercontent.com/noirety/common-scripts/main/sh/query-xray.sh | tee query-xray.sh)
                echo_info "查询Xray统计数据完成..."
                ;;
#            33)
#                echo_info "清除Oracle默认防火墙规则开始..."
#                iptables -F
#                echo_info "清除Oracle默认防火墙规则完成"
#                ;;
            41)
                echo_info "NodeQuality检测开始..."
                bash <(curl -sL https://run.NodeQuality.com)
                echo_info "NodeQuality检测完成"
                ;;
            0)
                echo "退出脚本"
                exit 0
                ;;
            *)
                echo "无效的输入"
                echo ""
                ;;
        esac

        read -p "输入任意字符返回菜单: " ignore
    done
}

# 主函数
main() {
    check_run_evn
    main_option
}

# 执行主函数
main