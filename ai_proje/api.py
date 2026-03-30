from flask import Flask, request, jsonify
from flask_cors import CORS
import tensorflow as tf
import numpy as np
import matplotlib
matplotlib.use('Agg') 
import matplotlib.pyplot as plt
import os
import time

app = Flask(__name__)
CORS(app)

print("⏳ V4 Model yükleniyor...")
MODEL_YOLU = 'cocuk_analiz_modeli_v4.h5'
model = None

if os.path.exists(MODEL_YOLU):
    try:
        model = tf.keras.models.load_model(MODEL_YOLU)
        SINIFLAR = ['bagimli', 'gece_kusu', 'ideal', 'sosyal_medya']
        print(" V4 Model Başarıyla Yüklendi! Sistem Hazır.")
    except Exception as e:
        print(f" MODEL HATASI: {e}")
        print("Lütfen 'python train_v4.py' kodunu çalıştırıp modeli eğit.")
else:
    print(f"HATA: '{MODEL_YOLU}' dosyası bulunamadı.")


def rapor_olustur(sinif, oyun_yuzde, egitim_yuzde, sosyal_yuzde, toplam_dk, uyku_ihlali):
    

    risk_puani = 0
    if toplam_dk > 180: risk_puani += 20
    if oyun_yuzde > 40: risk_puani += 30
    if sosyal_yuzde > 50: risk_puani += 20
    if uyku_ihlali > 15: risk_puani += 40 
    if egitim_yuzde > 40: risk_puani -= 20
    

    risk_puani = max(0, min(100, risk_puani))
    
    baslik = ""
    detay = ""
    oneri = ""

    if sinif == 'bagimli':
        
        if uyku_ihlali > 15:
            baslik = f"⚠️ TESPİT: BAĞIMLI & GECE KUŞU (Risk: {risk_puani})"
            detay = f"Çok Kritik: Hem aşırı kullanım (%{int(oyun_yuzde)} Oyun) hem de gece uykusuzluk ({uyku_ihlali} dk) tespit edildi."
            oneri = "👉 Öneri: ACİL 'Dijital Detoks' ve uyku düzenlemesi şart!"
        else:
            baslik = f"⚠️ TESPİT: OYUN BAĞIMLILIĞI (Risk: {risk_puani})"
            detay = f"Toplam sürenin %{int(oyun_yuzde)}'si oyun! Günlük kullanım limiti aşılmış."
            oneri = "👉 Öneri: Günlük süre kısıtlaması (Max 1 saat) getirilmeli."
        
    elif sinif == 'gece_kusu':
        baslik = f"🌙 TESPİT: GECE KUŞU (Uyku Riski)"
        detay = f"Gündüz kullanımı normal ama gece 02:00-06:00 arası {uyku_ihlali} dk aktiflik var."
        oneri = "👉 Öneri: Telefonu yatak odasından çıkarın, biyolojik saati düzeltin."
        
    elif sinif == 'ideal':
        baslik = f"✅ TESPİT: İDEAL KULLANIM"
        detay = f"Eğitim odaklı (%{int(egitim_yuzde)}) ve dengeli profil."
        oneri = "👉 Öneri: Bu düzeni koruyun."
        
    elif sinif == 'sosyal_medya':
        baslik = f"📱 TESPİT: SOSYAL MEDYA"
        detay = f"Kullanımın %{int(sosyal_yuzde)}'si sosyal medya. Dikkat dağınıklığı riski."
        oneri = "👉 Öneri: Sürekli kaydırma yerine hobilere yönlendirilmeli."


    return f"{baslik}\n\n📊 İstatistikler:\n• Toplam: {toplam_dk} dk\n• Oyun: %{int(oyun_yuzde)} | Sosyal: %{int(sosyal_yuzde)} | Eğitim: %{int(egitim_yuzde)}\n\n💡 Analiz:\n{detay}\n\n{oneri}"


