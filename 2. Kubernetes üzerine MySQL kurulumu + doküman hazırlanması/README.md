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

![Ekran görüntüsü 2022-09-03 180736.png](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/3824eb7b-442f-4186-aca0-b0d9fce0d0ce/Ekran_grnts_2022-09-03_180736.png)

artık MySQL’e bağlanabiliriz.

```bash
kubectl run --rm -it myshell --image=mysql/mysql-operator -- mysqlsh root@mycluster --sql
```

MySQL InnoDB Kümesini yönetmek için MySQL Shell ile yeni bir kapsayıcı oluşturduk.

oluşturduğumuz secret dosyasındaki parola isteniyor. Benim şifrem “parlak”

![Ekran görüntüsü 2022-09-03 181118.png](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/0c603d1d-8a92-4bf2-8bf6-b92671e06aa1/Ekran_grnts_2022-09-03_181118.png)

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

![Untitled](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/deea2fac-fc00-4714-880e-177199726d62/Untitled.png)

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

![Ekran görüntüsü 2022-09-06 165331.png](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/e7875089-8048-4a52-83a0-8746edd114b4/Ekran_grnts_2022-09-06_165331.png)

```bash
# 1. Run a pod that you can use as a client:

      kubectl run my-releases-mysql-client --rm --tty -i --restart='Never' --image  docker.io/bitnami/mysql:8.0.30-debian-11-r6 --namespace default --env MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD --command -- bash

```

![Untitled](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/3070bc9a-a669-447e-a1be-b10807d6a784/Untitled.png)

```bash
# 2. To connect to primary service (read/write):

      mysql -h my-releases-mysql.default.svc.cluster.local -uroot -p"$MYSQL_ROOT_PASSWORD"
```

![Untitled](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/12fb9f96-aff1-4fe4-97db-9826333c1fec/Untitled.png)

`auth.rootPassword=secretpassword` = secretpassword

![Untitled](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/f1ce7658-9b21-4c13-a4e2-7b05783b29f4/Untitled.png)

![Untitled](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/e22b4615-fa43-4c6a-8cfb-ce59c3dd35d6/Untitled.png)
