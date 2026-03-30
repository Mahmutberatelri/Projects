import requests
import json

# Sunucu adresi
url = 'http://127.0.0.1:5000/analiz-et'

# SAHTE VERİ (Senaryo: Gece Kuşu)
# Gündüz (Saat 08-20 arası) hiç oynamamış (0)
# Gece (Saat 03:00 ve 04:00) 90'ar dakika oynamış.
veri_listesi = [0] * 24
veri_listesi[3] = 90 
veri_listesi[4] = 90

print(f"📡 İstek şu adrese gönderiliyor: {url}")

try:
    # İsteği gönder
    cevap = requests.post(url, json={'veriler': veri_listesi})
    
    # Gelen cevabı yazdır
    print("\n📩 SUNUCUDAN GELEN CEVAP:")
    print(json.dumps(cevap.json(), indent=4, ensure_ascii=False))

except Exception as e:
    print(f"❌ Hata oluştu: {e}")