#!/bin/bash

# 函数：检查并安装缺失的软件
check_and_install() {
  local package=$1
  if ! command -v $package &>/dev/null; then
    echo "$package 未安装，正在安装..."
    if [[ -n "$(command -v apt-get)" ]]; then
      sudo apt-get update
      sudo apt-get install -y $package
    elif [[ -n "$(command -v yum)" ]]; then
      sudo yum install -y $package
    elif [[ -n "$(command -v dnf)" ]]; then
      sudo dnf install -y $package
    else
      echo "无法自动安装 $package，请手动安装。"
      exit 1
    fi
  fi
}

# 检查并安装必要的软件
check_and_install jq

get_ipv6_address() {
  INTERFACE=$1
  ip -6 addr show dev "$INTERFACE" | grep 'global' | awk '{print $2}' | cut -d/ -f1 | head -n 1
}

get_public_ipv42() {
  # 定义要请求的 URL 列表
  urls=(
    "https://myip.ipip.net"
    "https://ddns.oray.com/checkip"
    "https://ip.3322.net"
    "https://4.ipw.cn"
  )

  # 正则表达式匹配 IPv4 地址
  regex='([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)'

  # 遍历 URL 列表
  for url in "${urls[@]}"; do
    response=$(curl -s "$url")
    # 使用正则表达式提取 IPv4 地址
    if [[ $response =~ $regex ]]; then
      echo ${BASH_REMATCH[1]}
      return
    fi
  done
}

get_cloudflare_zone_id() {
  ZONE_NAME=$1
  API_TOKEN=$2
  ZONE_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=${ZONE_NAME}" \
    -H "Authorization: Bearer ${API_TOKEN}" \
    -H "Content-Type: application/json" | jq -r '.result[0].id')
  echo $ZONE_ID
}

get_cloudflare_ddns_list() {
  ddns=$(curl -X GET --location "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records" \
    -H "Authorization: Bearer ${API_TOKEN}" \
    -H "Content-Type: application/json")

}

main() {
  INTERFACE="ens33"

  ZONE_NAME="sparkless.de"

  API_TOKEN="L83i80UyDhKkMD48IrL5NRvtxTq9bjKJ3_tbebRE"

  ipv6_address=$(get_ipv6_address $INTERFACE)
  echo $ipv6_address

  ipv4_address=$(get_public_ipv42)
  echo $ipv4_address

  ZONE_ID=$(get_cloudflare_zone_id $ZONE_NAME $API_TOKEN)
  echo $ZONE_ID
}

main
