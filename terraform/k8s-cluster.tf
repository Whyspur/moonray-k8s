resource "digitalocean_kubernetes_cluster" "moonray-cluster" {
  name   = "moonray-cluster"
  # Only NYC2 and TOR1 Regions support GPU instances
  region = "nyc2"
  version = "latest"

  node_pool {
    name       = "worker-pool"
    size       = var.node_size
    node_count = var.node_count
  }
}