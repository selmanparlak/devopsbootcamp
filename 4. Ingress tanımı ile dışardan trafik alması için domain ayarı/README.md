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

![Untitled.png](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/1355da3e-f5b1-41e6-b459-919d6d7627ec/Untitled.png)

```yaml
kubectl create ingress rgb \
  --rule="red.192.168.25.144.nip.io/*=red:80" \
  --rule="green.192.168.25.144.nip.io/*=green:80" \
  --rule="blue.192.168.25.144.nip.io/*=blue:80"
```

linux sunucu ip adresimin sonuna [nip.io](http://nip.io) ekledim. nip.io,örneğin [red.192.168.25.144.nip.io](http://red.192.168.25.144.nip.io) adresine dns isteği gelirse bize 192.168.25.144 adresini döndürüyor.

burada [red.192.168.25.144.nip.io](http://red.192.168.25.144.nip.io/),[green.192.168.25.144.nip.io](http://green.192.168.25.144.nip.io/),[blue.192.168.25.144.nip.io](http://blue.192.168.25.144.nip.io/) adresine gelen istekleri sırasıyla red,green,blue servislerinin 80 portuna yönlendirme yapıyor.

![Untitled](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/cd4feab3-4fa9-4e26-bdee-1a9fa88f6eeb/Untitled.png)

![Untitled](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/e76dabde-7c7b-44d4-9af6-e9a3cad504d2/Untitled.png)

![Untitled](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/d7aaeac8-87c7-4ac7-a492-33a37cb7200f/Untitled.png)

**Wordpress Ingress örneği:**

wordpress servisine sahip bir sunucuya port yönlendirmesi yapacağım.

port yönlendirmesi yapmadan önceki hali;

![Untitled](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/e0f3dce5-8024-4f91-8065-9aa967024b80/Untitled.png)

**Servislerimiz:**

![Untitled](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/f845f1c5-af3c-4c09-83dc-9fd1570e571b/Untitled.png)

```yaml
kubectl create ingress wordpress\
  --rule="wordpress.192.168.25.144.nip.io/*=my-release-wordpress:80"
```

**Sonuç:**

![Untitled](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/c5284327-dfb2-4ba7-9c1a-24d602914fa1/Untitled.png)

**google kubernetes-cluster’da wordpress için ingress oluşturdum.giriş yapmak isterseniz**

[http://wordpress.34.89.132.191.nip.io/](http://wordpress.34.89.132.191.nip.io/)
