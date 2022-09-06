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

![Ekran görüntüsü 2022-09-06 220222.png](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/9c53a6ef-c75c-40ac-8ea7-9f03174baf87/Ekran_grnts_2022-09-06_220222.png)

**Enable**

![Untitled](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/f4a76847-89b5-4a76-a548-fc91f9d483a4/Untitled.png)

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

![https://s3-us-west-2.amazonaws.com/secure.notion-static.com/1032fdd9-b4c4-47a0-8de5-2d1bf261d658/Ekran_grnts_2022-09-06_210718.png](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/1032fdd9-b4c4-47a0-8de5-2d1bf261d658/Ekran_grnts_2022-09-06_210718.png)

Terraform plan , Terraform'un altyapınızda yapmayı planladığı değişiklikleri önizlemenize olanak tanıyan bir yürütme planı oluşturur.

```bash
terraform plan

```

![Untitled](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/e786e9a6-63e3-43a8-823b-965da1f53251/Untitled.png)

![Untitled](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/ef819512-a286-45e8-b331-0c3ca019652f/Untitled.png)

Terraform apply, terraform plan tarafından oluşan yürütme planını gerçekleştirir.

```bash
terraform apply
```

![Untitled](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/600df182-ea91-445b-a506-9304efac395d/Untitled.png)

**Sonuç:**

![Untitled](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/e533dd1e-d388-421f-a78a-3bbc1b52afb4/Untitled.png)

Oluşturduğum kubernetes cluster’a bağlanmak için

![Untitled](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/7dbe4411-d05e-4f93-ba69-80db1e05df8a/Untitled.png)

![Untitled](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/dc8dd243-1a90-4444-b938-a3bb957e396b/Untitled.png)

```bash
gcloud container clusters get-credentials bc-gke --zone europe-west3-a --project myproject-361717
```

![Untitled](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/06d22626-5acc-469c-965f-b83a3f04d0f8/Untitled.png)
