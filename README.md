# Apteka 360 Edge

Filial Edge serverini (kameralar, ovoz, tunnel, Edge-AI) bitta ilova bilan o'rnatish va kuzatish.

## O'rnatish (Kali / Debian / Ubuntu, XFCE)
```bash
curl -fsSL https://github.com/rootzero-x/apteka360-edge/releases/latest/download/install.sh | sudo bash
```
Keyin **Menyu → Apteka 360 Edge**: Egasi yoki Super admin hisobi bilan kiring → Telegram kodi → filialni tanlang.

Ilova o'zi: Docker o'rnatadi, image'larni yuklaydi (uzilsa davom etadi), filial sozlamasini serverdan oladi,
Edge + Edge-AI ni ishga tushiradi, kameralarni moslaydi (H.265 → H.264, 1 s kalit kadr, Wi-Fi/LAN ga qarab bitreyt),
kompyuterni uxlamaydigan qiladi va har 30 s da Wi-Fi hamda konteynerlarni tekshirib turadi.

## Tuzilma
- `bin/apteka360-edge` — oyna (zenity), `bin/apteka360-edge-setup` — o'rnatish/tiklash (root), `bin/apteka360-edge-watch` — kuzatuvchi
- `stack/` — Docker compose (MediaMTX, agent, tunnel, Edge-AI), `tools/camtune.py` — kamera sozlash (ISAPI)

Sirlar repoda yo'q: filial kaliti login orqali `GET /v1/edges/key` dan olinadi va faqat `/opt/apteka360-edge/stack/edge-agent/edge_agent.ini` (640) ga yoziladi.
