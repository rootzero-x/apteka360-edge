#!/usr/bin/env bash
# Apteka 360 Edge — filial serveriga ilovani o'rnatish (Kali / Debian / Ubuntu, XFCE).
#   curl -fsSL https://github.com/rootzero-x/apteka360-edge/releases/latest/download/install.sh | sudo bash
set -euo pipefail
REL=https://github.com/rootzero-x/apteka360-edge/releases/latest/download
DEST=/opt/apteka360-edge
[ "$(id -u)" = 0 ] || { echo "sudo bilan ishga tushiring"; exit 1; }
export DEBIAN_FRONTEND=noninteractive

echo "== Kerakli paketlar"
apt-get update -qq
apt-get install -y -qq curl ca-certificates python3 zenity policykit-1 >/dev/null 2>&1 || apt-get install -y -qq curl ca-certificates python3 zenity pkexec >/dev/null

echo "== Ilova yuklanmoqda"
TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT
curl -fsSL --retry 5 -o "$TMP/app.tar.gz" "$REL/apteka360-edge-app.tar.gz"
mkdir -p "$DEST"
# Sozlamalar (edge_agent.ini, yozuvlar, AI ma'lumotlari) qayta o'rnatishda saqlanadi
tar -xzf "$TMP/app.tar.gz" -C "$DEST" --skip-old-files
tar -xzf "$TMP/app.tar.gz" -C "$DEST" --overwrite bin tools share stack/edge-agent/docker-compose.yml stack/edge-agent/mediamtx.yml stack/edge-ai/docker-compose.yml stack/edge-ai/models
chmod 755 "$DEST"/bin/*

echo "== Tizim xizmatlari"
install -m 644 "$DEST/share/apteka360-edge-watch.service" "$DEST/share/apteka360-edge-watch.timer" /etc/systemd/system/
install -m 644 "$DEST/share/uz.apteka360.edge.policy" /usr/share/polkit-1/actions/
install -m 644 "$DEST/share/apteka360-edge.desktop" /usr/share/applications/
U=${SUDO_USER:-}
if [ -n "$U" ] && [ -d "/home/$U/Desktop" ]; then install -m 755 -o "$U" "$DEST/share/apteka360-edge.desktop" "/home/$U/Desktop/"; fi
systemctl daemon-reload

echo "== Docker va image'lar (~1 GB, internet tezligiga qarab bir necha daqiqa)"
"$DEST/bin/apteka360-edge-setup" prepare
[ -n "$U" ] && usermod -aG docker "$U" || true
systemctl enable apteka360-edge-watch.timer >/dev/null

echo
echo "Tayyor. Menyu → Apteka 360 Edge (yoki ish stolidagi belgi) ni oching, kiring va filialni tanlang."
if [ -n "$U" ] && [ -n "${DISPLAY:-}${WAYLAND_DISPLAY:-}" ]; then sudo -u "$U" DISPLAY="${DISPLAY:-:0}" nohup "$DEST/bin/apteka360-edge" >/dev/null 2>&1 & fi
