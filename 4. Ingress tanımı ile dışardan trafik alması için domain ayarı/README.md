Kubernetes Ingress, harici kullanıcıların bir Kubernetes cluster’ın servislere erişimini genellikle HTTPS/HTTP aracılığıyla yönetmek için yönlendirme kuralları sağlayan bir API nesnesidir.LoadBalancer oluşturmadan trafiği yönlendirmek için kolayca kurallar oluşturabilirsiniz.

![https://d33wubrfki0l68.cloudfront.net/91ace4ec5dd0260386e71960638243cf902f8206/c3c52/docs/images/ingress.svg](https://d33wubrfki0l68.cloudfront.net/91ace4ec5dd0260386e71960638243cf902f8206/c3c52/docs/images/ingress.svg)

```yaml
kubectl create ingress red \
  --rule=red.A.B.C.D.nip.io/*=red:80
```

[red.A.B.C.D.nip.io](http://red.A.B.C.D.nip.io) adresine gelen istekleri red servisinin 80 portuna yönlendir anlamına gelir.

çoklu kurallar da yapabiliriz.

```yaml
kubectl create ingress rgb \
  --rule=red.A.B.C.D.nip.io/*=red:80 \
  --rule=green.A.B.C.D.nip.io/*=green:80 \
  --rule=blue.A.B.C.D.nip.io/*=blue:80
```

Bu şekilde ingress kuralları oluşturabiliriz. Dışardan gelen trafiği içeri alabiliriz.

**Yaml Versiyonu:**

```yaml
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: rgb
spec:
  rules:
  - host: rgb.A.B.C.D.nip.io
    http:
      paths:
      - path: /
        backend:
          serviceName: red
          servicePort: 80
      - path: /
        backend:
          serviceName: green
          servicePort: 80
      - path: /
        backend:
          serviceName: blue
          servicePort: 80
```

**Örnek:**

red,green,blue servislerini kullanabilmek için 3 tane deployment oluşturduk.

```bash
kubectl create deployment red   --image=jpetazzo/color
kubectl create deployment green --image=jpetazzo/color
kubectl create deployment blue  --image=jpetazzo/color
```

![2](https://user-images.githubusercontent.com/67348445/188747968-a97862a5-f8d8-4f4a-a632-b2f238066e00.png)


hepsinin önüne ClusterIP atadık.

**ClusterIP** : yalnızca bir Kubernetes kümesi içinde erişilebilen bir servis türü veya bir Kubernetes kümesi içindeki bileşenlerin sanal IP' adresidir.

```bash
kubectl expose deployment red   --port=80
kubectl expose deployment green --port=80
kubectl expose deployment blue  --port=80
```

![3](https://user-images.githubusercontent.com/67348445/188748194-34a76618-11ad-46bb-aa78-ce1821daa1f6.png)


```yaml
kubectl create ingress rgb \
  --rule="red.192.168.25.144.nip.io/*=red:80" \
  --rule="green.192.168.25.144.nip.io/*=green:80" \
  --rule="blue.192.168.25.144.nip.io/*=blue:80"
```

linux sunucu ip adresimin sonuna [nip.io](http://nip.io) ekledim. nip.io,örneğin [red.192.168.25.144.nip.io](http://red.192.168.25.144.nip.io) adresine dns isteği gelirse bize 192.168.25.144 adresini döndürüyor.

burada [red.192.168.25.144.nip.io](http://red.192.168.25.144.nip.io/),[green.192.168.25.144.nip.io](http://green.192.168.25.144.nip.io/),[blue.192.168.25.144.nip.io](http://blue.192.168.25.144.nip.io/) adresine gelen istekleri sırasıyla red,green,blue servislerinin 80 portuna yönlendirme yapıyor.

![4](https://user-images.githubusercontent.com/67348445/188748199-49ff5900-d60a-4794-b577-8db738d41f68.png)


![5](https://user-images.githubusercontent.com/67348445/188748202-ed821486-9761-4c5f-8c8d-3c7db8f0b3e6.png)


![6](https://user-images.githubusercontent.com/67348445/188748206-0f0c4159-ac44-4616-8a3b-f7e7326eb020.png)


**Wordpress Ingress örneği:**

wordpress servisine sahip bir sunucuya port yönlendirmesi yapacağım.

port yönlendirmesi yapmadan önceki hali;

![7](https://user-images.githubusercontent.com/67348445/188748208-07ecd49f-2a46-4a02-b6f7-83c01128083d.png)


**Servislerimiz:**

![8](https://user-images.githubusercontent.com/67348445/188748210-903940d6-c5e2-43bc-87f1-a6c5a1176049.png)


```yaml
kubectl create ingress wordpress\
  --rule="wordpress.192.168.25.144.nip.io/*=my-release-wordpress:80"
```

**Sonuç:**

![9](https://user-images.githubusercontent.com/67348445/188748214-48d1e89f-e0a3-4990-81a6-a2fbbdc159aa.png)


**google kubernetes-cluster’da wordpress için ingress oluşturdum.giriş yapmak isterseniz**

[http://wordpress.34.89.132.191.nip.io/](http://wordpress.34.89.132.191.nip.io/)
