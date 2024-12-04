#!/usr/bin/env bash

# 默认各参数值，请自行修改.(注意:伪装路径不需要 / 符号开始,为避免不必要的麻烦,请不要使用特殊符号.)
PORT=${PORT:-'8080'}
UUID=${UUID:-'91a72b90-bb1e-44ea-b2af-a5dcb5f4301a'}
WSPATH=${WSPATH:-'argo'}

./cloudflared-linux-amd64 tunnel --url http://localhost:8080 --no-autoupdate 2>&1 &
 

#./cloudflared-linux-amd64 tunnel --url http://localhost:${PORT} --no-autoupdate 2>&1 &
#
## 显示节点信息
#sleep 15
ARGO=$(cat argo.log | grep -oE "https://.*[a-z]+cloudflare.com" | sed "s#https://##")


# V2rayN 配置
echo "V2-rayN Configuration:"
echo "vless://${UUID}@www.digitalocean.com:443?encryption=none&security=tls&sni=${ARGO}&type=ws&host=${ARGO}&path=%2F${WSPATH}-vless#Argo-Vless"
echo "vmess://$(echo "{ \"v\": \"2\", \"ps\": \"Argo-Vmess\", \"add\": \"www.digitalocean.com\", \"port\": \"443\", \"id\": \"${UUID}\", \"aid\": \"0\", \"scy\": \"none\", \"net\": \"ws\", \"type\": \"none\", \"host\": \"${ARGO}\", \"path\": \"${WSPATH}-vmess\", \"tls\": \"tls\", \"sni\": \"${ARGO}\", \"alpn\": \"\" }" | base64 -w0)"
echo "trojan://${UUID}@www.digitalocean.com:443?security=tls&sni=${ARGO}&type=ws&host=${ARGO}&path=%2F${WSPATH}-trojan#Argo-Trojan"
echo "ss://$(echo "chacha20-ietf-poly1305:${UUID}@www.digitalocean.com:443" | base64 -w0)@www.digitalocean.com:443#Argo-Shadowsocks"
echo "传输协议: WS ，伪装域名: ${ARGO} ，路径: /${WSPATH}-shadowsocks ，传输层安全: tls ，sni: ${ARGO}"

# 小火箭 配置
echo -e "\n小火箭 Configuration:"
echo "vless://${UUID}@www.digitalocean.com:443?encryption=none&security=tls&type=ws&host=${ARGO}&path=/${WSPATH}-vless&sni=${ARGO}#Argo-Vless"
echo "vmess://$(echo "none:${UUID}@www.digitalocean.com:443" | base64 -w0)?remarks=Argo-Vmess&obfsParam=${ARGO}&path=/${WSPATH}-vmess&obfs=websocket&tls=1&peer=${ARGO}&alterId=0"
echo "trojan://${UUID}@www.digitalocean.com:443?peer=${ARGO}&plugin=obfs-local;obfs=websocket;obfs-host=${ARGO};obfs-uri=/${WSPATH}-trojan#Argo-Trojan"
echo "ss://$(echo "chacha20-ietf-poly1305:${UUID}@www.digitalocean.com:443" | base64 -w0)?obfs=wss&obfsParam=${ARGO}&path=/${WSPATH}-shadowsocks#Argo-Shadowsocks"

# Clash 配置
echo -e "\nClash Configuration:"
echo "- {name: Argo-Vless, type: vless, server: www.digitalocean.com, port: 443, uuid: ${UUID}, tls: true, servername: ${ARGO}, skip-cert-verify: false, network: ws, ws-opts: {path: /${WSPATH}-vless, headers: { Host: ${ARGO}}}, udp: true}"
echo "- {name: Argo-Vmess, type: vmess, server: www.digitalocean.com, port: 443, uuid: ${UUID}, alterId: 0, cipher: none, tls: true, skip-cert-verify: true, network: ws, ws-opts: {path: /${WSPATH}-vmess, headers: {Host: ${ARGO}}}, udp: true}"
echo "- {name: Argo-Trojan, type: trojan, server: www.digitalocean.com, port: 443, password: ${UUID}, udp: true, tls: true, sni: ${ARGO}, skip-cert-verify: false, network: ws, ws-opts: { path: /${WSPATH}-trojan, headers: { Host: ${ARGO} } } }"
echo "- {name: Argo-Shadowsocks, type: ss, server: www.digitalocean.com, port: 443, cipher: chacha20-ietf-poly1305, password: ${UUID}, plugin: v2ray-plugin, plugin-opts: { mode: websocket, host: ${ARGO}, path: /${WSPATH}-shadowsocks, tls: true, skip-cert-verify: false, mux: false } }"

echo -e "\n↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓\n"
cat list
echo -e "\n 节点保存在文件: /app/list \n"
echo -e "\n↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑\n"

# 运行 xray
./cfss run -config config.json
