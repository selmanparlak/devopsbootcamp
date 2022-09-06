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

![1](https://user-images.githubusercontent.com/67348445/188746765-8647a7fb-aba6-4e65-a433-c97b58169492.png)


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

![2](https://user-images.githubusercontent.com/67348445/188746771-74601c6b-404a-404c-b6c2-0f0b813892cc.png)


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

![3](https://user-images.githubusercontent.com/67348445/188746773-1e834e51-677b-43c4-a6a8-5ff02857a933.png)


**Wordpress bloğumuza bağlanabilmek için:**

wordpressden oluşan servislerimize bakıyoruz. 

`service.type` varsayılan olarak Loadbalancer oluşturur.

```bash
kubectl get svc 
```

![4](https://user-images.githubusercontent.com/67348445/188746776-13dcfb9f-0a51-4339-b3ef-2f499dfdc0e9.png)


localhost:port  ile bağlanabilirsiniz. benim portum 80:30451 80 burada localhostu ifade eder.

![5](https://user-images.githubusercontent.com/67348445/188746779-fd15317c-7f0b-4d76-95ca-a37c89f7f8b5.png)


admin paneline ulaşmak isterseniz localhost:port/wp-admin

![6](https://user-images.githubusercontent.com/67348445/188746781-9f60b57f-9ebe-47f2-9c54-3b2f831c5c40.png)


yukarıda anlattığım set ile veya yaml ile verdiğiniz `wordpressUsername` ve `wordpressPassword` ’ u burada girebilirsiniz.

**ve sonuç :**

![7](https://user-images.githubusercontent.com/67348445/188746783-1ee96cf6-dfad-4549-a212-0e0d54655d1a.png)


**google kubernetes-cluster’da oluşturduğum wordpressden giriş yapmak isterseniz**

[http://34.89.132.191/](http://34.89.132.191/)
