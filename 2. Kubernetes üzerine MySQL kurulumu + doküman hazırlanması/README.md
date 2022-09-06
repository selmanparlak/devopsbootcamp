## MySQL Kurulumu

### Manifest Dosyalarını kullanarak yükleme:

Yaml dosyalarını kullanarak MySQL’i kurarken özelleştirmişte olacağız.

 MySQL Operator for Kubernetes tarafından kullanılan Custom Resource Definition (CRD) kurun:

CRD,Kubernetes API'sini genişleten veya kendi API'nizi bir projeye veya kümeye tanıtmanıza olanak tanıyan bir nesnedir. Özel bir kaynak tanımlama (CRD) dosyası, kendi nesne türlerinizi tanımlar ve API Sunucusunun tüm yaşam döngüsünü yönetmesini sağlar.

```bash
kubectl apply -f https://raw.githubusercontent.com/mysql/mysql-operator/trunk/deploy/deploy-crds.yaml
```

RBAC tanımlarını da içeren Kubernetes için MySQL Operator'ü dağıtın:

Rol tabanlı erişim denetimi (RBAC), kuruluşunuzdaki bireysel kullanıcıların rollerine dayalı olarak bilgisayar veya ağ kaynaklarına erişimi düzenleme yöntemidir.

```bash
kubectl apply -f https://raw.githubusercontent.com/mysql/mysql-operator/trunk/deploy/deploy-operator.yaml
```

deploymentı oluşup oluşmadığını görmek için get kullandık.

```bash
kubectl get deployment mysql-operator --namespace mysql-operator
```

**MySQL InnoDB Cluster**

veritabanında oluşan yükü birden fazla sunucuya dağıtarak çok daha yüksek performanslar elde etmenizi sağlayan bir veritabanı çeşitidir.

InnoDb , hata toleransı yüksek sistemleri oluşturmak için kullanılmaktadır.

kubectl ile bir InnoDB Kümesi oluşturmak için, önce yeni bir MySQL kök kullanıcısı için kimlik bilgilerini içeren bir secret oluşturun.

```bash
kubectl create secret generic mypwds \
        --from-literal=rootUser=root \
        --from-literal=rootHost=% \
        --from-literal=rootPassword="parlak"
```

Şimdi istediğimiz gibi yaml dosyası oluşturabiliriz.

```bash
vim mycluster.yaml

```

InnoDBCluster tanımı, üç MySQL sunucu örneği ve bir MySQL Router örneği oluşturur:

```bash
apiVersion: mysql.oracle.com/v2
kind: InnoDBCluster
metadata:
  name: mycluster
spec:
  secretName: mypwds
  tlsUseSelfSigned: true
  instances: 3
  router:
    instances: 1
```

```yaml
kubectl apply -f mycluster.yaml # kendi özel clusterımızı çalıştırdık.
```

Clusterın  durumunu kontrol etmek için

```bash
kubectl get innodbcluster --watch
```

![1](https://user-images.githubusercontent.com/67348445/188745317-b11118f9-7b19-4f01-8995-bd5d47c19d29.png)

artık MySQL’e bağlanabiliriz.

```bash
kubectl run --rm -it myshell --image=mysql/mysql-operator -- mysqlsh root@mycluster --sql
```

MySQL InnoDB Kümesini yönetmek için MySQL Shell ile yeni bir kapsayıcı oluşturduk.

oluşturduğumuz secret dosyasındaki parola isteniyor. Benim şifrem “parlak”

![2](https://user-images.githubusercontent.com/67348445/188745320-244b5784-2065-4989-b83c-a841159381f1.png)


### Helm kullanarak WordPress kurulumu:

Kubernetes üzerine wordpress kurulumu için helm’i tercih ettim. Helm bizim için Kubernetes ortamında çalışan uygulamalarımızın kaynaklarını (deployment, statefulset, service, ingress vb.) kolayca yönetebilmemizi ve karmaşıklıklardan kurtulmamızı sağlar.Paket yöneticisi gibi düşünebiliriz. Ubuntu’daki apt gibi.

### **Helm Kurulumu:**

```bash
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm
```

Helm’i kurduktan sonra sunucu veya sisteminizde docker ve k3s olması gerekiyor. Yoksa aşağıdaki gibi bir hata alabilirsiniz.

![3](https://user-images.githubusercontent.com/67348445/188745321-28af1d94-097e-490d-95ae-a8e3f498dee8.png)


yine hata alıyorsanız şu kodu deneyebilirsiniz.

```bash
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
```

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
```

```yaml
helm install my-release \
  --set auth.rootPassword=secretpassword,auth.database=app_database \
  --set auth.username=selman \
  --set auth.password=parlak \
    bitnami/mysql
```

yaml dosyasıyla da kurulum yapabiliriz.

```bash
helm install my-release -f values.yaml bitnami/mysql

```

**Helm parametreleri :**

`global.storageClass` = kalıcı depolama birimleri için StorageClass.

`image.registry` = image dosyası kaynağı (docker.io).

`image.repository`= image dosyası (bitnami/mysql).

`auth.database` = oluşturulacak  veritabanının adı.

`auth.username` = oluşturulacak kullanıcının adı.

`auth.password` = oluşturulan kullanıcı için şifre.rootpassword sağlanmışsa yok sayılabilir.

`primary.persistence.storageClass`= birincil kalıcı deploma birimi için StorageClass.

`primary.persistence.accessModes` =birincil kalıcı depolama birimi için erişim Modları. varsayılan(ReadWriteOnce).

`primary.persistence.size` =  birincil kalıcı depolama birimi boyutu.

![4](https://user-images.githubusercontent.com/67348445/188745322-715009d4-9996-4615-b07a-9afa14b1bd34.png)


```bash
# 1. Run a pod that you can use as a client:

      kubectl run my-releases-mysql-client --rm --tty -i --restart='Never' --image  docker.io/bitnami/mysql:8.0.30-debian-11-r6 --namespace default --env MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD --command -- bash

```

![5](https://user-images.githubusercontent.com/67348445/188745325-46c8a0a2-134c-4e50-8019-6f0b2dda7037.png)


```bash
# 2. To connect to primary service (read/write):

      mysql -h my-releases-mysql.default.svc.cluster.local -uroot -p"$MYSQL_ROOT_PASSWORD"
```

![6](https://user-images.githubusercontent.com/67348445/188745327-2a1ce917-34e4-4c7d-83b7-08207dd61c56.png)


`auth.rootPassword=secretpassword` = secretpassword

![7](https://user-images.githubusercontent.com/67348445/188745331-91e015a6-0368-4427-8da2-e493bdbe703e.png)


![8](https://user-images.githubusercontent.com/67348445/188745334-a502f138-0946-46a0-8ee1-eee99cd16658.png)

