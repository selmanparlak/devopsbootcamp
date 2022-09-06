## **Helm**

Kubernetes üzerine wordpress kurulumu için helm’i tercih ettim.

Helm bizim için Kubernetes ortamında çalışan uygulamalarımızın kaynaklarını (deployment, statefulset, service, ingress vb.) kolayca yönetebilmemizi ve karmaşıklıklardan kurtulmamızı sağlar.

Paket yöneticisi gibi düşünebiliriz. Ubuntu’daki apt gibi.

### **Helm Kurulumu:**

```bash
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm
```

Helm’i kurduktan sonra sunucu veya sisteminizde docker ve k3s olması gerekiyor. Yoksa aşağıdaki gibi bir hata alabilirsiniz.

![Untitled](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/deea2fac-fc00-4714-880e-177199726d62/Untitled.png)

yine hata alıyorsanız şu kodu deneyebilirsiniz.

```bash
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
```

## **WordPress Kurulumu:**

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install my-release bitnami/wordpress
```

  

**Kullanıcı adı,şifreyi ve bazı özellikleri biz kurmak istersek şöyle yapabiliriz.**

```
helm install my-release \
  --set wordpressUsername=selman \
  --set wordpressPassword=parlak \
  --set wordpressEmail=selman@example.com \
  --set wordpressBlogName=SelmanBlog \
  --set mariadb.auth.rootPassword=secretpassword \
    bitnami/wordpress
```

Yukarıdaki komut, WordPress yönetici hesabı kullanıcı adını ve şifresini sırasıyla admin ve şifre olarak ayarlar. Ayrıca, MariaDB kök kullanıcı parolasını secretpassword olarak ayarlar.

**Not:**

![Untitled](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/3ce0297d-1cbc-4a3f-8d12-2da46d1409d5/Untitled.png)

Selman’s Blog’unda boşluk olduğu için 2 argüman olarak alır ve hata verir. yaml dosyasında yapmak her zaman daha garantili olabilir.

**yaml dosyasıyla da wordpress oluşturabiliriz.**

`wordpress.yaml`

```bash
image:
  registry: docker.io
  repository: bitnami/wordpress
  tag: 5.3.2-debian-10-r32
  pullPolicy: IfNotPresent
  debug: false
wordpressUsername: selman
wordpressPassword: parlak
wordpressEmail: selman@example.com
wordpressFirstName: selman
wordpressLastName: parlak
wordpressBlogName: Selman's Blog!
wordpressTablePrefix: wp_
wordpressScheme: http
wordpressSkipInstall: false
service:
   type: LoadBalancer
   port: 80
   httpsPort: 443
   httpsTargetPort: https
   metricsPort: 9117
   nodePorts:
     http: ""
     https: ""
     metrics: ""
   externalTrafficPolicy: Cluster
   annotations: {}
   loadBalancerSourceRanges: []
```

```bash
helm install my-release -f wordpress.yaml bitnami/wordpress
```

**Helm parametreleri :**

`image.registry` : Wordpress image dosyası kaydını nereden alacağımızı [söyler.Biz](http://söyler.Biz) kaynak olarak docker’ı gösterdik.

`image.repository`: Docker image yolu

`image.tag`: image versiyonu gibi düşünebiliriz.

`image.debug` : Hata ayıklama yapıp yapmadığını bool değerlerle kontrol edebiliriz. varsayılan false gelir.

`wordpressUsername`: WordPress kullanıcı adı

`wordpressPassword`: WordPress kullanıcı şifresi

`wordpressEmail` : WordPress kullanıcı e-postası

`wordpressFirstName`: WordPress kullanıcı adı

`wordpressLastName`: WordPress kullanıcı soyadı

`wordpressBlogName`: Blog adı

`wordpressTablePrefix`: WordPress veritabanı tabloları için kullanılacak önek

`wordpressScheme`: WordPress URL'leri oluşturmak için kullanılacak şema. Varsayılan http

`wordpressSkipInstall`: Kurulum sihirbazını atlar. varsayılan false gelir.

`service.type`: WordPress servis tipi varsayılan LoadBalancer.

`service.ports.http`:WordPress servis HTTP bağlantı noktası. varsayılan port 80 gelir.

`service.ports.https`: WordPress servis HTTPS bağlantı noktası. varsayılan 443 gelir.

`service.httpsTargetPort`: HTTPS için hedef bağlantı noktası

`service.externalTrafficPolicy`: WordPress servis dış trafik politikası. varsayılan cluster gelir.

**Yüklendikten sonra çıktı bu şekilde olacaktır.**

![Untitled](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/6e306170-cfaf-4e10-8393-f4fac40dd25b/Untitled.png)

**Wordpress bloğumuza bağlanabilmek için:**

wordpressden oluşan servislerimize bakıyoruz. 

`service.type` varsayılan olarak Loadbalancer oluşturur.

```bash
kubectl get svc 
```

![Untitled](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/ceb59123-f302-49b0-b22a-87333382651e/Untitled.png)

localhost:port  ile bağlanabilirsiniz. benim portum 80:30451 80 burada localhostu ifade eder.

![Untitled](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/fb15acaf-a2d2-4145-a91c-4616b2b73cdc/Untitled.png)

admin paneline ulaşmak isterseniz localhost:port/wp-admin

![Untitled](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/d9b42aee-73d9-4592-bb0e-048553ed184b/Untitled.png)

yukarıda anlattığım set ile veya yaml ile verdiğiniz `wordpressUsername` ve `wordpressPassword` ’ u burada girebilirsiniz.

**ve sonuç :**

![Untitled](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/c4b603cc-dbf9-4321-a81e-1dd73571b0c9/Untitled.png)

**google kubernetes-cluster’da oluşturduğum wordpressden giriş yapmak isterseniz**

[http://34.89.132.191/](http://34.89.132.191/)
