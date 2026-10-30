"""Filial kameralarini (Hikvision ISAPI) Edge uchun moslaydi: H.265 → H.264, GOP 1 s, fps va bitreyt chegarasi.
Agent konteyneri ichida ishlaydi; kamera parollari MediaMTX yo'l manbasidan olinadi, hech qayerga yozilmaydi.
  python3 camtune.py wifi|lan
"""
import json, re, sys, urllib.request as U, urllib.parse as P

PROFILES = {  # kanal: (fps*100, VBR chegarasi kbit/s, GOP kadr)
    "wifi": {"101": (1200, 1024, 12), "102": (1200, 256, 12)},
    "lan": {"101": (1500, 2048, 15), "102": (1500, 512, 15)},
}
target = PROFILES.get(sys.argv[1] if len(sys.argv) > 1 else "wifi", PROFILES["wifi"])
paths = json.load(U.urlopen("http://127.0.0.1:9997/v3/config/paths/list?itemsPerPage=200"))["items"]
for p in sorted(paths, key=lambda x: x["name"]):
    if not p["name"].endswith("-sub"):
        continue
    u = P.urlparse(p.get("source") or "")
    if not u.hostname or not u.password:
        continue
    pm = U.HTTPPasswordMgrWithDefaultRealm()
    pm.add_password(None, "http://%s/" % u.hostname, P.unquote(u.username or ""), P.unquote(u.password))
    op = U.build_opener(U.HTTPDigestAuthHandler(pm))
    for ch, (fps, cap, gop) in target.items():
        url = "http://%s/ISAPI/Streaming/channels/%s" % (u.hostname, ch)
        for attempt in range(3):
            try:
                x = op.open(url, timeout=15).read().decode()
                y = x.replace("<videoCodecType>H.265</videoCodecType>", "<videoCodecType>H.264</videoCodecType>")
                y = re.sub(r"<H265Profile>[^<]*</H265Profile>", "", y)
                y = re.sub(r"<maxFrameRate>\d+<", "<maxFrameRate>%d<" % fps, y)
                y = re.sub(r"<vbrUpperCap>\d+<", "<vbrUpperCap>%d<" % cap, y)
                y = re.sub(r"<constantBitRate>\d+<", "<constantBitRate>%d<" % cap, y)
                y = re.sub(r"<GovLength>\d+<", "<GovLength>%d<" % gop, y)
                if y == x:
                    print(p["name"][:-4], ch, "ok")
                    break
                r = op.open(U.Request(url, data=y.encode(), method="PUT", headers={"Content-Type": "application/xml"}), timeout=20).read().decode()
                print(p["name"][:-4], ch, (re.search(r"<statusString>([^<]*)<", r) or [None, "?"])[1])
                break
            except Exception as e:  # noqa: BLE001 — Wi-Fi kamera javob bermay qolishi mumkin
                if attempt == 2:
                    print(p["name"][:-4], ch, "xato:", e)
