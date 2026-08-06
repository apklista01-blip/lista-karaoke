"""Gera o QR code do link público do aplicativo Karaokê Online."""
import qrcode
from qrcode.constants import ERROR_CORRECT_H

URL = "https://apklista01-blip.github.io/lista-karaoke/"

qr = qrcode.QRCode(
    version=None,
    error_correction=ERROR_CORRECT_H,
    box_size=12,
    border=4,
)
qr.add_data(URL)
qr.make(fit=True)

img = qr.make_image(fill_color="black", back_color="white")
out = "qrcode_lista_karaoke.png"
img.save(out)
print(f"QR code salvo em: {out}")
print(f"URL: {URL}")
