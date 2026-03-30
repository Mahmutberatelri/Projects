import matplotlib.pyplot as plt
import numpy as np
import random
import os
import shutil

# --- AYARLAR ---
ANA_KLASOR = 'egitim_verileri_v4'
# Sınıflar yine aynı kalmalı ki Uygulama (Flutter) bozulmasın.
# Ama klasörlerin İÇERİĞİ çok zengin olacak.
SINIFLAR = ['bagimli', 'ideal', 'gece_kusu', 'sosyal_medya'] 
VERI_SAYISI = 1000 # Her sınıftan 1000 tane (Toplam 4000 resim! - Çok iyi öğrenir)

# Klasörü temizle
if os.path.exists(ANA_KLASOR):
    shutil.rmtree(ANA_KLASOR)
os.makedirs(ANA_KLASOR)
for sinif in SINIFLAR:
    os.makedirs(os.path.join(ANA_KLASOR, sinif))

def grafik_uret(dosya_adi, profil_tipi):
    saatler = np.arange(24)
    renkler = [] 
    kullanim = []

    # --- KOMBİNASYONLU SENARYOLAR ---

    if profil_tipi == "ideal":
        # Senaryo 1: Sadece Ders Çalışan (Klasik İnek Öğrenci)
        # Senaryo 2: Ders + Biraz Oyun (Dengeli Öğrenci) -> MODEL BUNU ÖĞRENMELİ
        # Senaryo 3: Ders + Biraz Sosyal (Normal Genç)
        
        alt_tur = random.choice(['sadece_ders', 'ders_oyun', 'ders_sosyal'])
        
        for s in saatler:
            val = 0
            renk = 'gray'
            
            # Ana Ders Saatleri (Ortak)
            if 14 <= s <= 17: 
                val = random.randint(60, 90)
                renk = 'green' # DERS
            
            # Yan Aktiviteler
            elif alt_tur == 'ders_oyun' and (20 <= s <= 21):
                val = random.randint(30, 50) # Makul seviye oyun
                renk = 'red'
            elif alt_tur == 'ders_sosyal' and (20 <= s <= 22):
                val = random.randint(30, 50)
                renk = 'blue'
            
            kullanim.append(val)
            renkler.append(renk)

    elif profil_tipi == "bagimli":
        # Senaryo 1: Full Oyun (Hardcore)
        # Senaryo 2: Oyun + Azıcık Ders (Anneyi kandırmalık ders) -> YİNE DE BAĞIMLI
        
        alt_tur = random.choice(['full_oyun', 'oyun_ders'])

        for s in saatler:
            val = 0
            renk = 'gray'
            
            if s > 12 and s < 23: # Gün boyu aktivite
                if alt_tur == 'oyun_ders' and s == 15: # Sadece 1 saat ders
                    val = random.randint(30, 50)
                    renk = 'green'
                else: # Geri kalan hep oyun
                    val = random.randint(70, 100)
                    renk = 'red'
            
            kullanim.append(val)
            renkler.append(renk)

    elif profil_tipi == "sosyal_medya":
        # Senaryo 1: Full Sosyal
        # Senaryo 2: Sosyal + Biraz Oyun
        
        for s in saatler:
            val = 0
            renk = 'gray'
            
            if s > 9:
                if random.random() > 0.7: # Ara ara giriyor
                    val = random.randint(20, 60)
                    # Arada kırmızı (oyun) karışsa bile geneli Mavi
                    if random.random() > 0.8: 
                        renk = 'red'
                    else:
                        renk = 'blue'
            
            kullanim.append(val)
            renkler.append(renk)

    elif profil_tipi == "gece_kusu":
        # Gece ne yaparsa yapsın (Oyun, Sosyal, Ders) Gece Kuşudur.
        for s in saatler:
            val = 0
            renk = 'gray'
            
            if 2 <= s <= 5: # Gece Aktivitesi
                val = random.randint(80, 100)
                # Renk rastgele olabilir, önemli olan saat
                renk = random.choice(['red', 'blue', 'green']) 
            elif s > 12:
                if random.random() > 0.8:
                    val = random.randint(20, 50)
                    renk = 'blue'
            
            kullanim.append(val)
            renkler.append(renk)

    # --- ÇİZİM ---
    plt.figure(figsize=(3, 3))
    plt.bar(saatler, kullanim, color=renkler, width=0.9)
    plt.ylim(0, 100)
    plt.axis('off')
    
    kayit_yolu = os.path.join(ANA_KLASOR, profil_tipi, f"{dosya_adi}.png")
    plt.savefig(kayit_yolu, dpi=64, bbox_inches='tight', pad_inches=0)
    plt.close()

print(f"🚀 Genişletilmiş veri seti üretiliyor (4000 Resim)...")
for i in range(VERI_SAYISI):
    for sinif in SINIFLAR:
        grafik_uret(f"img_{i}", sinif)

print("✅ Veri seti hazır: egitim_verileri_v4")
print("👉 Şimdi train_v4.py dosyasını çalıştırıp modeli eğitmelisin!")