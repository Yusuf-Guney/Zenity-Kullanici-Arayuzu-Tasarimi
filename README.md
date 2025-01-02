# Kullanıcı ve Envanter Yönetim Sistemi

Bu proje, Zenity kullanılarak geliştirilmiş kapsamılı bir **Kullanıcı ve Envanter Yönetim Sistemi**dir. Kullanıcıların giriş yapabileceği, yeni kayıt oluşturabileceği, şifre sıfırlayabileceği ve envanter yönetimi yapabileceği bir sistem sunar. Özellikle blokeli hesap yönetimi ve güvenlik doğrulamaları ile sistemin güvenliği ön plandadır.

---

## **Özellikler**

### **Kullanıcı Yönetimi**
- **Kullanıcı Girişi**: Kullanıcı adı ve şifre ile güvenli giriş.
- **Yeni Kullanıcı Kaydı**: Yeni bir kullanıcı oluşturma.
- **Şifre Sıfırlama**: Güvenlik sorusu doğrulamasıyla şifre yenileme.
- **Blokeli Hesap Yönetimi**:
  - 3 hatalı girişten sonra hesap kilitlenir.
  - Bloklu kullanıcıları listeleme ve blok kaldırma.

### **Envanter Yönetimi**
- **Ürün Ekle**: Envantere yeni ürün eklenir.
- **Ürün Listele**: Mevcut ürünlerin listesi görüntülenir.
- **Ürün Güncelle**: Envanterdeki bir ürünün bilgileri (stok, fiyat) güncellenir.
- **Ürün Sil**: Belirtilen bir ürün envanterden kaldırılır.
- **Stok Analizi**:
  - Kritik stok seviyesindeki ürünleri raporlama.
  - Maksimum stoklu ürünleri listeleme.

### **Loglama ve Raporlama**
- **Hata Loglama**: Hatalı girişler `log.csv` dosyasında saklanır.
- **Raporlama**:
  - Belirli tarih aralıklarında envanter hareketleri.
  - Blokeli hesaplar listesi.

---

## **Nasıl Kurulur?**

1. Projeyi GitHub'dan klonlayın:
    ```bash
    git clone https://github.com/kullanici/ProjeAdi.git
    cd ProjeAdi
    ```

2. Script dosyalarını çalıştırılabilir yapın:
    ```bash
    chmod +x ana_script.sh user_authentication.sh
    ```

3. Sistemi başlatın:
    ```bash
    ./ana_script.sh
    ```

---

## **Kullanım Talimatları**

### **1. Giriş Ekranı**
Sistem başlatıldığında ilk olarak giriş ekranıyla karşılaşırsınız:

![Giriş Ekranı](images/giris_ekrani.png)

- **Giriş Yap**: Kullanıcı adı ve şire ile giriş yapabilirsiniz.
- **Kırat Ol**: Yeni bir kullanıcı oluşturabilirsiniz.
- **Şifre Sıfırla**: Güvenlik sorusuyla şifrenizi sıfırlayabilirsiniz.

---

### **2. Envanter Yönetim Menüsü**
Giriş başarılı olduğunda envanter yönetimi ana menüsü karşınıza gelir:

![Envanter Menüsü](images/envanter_menusu.png)

#### **İşlemler**:
- Ürün ekleme, listeleme, güncelleme ve silme.
- Stok analiz raporları.

---

### **3. Kullanıcı Yönetimi**
Yönetici olarak giriş yaptığınızda kullanıcı yönetim işlemlerine erişim sağlayabilirsiniz:

![Kullanıcı Yönetimi](images/kullanici_yonetimi.png)

#### Özellikler:
- Kullanıcı ekleme, listeleme, güncelleme ve silme.
- Bloklu kullanıcıları listeleme ve blok kaldırma.

---

### **4. Şifre Sıfırlama**
Giriş ekranındaki "Şifre Sıfırla" seçeneğiyle şunlar yapılabilir:

![Şifre Sıfırlama](images/sifre_sifirlama.png)

1. Kullanıcı adı girilir.
2. Güvenlik sorusu doğrulanır.
3. Yeni bir şire belirlenir.

---

## **Proje Yapısı**

```
ProjeAdi/
├── ana_script.sh          # Ana menü ve sistem dosyaları
├── user_authentication.sh # Kullanıcı girişi ve şifre sıfırlama
├── depo.csv               # Ürün bilgileri
├── kullanici.csv          # Kullanıcı bilgileri
├── log.csv                # Sistem logları
├── kilitli_kullanicilar.csv # Kilitli kullanıcılar
├── images/                # Ekran görüntüleri
├── README.md              # Proje dokümanı
```

---

## **Ekran Görüntüleri**

1. **Giriş Ekranı**:
   ![Giriş Ekranı](images/giris_ekrani.png)

2. **Envanter Menüsü**:
   ![Envanter Menüsü](images/envanter_menusu.png)

3. **Kullanıcı Yönetimi**:
   ![Kullanıcı Yönetimi](images/kullanici_yonetimi.png)

4. **Şifre Sıfırlama**:
   ![Şifre Sıfırlama](images/sifre_sifirlama.png)

---

## **Video Tanıtım**

Projenin nasıl kullanıldığını anlatan videoya aşağıdaki linkten ulaşabilirsiniz:

[Proje Tanıtım Videosu](https://example.com/video)

---

## **Katkıda Bulunma**

1. Bu projeyi forklayın.
2. Yeni bir dal oluşturun:
    ```bash
    git checkout -b yeni-ozellik
    ```
3. Değişikliklerinizi yapıp commit edin:
    ```bash
    git commit -m "Yeni özellik eklendi"
    ```
4. Dalınızı push edin:
    ```bash
    git push origin yeni-ozellik
    ```
5. Bir Pull Request oluşturun.

---

## **Lisans**

Bu proje MIT Lisansı ile lisanslanmıştır. Daha fazla bilgi için `LICENSE` dosyasına bakabilirsiniz.
