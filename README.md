# SQL Injection Crawler ve Tarama Aracı
Bu uygulama, belirli bir hedef URL üzerinde SQL Injection zafiyetlerini tespit etmek için geliştirilmiş bir tarayıcı ve saldırı testi aracıdır. Uygulama, hedef sitede bulunan bağlantıları ve formları tarar, SQL Injection payload'larını GET ve POST parametreleri üzerinde test eder. Ayrıca, time-based SQL Injection saldırıları ile sayfanın yanıt süresini analiz eder ve farklı veritabanı yönetim sistemleri (MySQL, MSSQL, Oracle, PostgreSQL) için hata mesajlarını yakalar.

# Uygulamanın Genel Özellikleri
Hedef URL'deki tüm bağlantıları ve formları tarar.
GET ve POST parametreleri üzerinde SQL Injection payload'larını test eder.
Time-based SQL Injection denemeleri ile 30 saniye gecikmelerini tespit eder.
SQL Injection sırasında oluşan veritabanı hata mesajlarını (MySQL, PostgreSQL, MSSQL, Oracle) yakalar ve raporlar.
Kullanıcıya renkli çıktı verir, başarılı SQL Injection durumlarını yeşil renkle belirtir.
Cloudflare gibi bazı güvenlik duvarlarını bypass etmeye çalışır.
Kullanılan Kütüphaneler

# Bu uygulama Perl dilinde yazılmıştır ve aşağıdaki modülleri kullanır:
LWP::UserAgent: HTTP isteklerini yapmak ve web sayfalarından veri çekmek için kullanılır.
HTTP::Cookies: Çerez yönetimi sağlar, isteklere çerez ekler.
HTML::Form: HTML formlarını parse etmek ve form alanlarını doldurup test etmek için kullanılır.
Time::HiRes: Yüksek çözünürlüklü zaman ölçümleri yapmak için kullanılır (SQL injection sırasında zaman gecikmelerini ölçmek için).
Term::ANSIColor: Komut satırında renkli çıktı almak için kullanılır.
URI: URL manipülasyonları ve mutlak/göreceli URL işlemleri için kullanılır.
Kütüphaneleri Kurma
Gerekli Perl modüllerini kurmak için, CPAN (Comprehensive Perl Archive Network) aracını kullanabilirsiniz. Aşağıdaki komutlarla gerekli modülleri kurabilirsiniz:

cpan install LWP::UserAgent
cpan install HTTP::Cookies
cpan install HTML::Form
cpan install Time::HiRes
cpan install Term::ANSIColor
cpan install URI

# Eğer CPAN'i kullanmak istemiyorsanız, aşağıdaki komutlarla doğrudan gerekli modülleri kurabilirsiniz:
sudo apt install libwww-perl           # LWP::UserAgent ve HTTP modülleri
sudo apt install libhtml-form-perl     # HTML::Form modülü
sudo apt install libterm-ansicolor-perl # Term::ANSIColor modülü

# Kullanım Örnekleri
Başarılı SQL Injection Bulma: Eğer bir SQL Injection açığı tespit edilirse, bu terminalde yeşil renkte belirtilir.
30+ Saniye Gecikme: Time-based SQL Injection testlerinde sayfanın yanıtı 30 saniyeden fazla sürerse, bu da başarılı SQL Injection olarak işaretlenir.
Veritabanı Hata Mesajları: Uygulama, sayfadaki veritabanı hata mesajlarını (MySQL, PostgreSQL, MSSQL, Oracle) yakalar ve sarı renkte çıktılar.

# Özelleştirme
Hedef URL: Uygulamanın hedeflediği URL'yi $target değişkeni ile değiştirebilirsiniz.
Payload'lar: Farklı veritabanı yönetim sistemleri için kullanılacak SQL Injection payload'ları %payloads değişkeninde tanımlıdır. Bu payload'ları değiştirebilir veya yeni payload'lar ekleyebilirsiniz.
