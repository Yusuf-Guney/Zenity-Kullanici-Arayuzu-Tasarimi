#!/bin/bash

# GEREKLİ CSV DOSYALARINI TANIMLA
USERS_FILE="kullanici.csv"
LOG_FILE="log.csv"
LOCKED_USERS_FILE="kilitli_kullanicilar.csv"

zenity_with_size() {
    zenity "$@" --width=800 --height=600
}

# CSV DOSYALARI MEVCUT MU KONTROL ET
Dosya_kontrolu() {
  for file in "$USERS_FILE" "$LOG_FILE" "$LOCKED_USERS_FILE"; do
    if [ ! -f "$file" ]; then
      touch "$file"
      echo "INFO: $file created."
    fi
  done
}

# KULLANICI GİRİŞİ
giris_yap() {
  local username=$(zenity_with_size --entry --title="Kullanıcı Girişi" --text="Kullanıcı adınızı girin:")
  local password=$(zenity_with_size --password --title="Şifre")

  if [ -z "$username" ] || [ -z "$password" ]; then
    zenity_with_size --error --text="Kullanıcı adı ve şifre boş bırakılamaz."
    return 1
  fi

  if grep -q "$username" "$LOCKED_USERS_FILE"; then
    zenity_with_size --error --text="Hesabınız kilitlenmiştir. Lütfen yöneticiyle iletişime geçin."
    return 1
  fi

  local hashed_password=$(echo -n "$password" | md5sum | cut -d ' ' -f 1)
  local line=$(grep -i "^.*,$username,.*,$hashed_password$" "$USERS_FILE")

  if [ -z "$line" ]; then
    echo "$username,FAILED,$(date)" >> "$LOG_FILE"
    local attempts=$(grep -c "$username,FAILED" "$LOG_FILE")
    if [ $attempts -ge 3 ]; then
      echo "$username" >> "$LOCKED_USERS_FILE"
      zenity_with_size --error --text="Hesabınız 3 hatalı giriş nedeniyle kilitlenmiştir."
      return 1
    fi
    zenity_with_size --error --text="Hatalı kullanıcı adı veya şifre."
    return 1
  fi

  zenity_with_size --info --text="Giriş başarılı. Hoş geldiniz, $username."
  return 0
}
#KAYIT OL
kayit_ol() {
  local result=$(zenity_with_size --forms --title="Kayıt Ol" --text="Yeni Kullanıcı Bilgilerini Girin:" \
    --add-entry="Adı" \
    --add-entry="Soyadı" \
    --add-entry="Kullanıcı Adı" \
    --add-entry="Rol (Yönetici/Kullanıcı)" \
    --add-entry="En Sevdiğiniz Renk" \
    --add-password="Şifre")

  if [ -z "$result" ]; then
    zenity_with_size --error --text="Bilgi girişi iptal edildi."
    return
  fi

  local name=$(echo "$result" | cut -d '|' -f 1)
  local surname=$(echo "$result" | cut -d '|' -f 2)
  local username=$(echo "$result" | cut -d '|' -f 3)
  local role=$(echo "$result" | cut -d '|' -f 4)
  local favorite_color=$(echo "$result" | cut -d '|' -f 5)
  local password=$(echo "$result" | cut -d '|' -f 6)

  if [[ "$role" != "Yönetici" && "$role" != "Kullanıcı" ]]; then
    zenity_with_size --error --text="Geçersiz rol. Sadece Yönetici veya Kullanıcı olabilir."
    return
  fi

  local id=$(($(wc -l < "$USERS_FILE") + 1))
  local hashed_password=$(echo -n "$password" | md5sum | cut -d ' ' -f 1)
  echo "$id,$username,$name,$surname,$role,$favorite_color,$hashed_password" >> "$USERS_FILE"
  zenity_with_size --info --text="Kullanıcı başarıyla kaydedildi."
}


# KİLİTLİ HESABI AÇ
unlock_user() {
  local username=$(zenity_with_size --entry --title="Kilitli Hesap Aç" --text="Kilitli hesabın kullanıcı adını girin:")
  if [ -z "$username" ]; then
    zenity_with_size --error --text="Kullanıcı adı boş bırakılamaz."
    return
  fi

  if ! grep -q "$username" "$LOCKED_USERS_FILE"; then
    zenity_with_size --error --text="Bu kullanıcı kilitli değil."
    return
  fi

  sed -i "/$username/d" "$LOCKED_USERS_FILE"
  zenity_with_size --info --text="Hesap başarıyla açıldı."
}


sifre_resetle() {
  local username=$(zenity_with_size --entry --title="Şifre Sıfırlama" --text="Kullanıcı adınızı girin:")
  if [ -z "$username" ]; then
    zenity_with_size --error --text="Kullanıcı adı boş bırakılamaz."
    return
  fi

  local line=$(grep -i "^.*,$username,.*$" "$USERS_FILE")
  if [ -z "$line" ]; then
    zenity_with_size --error --text="Kullanıcı bulunamadı."
    return
  fi

  local stored_color=$(echo "$line" | cut -d ',' -f 6)
  local entered_color=$(zenity_with_size --entry --title="Güvenlik Sorusu" --text="En sevdiğiniz renk nedir?")

  if [ "$stored_color" != "$entered_color" ]; then
    zenity_with_size --error --text="Güvenlik sorusu cevabı yanlış."
    return
  fi

  local new_password=$(zenity --password --title="Yeni Şifre" --text="Yeni şifrenizi girin:")
  if [ -z "$new_password" ]; then
    zenity_with_size --error --text="Şifre boş bırakılamaz."
    return
  fi

  local hashed_password=$(echo -n "$new_password" | md5sum | cut -d ' ' -f 1)
  local updated_line=$(echo "$line" | sed "s/[^,]*$/$(echo $hashed_password)/")
  sed -i "/^.*,$username,.*$/d" "$USERS_FILE"
  echo "$updated_line" >> "$USERS_FILE"

  zenity_with_size --info --text="Şifre başarıyla güncellendi."
}

	
# GİRİŞ EKRANI
giris_ekrani() {
  while true; do
    local choice=$(zenity_with_size --list --title="Hoş Geldiniz" --text="Bir işlem seçin:" \
      --column="Seçenek" \
      "Giriş Yap" "Kayıt Ol" "Şifre Sıfırla" "Çıkış" )

    case "$choice" in
      "Giriş Yap")
        giris_yap
        if [ $? -eq 0 ]; then
          break 
        fi
        ;;
      "Kayıt Ol")
        kayit_ol
        ;;
      "Şifre Sıfırla")
  	sifre_resetle
  	;;
      "Çıkış")
        exit 0
        ;;
      *)
        zenity_with_size --error --text="Geçersiz seçim."
        ;;
    esac
  done
}

# DOSYA KONTROLÜ VE BAŞLATMA
Dosya_kontrolu

