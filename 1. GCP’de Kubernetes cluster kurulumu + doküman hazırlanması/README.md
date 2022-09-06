## Gerekli Kurulumlar:

otomatize etmeden önce gerekenler;

**google-cloud-cli**

**kubernetes engine api etkinleştirme**

### **Google Cloud Cli Kurulumu :**

```bash
sudo apt update
sudo apt install snapd
sudo snap install google-cloud-cli --classic
```

google cloud client ile hesabınızın bağlanması için gereken komut

```bash
gcloud auth application-default login
```

 linke girdikten sonra ****gcloud CLI**** ile gcp mail hesabımızı bağlıyoruz.

![1](https://user-images.githubusercontent.com/67348445/188741770-12ad7c1a-c17f-426b-86c5-57df21bcc0d1.png)

Enter authorization code kısmına alttaki kodu yapıştırırsak credentials sağlanıyor.

### K**ubernetes engine api etkinleştirme:**

**Kubernetes engine > cluster**

![2](https://user-images.githubusercontent.com/67348445/188741781-23dc5994-f906-486e-99ac-a8f91de0d485.png)


**Enable**

![3](https://user-images.githubusercontent.com/67348445/188741786-3317560b-164e-44a8-8158-ae85378a2631.png)

## Terraform Kullanımı

```bash
mkdir tf
vim main.tf
```

m**ain.tf dosyası** 

```bash
provider "google" {    # sağlayıcı,proje adı,bölge gibi bilgiler bulunur.
    project = "myproject-361717"
    region =  "europe-west3"
    zone = "europe-west3-a"
}
resource "google_compute_network" "vpc_network" {  # sanal bir network oluşturur.
    name = "bc-network"
    auto_create_subnetworks= "true"
}

resource "google_container_cluster" "bootcamp" {   # Kubernetes cluster tanımı.
    name = "bc-gke"
    remove_default_node_pool = true
    initial_node_count       = 1
    network = google_compute_network.vpc_network.name

}

resource "google_service_account" "nodepool" { # Servislerin, Google Cloudda hangi yetkilere sahip olunacağını buradan ayarlarız.Servislere hesap açıp yetki veririz.Bot hesap g>    account_id = "bc-serviceaccount"
    display_name ="BC Service Account"
}

resource "google_container_node_pool" "primary_preemptible_nodes" { # node poolu oluşturduğumuz yer.
    name = "bc-node-pool"
    cluster = google_container_cluster.bootcamp.name # bc-gke
    node_count = 1 # 1 adet

    node_config{
        preemptible = true  # sunucuyu daha ucuza verir fakat ihtiyacı olduğu anda geri alıp başkasına satabilir.
        machine_type = "e2-medium"

        service_account = google_service_account.nodepool.email
        oauth_scopes = [
            "https://www.googleapis.com/auth/cloud-platform"
        ]
    }
}
```

Terraform init, tf dosyalarını içeren bir çalışma dizini başlatmak için kullanılır.

```bash
terraform init

```

![4](https://user-images.githubusercontent.com/67348445/188741792-2d63b4c0-5f90-4ab6-9431-a36803e9667f.png)

Terraform plan , Terraform'un altyapınızda yapmayı planladığı değişiklikleri önizlemenize olanak tanıyan bir yürütme planı oluşturur.

```bash
terraform plan

```

![5](https://user-images.githubusercontent.com/67348445/188741796-04048806-a0ec-4345-b02a-22f93eef8977.png)


![6](https://user-images.githubusercontent.com/67348445/188741803-d8668d80-c991-47f7-9b65-99e651cf647a.png)


Terraform apply, terraform plan tarafından oluşan yürütme planını gerçekleştirir.

```bash
terraform apply
```

![7](https://user-images.githubusercontent.com/67348445/188741807-f529b48a-1d7a-4311-8323-ad73d176f015.png)


**Sonuç:**

![8](https://user-images.githubusercontent.com/67348445/188741814-e363a5c8-e1ab-4323-8e04-45cc54abe7e9.png)

Oluşturduğum kubernetes cluster’a bağlanmak için

![9](https://user-images.githubusercontent.com/67348445/188741820-d080b7f5-e3bc-46fa-a78a-9116c5978e5b.png)


![10](https://user-images.githubusercontent.com/67348445/188741824-b3a01e48-42dc-47ad-88a3-4454ab78e046.png)


```bash
gcloud container clusters get-credentials bc-gke --zone europe-west3-a --project myproject-361717
```

![11](https://user-images.githubusercontent.com/67348445/188741829-820119f8-a331-4d6d-bd58-70fa161af96d.png)

