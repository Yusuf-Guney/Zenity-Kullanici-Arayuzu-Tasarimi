#!/bin/bash

# GEREKLİ CSV DOSYALARINI TANIMLA
PRODUCTS_FILE="depo.csv"
USERS_FILE="kullanici.csv"
LOG_FILE="log.csv"
LOCKED_USERS_FILE="kilitli_kullanicilar.csv"

source ./user_authentication.sh

# ZENITY BOYUTLANDIRMA FONKSIYONU
zenity_with_size() {
    zenity "$@" --width=800 --height=600
}

# CSV DOSYALARI MEVCUT MU KONTROL ET
Dosya_kontrolu() {
  for file in "$PRODUCTS_FILE" "$USERS_FILE" "$LOG_FILE" "$LOCKED_USERS_FILE"; do
    if [ ! -f "$file" ]; then
      touch "$file"
      echo "INFO: $file created."

      # BAŞLIKLAR EKLENİYOR
      if [ "$file" == "$USERS_FILE" ]; then
        echo "ID,Kullanıcı Adı,Adı,Soyadı,Rol,En Sevdiği Renk,Şifre Hash" > "$file"
      fi
    fi
  done
}

# BLOKLU KULLANICILARI LİSTELE
bloklu_kullanici_listele() {
  if [ ! -s "$LOCKED_USERS_FILE" ]; then
    zenity_with_size --info --text="Bloklanmış kullanıcı yok."
    return
  fi

  local content=$(cat "$LOCKED_USERS_FILE")
  zenity_with_size --text-info --title="Bloklu Kullanıcılar" --text="Bloklu kullanıcılar listesi:" --filename=<(echo "$content")
}

# BLOKLANMIŞ KULLANICININ BLOĞUNU KALDIRARN FONKSİYON 
blok_kaldir() {
  local username=$(zenity_with_size --entry --title="Kullanıcı Bloğunu Kaldır" --text="Bloktan kaldırılacak kullanıcı adını girin:")
  if [ -z "$username" ]; then
    zenity_with_size --error --text="Kullanıcı adı boş bırakılamaz."
    return
  fi

  if ! grep -q "^$username$" "$LOCKED_USERS_FILE"; then
    zenity_with_size --error --text="Bu kullanıcı bloklu değil."
    return
  fi

  sed -i "/^$username$/d" "$LOCKED_USERS_FILE"
  zenity_with_size --info --text="Kullanıcı başarıyla bloktan kaldırıldı."
}

