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