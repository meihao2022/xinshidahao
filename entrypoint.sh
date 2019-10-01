#! /bin/bash
if [[ -z "${V2_Path}" ]]; then
  V2_Path="/FreeApp"
fi

rm -rf /etc/localtime
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
date -R

SYS_Bit="$(getconf LONG_BIT)"
[[ "$SYS_Bit" == '32' ]] && BitVer='_linux_386.tar.gz'
[[ "$SYS_Bit" == '64' ]] && BitVer='_linux_amd64.tar.gz'


mkdir /goflyway-heroku
cd /goflyway-heroku
wget --no-check-certificate -qO 'goflyway.zip' "https://github.com/coyove/goflyway/releases/download/2.0.0rc1/goflyway_windows_amd64.zip"
tar -zxf goflyway.tar.gz
chmod +x goflyway

C_VER=`wget -qO- "https://api.github.com/repos/mholt/caddy/releases/latest" | grep 'tag_name' | cut -d\" -f4`
mkdir /caddybin
cd /caddybin
wget --no-check-certificate -qO 'caddy.tar.gz' "https://github.com/mholt/caddy/releases/download/$C_VER/caddy_$C_VER$BitVer"
tar xvf caddy.tar.gz
rm -rf caddy.tar.gz
chmod +x caddy
cd /root
mkdir /wwwroot
cd /wwwroot

wget --no-check-certificate -qO 'demo.tar.gz' "https://github.com/z0day/v2ray-heroku-undone/raw/master/demo.tar.gz"
tar xvf demo.tar.gz
rm -rf demo.tar.gz

cat <<-EOF > /caddybin/Caddyfile
http://0.0.0.0:${PORT}
{
	root /wwwroot
	index index.html
	timeouts none
	proxy ${V2_Path} localhost:2333 {
		websocket
		header_upstream -Origin
	}
}
EOF



cd /goflyway-heroku
./goflyway -k="$KEY"  -l=":$PORT" -lv="$LEVEL" &
cd /caddybin
./caddy -conf="Caddyfile"