# ÜrÜN EKLE
urun_ekle() {
  local result=$(zenity_with_size --forms --title="Ürün Ekle" --text="Yeni Ürün Bilgilerini Girin:" \
    --add-entry="Ürün Adı" \
    --add-entry="Stok Miktarı" \
    --add-entry="Birim Fiyatı" \
    --add-entry="Kategori")

  if [ -z "$result" ]; then
    zenity_with_size --error --text="Bilgi girişi iptal edildi."
    return
  fi

  local name=$(echo "$result" | cut -d '|' -f 1)
  local stock=$(echo "$result" | cut -d '|' -f 2)
  local price=$(echo "$result" | cut -d '|' -f 3)
  local category=$(echo "$result" | cut -d '|' -f 4)

  if [[ ! "$stock" =~ ^[0-9]+$ || ! "$price" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    zenity_with_size --error --text="Stok miktarı ve fiyat pozitif sayı olmalıdır."
    return
  fi

  # AYNI ÜRÜN ADINI KONTROL ETME
  if grep -q "^.*,${name}," "$PRODUCTS_FILE"; then
    zenity_with_size --error --text="Bu ürün adıyla başka bir kayıt bulunmaktadır. Lütfen farklı bir ad giriniz."
    echo "$(date),HATA: Bu ürün adıyla başka bir kayıt bulunmaktadır: $name" >> log.csv
    return
  fi

  local id=$(($(wc -l < "$PRODUCTS_FILE") + 1))
  echo "$id,$name,$stock,$price,$category" >> "$PRODUCTS_FILE"
  zenity_with_size --info --text="Ürün başarıyla eklendi."
}

# ÜRÜNLERİ LİSTELE
urun_listele() {
  if [ ! -s "$PRODUCTS_FILE" ]; then
    zenity_with_size --warning --text="Hiç ürün bulunmamaktadır."
    return
  fi

  local content=$(cat "$PRODUCTS_FILE")
  zenity_with_size --text-info --title="Ürün Listesi" --filename=<(echo "$content")
}

# ÜRÜN GÜNCELLE
urun_guncelle() {
  if [ ! -s "$PRODUCTS_FILE" ]; then
    zenity_with_size --warning --text="Hiç ürün bulunmamaktadır."
    return
  fi

  local name=$(zenity_with_size --entry --title="Ürün Güncelle" --text="Güncellenecek ürünün adını girin:")
  if [ -z "$name" ]; then
    zenity_with_size --error --text="Ürün adı girilmedi."
    return
  fi

  local line=$(grep -i "^.*,$name,.*$" "$PRODUCTS_FILE")
  if [ -z "$line" ]; then
    zenity_with_size --error --text="Ürün bulunamadı."
    return
  fi

  local new_stock=$(zenity_with_size --entry --title="Stok Güncelle" --text="Yeni stok miktarını girin:")
  local new_price=$(zenity_with_size --entry --title="Fiyat Güncelle" --text="Yeni fiyatı girin:")

  if [[ ! "$new_stock" =~ ^[0-9]+$ || ! "$new_price" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    zenity_with_size --error --text="Stok ve fiyat pozitif sayı olmalıdır."
    return
  fi

  local id=$(echo "$line" | cut -d ',' -f 1)
  local category=$(echo "$line" | cut -d ',' -f 5)
  sed -i "/^$id,$name,.*$/d" "$PRODUCTS_FILE"
  echo "$id,$name,$new_stock,$new_price,$category" >> "$PRODUCTS_FILE"
  zenity_with_size --info --text="Ürün başarıyla güncellendi."
}

# ÜRÜN SİL
urun_sil() {
  if [ ! -f "$PRODUCTS_FILE" ] || [ ! -s "$PRODUCTS_FILE" ]; then
    zenity_with_size --warning --text="HİÇ ÜRÜN BULUNMAMAKTADIR."
    return
  fi

  local name=$(zenity_with_size --entry --title="ÜRÜN SİL" --text="SİLİNECEK ÜRÜNÜN ADINI GİRİN:")
  if [ -z "$name" ]; then
    zenity_with_size --error --text="ÜRÜN ADI GİRİLMEDİ."
    return
  fi

  local line=$(grep -i "^.*,$name,.*$" "$PRODUCTS_FILE")
  if [ -z "$line" ]; then
    zenity_with_size --error --text="ÜRÜN BULUNAMADI."
    return
  fi

  zenity_with_size --question --text="BU ÜRÜNÜ SİLMEK İSTEDİĞİNİZE EMİN MİSİNİZ?\n\n$name"
  if [ $? -eq 0 ]; then
    cp "$PRODUCTS_FILE" "${PRODUCTS_FILE}.bak"
    sed -i "/^.*,$name,.*$/Id" "$PRODUCTS_FILE"
    zenity_with_size --info --text="ÜRÜN BAŞARIYLA SİLİNDİ. (YEDEK ALINDI: ${PRODUCTS_FILE}.bak)"
  fi
}


# KULLANICI EKLE
kullanici_ekle() {
  local result=$(zenity_with_size --forms --title="Yeni Kullanıcı" --text="Kullanıcı bilgilerini girin:" \
    --add-entry="Adı" \
    --add-entry="Soyadı" \
    --add-entry="Rol (Yönetici/Kullanıcı)" \
    --add-password="Şifre")

  if [ -z "$result" ]; then
    zenity_with_size --error --text="Bilgi girişi iptal edildi."
    return
  fi

  local name=$(echo "$result" | cut -d '|' -f 1)
  local surname=$(echo "$result" | cut -d '|' -f 2)
  local role=$(echo "$result" | cut -d '|' -f 3)
  local password=$(echo "$result" | cut -d '|' -f 4)

  if [[ "$role" != "Yönetici" && "$role" != "Kullanıcı" ]]; then
    zenity_with_size --error --text="Geçersiz rol. Sadece Yönetici veya Kullanıcı olabilir."
    return
  fi

  local id=$(($(wc -l < "$USERS_FILE") + 1))
  local hashed_password=$(echo -n "$password" | md5sum | cut -d ' ' -f 1)
  echo "$id,$name,$surname,$role,$hashed_password" >> "$USERS_FILE"
  zenity_with_size --info --text="Kullanıcı başarıyla eklendi."
}

# KULLANICI LİSTELE
kullanici_listele() {
  if [ ! -s "$USERS_FILE" ]; then
    zenity_with_size --warning --text="Hiç kullanıcı bulunmamaktadır."
    return
  fi

  local content=$(cat "$USERS_FILE")
  zenity_with_size --text-info --title="Kullanıcı Listesi" --filename=<(echo "$content")
}

# KULLANICI SİL
kullanici_sil() {
  if [ ! -s "$USERS_FILE" ]; then
    zenity_with_size --warning --text="Hiç kullanıcı bulunmamaktadır."
    return
  fi

  local name=$(zenity_with_size --entry --title="Kullanıcı Sil" --text="Silinecek kullanıcının adını girin:")
  if [ -z "$name" ]; then
    zenity_with_size --error --text="Kullanıcı adı girilmedi."
    return
  fi

  local line=$(grep -i "^.*,$name,.*$" "$USERS_FILE")
  if [ -z "$line" ]; then
    zenity_with_size --error --text="Kullanıcı bulunamadı."
    return
  fi

  zenity_with_size --question --text="Bu kullanıcıyı silmek istediğinize emin misiniz?"
  if [ $? -eq 0 ]; then
    sed -i "/^.*,$name,.*$/d" "$USERS_FILE"
    zenity_with_size --info --text="Kullanıcı başarıyla silindi."
  fi
}

# ANA MENÜ
main() {
  while true; do
    local choice=$(zenity_with_size --list --title="Envanter Yönetim Sistemi" --text="Bir işlem seçin:" \
      --column="İşlem" --height=400 --width=500 \
      "Ürün Ekle" "Ürün Listele" "Ürün Güncelle" "Ürün Sil"  \
      "Kullanıcı Ekle" "Kullanıcı Listele" "Kullanıcı Sil" "Bloklu Kullanıcıları Listele" "Kullanıcı Bloğunu Kaldır" "Çıkış")

    case "$choice" in
      "Ürün Ekle")
        urun_ekle
        ;;
      "Ürün Listele")
        urun_listele
        ;;
      "Ürün Güncelle")
        urun_guncelle
        ;;
      "Ürün Sil")
        urun_sil
        ;;
      "Kullanıcı Ekle")
        kullanici_ekle
        ;;
      "Kullanıcı Listele")
        kullanici_listele
        ;;
      "Kullanıcı Sil")
        kullanici_sil
        ;;
      "Kullanıcı Bloğunu Kaldır")
  	blok_kaldir
 	;;
      "Bloklu Kullanıcıları Listele")
  	bloklu_kullanici_listele
  	;;

      "Çıkış")
        zenity_with_size --question --text="Çıkmak istediğinize emin misiniz?"
        if [ $? -eq 0 ]; then
          break
        fi
        ;;
      *)
        zenity_with_size --error --text="Geçersiz seçim."
        ;;
    esac
  done
}

# DOSYA KONTROLÜ VE MENÜ ÇAĞRISI
giris_ekrani
Dosya_kontrolu
main