def renkli_grafik_olustur(saatlik_veriler, kategoriler):
    plt.close('all') 
    plt.figure(figsize=(2, 2))
    
    renk_map = {0: 'red', 1: 'green', 2: 'blue', 3: 'gray'}
 
    cubuk_renkleri = [renk_map.get(k, 'gray') for k in (kategoriler or [])]
    
    plt.bar(range(24), saatlik_veriler, color=cubuk_renkleri, width=1.0)
    plt.ylim(0, 120) 
    plt.axis('off')
    

    yol = f"gecici_{int(time.time())}.png"
    plt.savefig(yol, bbox_inches='tight', pad_inches=0)
    plt.close('all')
    return yol


@app.route('/analiz-et', methods=['POST'])
def analiz_et():
    resim_yolu = None
    try:
        json_gelen = request.get_json()
        if not json_gelen: return jsonify({'hata': 'Veri yok'}), 400

        saatlik_kullanim = json_gelen.get('veriler', [0]*24)
        kategoriler = json_gelen.get('kategoriler', [0]*24)
        
   
        toplam_dk = sum(saatlik_kullanim)
        
        egitim_suresi = 0
        oyun_suresi = 0
        sosyal_suresi = 0
        
        for i in range(24):
            if kategoriler[i] == 1: egitim_suresi += saatlik_kullanim[i]
            elif kategoriler[i] == 0: oyun_suresi += saatlik_kullanim[i]
            elif kategoriler[i] == 2: sosyal_suresi += saatlik_kullanim[i]

        uyku_ihlali = sum(saatlik_kullanim[2:6]) 

        if toplam_dk > 0:
            oyun_yuzde = (oyun_suresi / toplam_dk) * 100
            egitim_yuzde = (egitim_suresi / toplam_dk) * 100
            sosyal_yuzde = (sosyal_suresi / toplam_dk) * 100
        else:
            oyun_yuzde, egitim_yuzde, sosyal_yuzde = 0, 0, 0


        resim_yolu = renkli_grafik_olustur(saatlik_kullanim, kategoriler)
        sonuc_sinif = "ideal"
        guven = 0.0
        
        if model:
            img = tf.keras.utils.load_img(resim_yolu, target_size=(96, 96))
            img_array = tf.expand_dims(tf.keras.utils.img_to_array(img) / 255.0, 0)
            tahminler = model.predict(img_array)
            kazanan_index = np.argmax(tahminler[0])
            sonuc_sinif = SINIFLAR[kazanan_index]
            guven = float(100 * np.max(tahminler[0]))


        print(f"🤖 AI: {sonuc_sinif} | Toplam: {toplam_dk}dk | Oyun: %{oyun_yuzde:.1f} | Gece: {uyku_ihlali}dk")

  
        if toplam_dk > 210 and oyun_yuzde > 40:
            sonuc_sinif = 'bagimli'
            guven = 99.9
            print("👉 KURAL: Ağır kullanım -> Bağımlı")

        elif uyku_ihlali > 15:
            sonuc_sinif = 'gece_kusu'
            guven = 98.0
            print("👉 KURAL: Gece aktivitesi -> Gece Kuşu")


        elif sosyal_yuzde > 40:
            sonuc_sinif = 'sosyal_medya'
            guven = 96.0


        elif sonuc_sinif == 'ideal':
            if egitim_yuzde < 15 and toplam_dk > 60:
                sonuc_sinif = 'bagimli' if oyun_yuzde > sosyal_yuzde else 'sosyal_medya'


        mesaj = rapor_olustur(sonuc_sinif, oyun_yuzde, egitim_yuzde, sosyal_yuzde, toplam_dk, uyku_ihlali)
        
 
        if resim_yolu and os.path.exists(resim_yolu): os.remove(resim_yolu)

        return jsonify({
            'durum': sonuc_sinif, 
            'guven': f"%{guven:.1f}", 
            'mesaj': mesaj
        })

    except Exception as e:
        print(f"❌ KRİTİK HATA: {e}")
        if resim_yolu and os.path.exists(resim_yolu): os.remove(resim_yolu)
        return jsonify({'hata': str(e)}), 500

if __name__ == '__main__':

    app.run(host='0.0.0.0', port=5000, debug=True)