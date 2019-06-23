
# Enerji Dağıtım Business Network Application

Hyperledger Fabric Network'ü üzerinde çalışabilen basit enerji dağıtım ve takip uygulaması. Amaç, akıllı sayaçlar üzerinden gelen ölçüm verilerinin Hyperledger Fabric üzerinde oluşturulması ve saklanmasıdır.

  
  
  

## Kurulum

Hyperledger Fabric Network düzgün çalışması açısından [linkteki](https://hyperledger-fabric.readthedocs.io/en/release-1.4/prereqs.html) tüm gerekliliklerin sağlanması gereklidir.

  

Şartların sağlandığını görmek ve gerekli bazı araçların kurulması için,

  

> ./prereqs-ubuntu.sh

  

Aşağıdaki araçlar [linteki](https://hyperledger-fabric.readthedocs.io/en/latest/install.html) yerden indirilip kurulmalı ve projenin anadizinine eklenmelidir:

- orderer

- peer

- fabric-ca-server

- fabric-ca-client

- configtxgen

  

Bu araçlara ek olacak şekilde:

  

-  [composer](https://hyperledger.github.io/composer/latest/installing/installing-index.html)

-  [composer-rest-server](https://www.npmjs.com/package/composer-rest-server)

Kurulmalıdır.

  

Araçların kullanımı test edildikten sonra,

  

> ./gen-fabric-ca.sh

  

Gerekli kriptografik materyal oluşacaktır. Kodu detaylı inceleyip, yorum satırlarını takip ederek daha iyi anlaşılabilir.

Dizin şu şekilde olmalıdır:

  

- fabric-ca

- client

- aydem

- admin

- enerjisa

- admin

- orderer

- admin

- kamukurumu

- admin

- caserver

- admin

- server

- msp

- ...

  

Ardından Kanalların([Channel](https://hyperledger-fabric.readthedocs.io/en/release-1.4/channels.html)) ve eşlerin(Peer) oluşturulması için,

> ./start-peers.sh

  

Ağın çalışabilmesi için gerekli ilk blok(Genesis) ve kanalların başlatılabilmesi için gerekli TX dosyaları, Artifacts klasörü içerisinde oluşmalıdır. Kontrol edilmeli.

  

Çalışan işlemler için,

> ps -a

  

Olması gereken:

- peer

- peer

- peer

- orderer

- fabric-ca

  

Ağ kurulumu hatasız gerçekleştiyse artık Business Network Archive dosyamızı ağımızdaki eşlere yüklenebilir.

Business Card oluşturduktan sonra yüklememizi yapabiliriz.

  


>cd ./businessnetworkapp/util

>npm install

>node card-ops.js

>->Generate Peer Admin Cards for Multi Org Profile

  

**./businessnetworkapp/cards** klasörü içerisinde Üç adet kart oluşması gerekmektedir.

  

- Aydem-peer1PeerAdmin.card

- Enerjisa-peer1PeerAdmin.card

- Kamukurumu-peer1PeerAdmin.card


 Üç adet kart oluşması gerekmektedir.


>->node card-ops.js
>->Delete all cards
>->Install/Replace Peer Cards

Eklenmiş business card ögelerini temizliyoruz. Daha sonra da, oluşturduğumuz card ögelerini ekliyoruz.

Hiçbir hata ile karşılaşılmadıysa son olarak,

> cd ./businessnetworkapp/util/

> ./install-bna.sh

  

**businessnetworkapp** klasörü içerisinde bulunan örnek **basic-energy-tracking.bna**(Business Network Archive), Hyperledger Fabric ağımız üzerine başarıyla yüklendi.

  

İki adet **composer-rest-server** çalışmaya başladı:

localhost:3001 -> enerjisa

localhost:3002 -> aydem

  

Browser kullanılarak sayfalara ulaşılabilir ve test edilebilir.

  
  

## İçerik

**basic-energy-tracking.bna** dosyası içerisinde oluşturulan modeller:

- SmartMeter (Participant)

- EnergyUsage (Asset)

- EnergyUsageTransaction (Transaction)

- EnergyUsageEvent (Event)

  

(Dosyanın düzenlemesi için [composer-playground](https://composer-playground.mybluemix.net/editor) kullanılabilir.)

  

API aracılığıyla Hyperledger Fabric ağı ile iletişim kurmak için :

  

Akıllı Sayaç Ekleme Örneği

> curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{"$class": "org.example.basic.SmartMeter","SmartmeterId": "1000","Model": "BCRG","Version": "1.15", "LastUpdateDate": "2019-05-24T12:30:40.043Z"}' 'http://localhost:3001/api/org.example.basic.SmartMeter'

  

Enerji Ölçümü Başlatma Örneği

> curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{"$class": "org.example.basic.EnergyUsage","energyId": "1000", "owner": "org.example.basic.SmartMeter#1000","TotalMeasure": 0}' 'http://localhost:3001/api/org.example.basic.EnergyUsage'

  

Ölçüm İşlem Kaydı (Transaction) Örneği

> curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{"$class": "org.example.basic.EnergyUsageTransaction","asset": "org.example.basic.EnergyUsage#1000","AddingMeasure": 10}' 'http://localhost:3001/api/org.example.basic.EnergyUsageTransaction'

  

Gerçekleşen İşlem Kayıtları Sorgulama Örneği

>curl -X GET --header 'Accept: application/json' 'http://localhost:3001/api/org.example.basic.EnergyUsageTransaction'