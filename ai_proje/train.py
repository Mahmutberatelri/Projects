import tensorflow as tf
from tensorflow.keras import layers, models
import os

# --- AYARLAR ---
# DİKKAT: Yeni ve karmaşık veri setini kullanıyoruz
VERI_KLASORU = 'egitim_verileri_v4' 
IMG_BOYUT = (96, 96) # Çözünürlük
BATCH_SIZE = 32
EPOCHS = 15 # Karmaşık veriyi sindirmesi için ideal tur sayısı

print("1. Karmaşık Veriler (V4) Yükleniyor...")

# Eğitim Seti (%80)
train_ds = tf.keras.utils.image_dataset_from_directory(
    VERI_KLASORU,
    validation_split=0.2,
    subset="training",
    seed=123,
    image_size=IMG_BOYUT,
    batch_size=BATCH_SIZE,
    label_mode='categorical'
)

# Doğrulama Seti (%20)
val_ds = tf.keras.utils.image_dataset_from_directory(
    VERI_KLASORU,
    validation_split=0.2,
    subset="validation",
    seed=123,
    image_size=IMG_BOYUT,
    batch_size=BATCH_SIZE,
    label_mode='categorical'
)

sinif_isimleri = train_ds.class_names
print(f"Tespit Edilecek Sınıflar: {sinif_isimleri}")

# Performans Ayarı (Veriyi RAM'e alıp hızlandırır)
AUTOTUNE = tf.data.AUTOTUNE
train_ds = train_ds.cache().shuffle(1000).prefetch(buffer_size=AUTOTUNE)
val_ds = val_ds.cache().prefetch(buffer_size=AUTOTUNE)

# --- MODEL MİMARİSİ (CNN) ---
model = models.Sequential([
    # Giriş Katmanı ve Normalizasyon (0-1 arasına çekme)
    layers.Rescaling(1./255, input_shape=IMG_BOYUT + (3,)),
    
    # 1. Özellik Çıkarma Bloğu
    layers.Conv2D(32, 3, padding='same', activation='relu'),
    layers.MaxPooling2D(),
    layers.Dropout(0.2), # %20 unut (Ezberi bozmak için)

    # 2. Özellik Çıkarma Bloğu
    layers.Conv2D(64, 3, padding='same', activation='relu'),
    layers.MaxPooling2D(),
    layers.Dropout(0.3), # %30 unut

    # 3. Özellik Çıkarma Bloğu (Detayları Görür)
    layers.Conv2D(128, 3, padding='same', activation='relu'),
    layers.MaxPooling2D(),
    layers.Dropout(0.4), # %40 unut

    # Karar Katmanı (Yapay Sinir Ağı)
    layers.Flatten(),
    layers.Dense(128, activation='relu'),
    layers.Dropout(0.5), # %50 unut (En kritik yer)
    
    # Çıktı Katmanı (4 Sınıf)
    layers.Dense(len(sinif_isimleri), activation='softmax')
])

# Modeli Derle
model.compile(optimizer='adam',
              loss='categorical_crossentropy',
              metrics=['accuracy'])

model.summary()

print("2. Derin Eğitim Başlıyor (V4)...")
history = model.fit(
    train_ds,
    validation_data=val_ds,
    epochs=EPOCHS
)

print("3. Yeni Beyin Kaydediliyor...")
# V4 olarak kaydediyoruz
model.save('cocuk_analiz_modeli_v4.h5') 

print(f"✅ Gelişmiş model hazır: cocuk_analiz_modeli_v4.h5")
print("👉 Şimdi api.py dosyasında model adını 'v4' yaparak kullanabilirsin.")