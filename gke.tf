
variable "gke_username" {
  default     = ""
  description = "gke username"
}

variable "gke_password" {
  default     = ""
  description = "gke password"
}

variable "gke_num_nodes" {
  default     = 1
  description = "number of gke nodes"
}

# GKE cluster


resource "google_container_cluster" "primary" {
  name     = "${var.project_id}-gke"
  location = var.region
  
  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  #project = "vcp-share-network"
  
  network    =  "https://www.googleapis.com/compute/v1/projects/vcp-share-network/global/networks/vpc-network"
  #subnetwork = "https://www.googleapis.com/compute/v1/projects/vcp-share-network/regions/asia-northeast3/subnetworks/sbn-test-1"
  subnetwork = "https://www.googleapis.com/compute/v1/projects/vcp-share-network/regions/asia-northeast1/subnetworks/sbn-test-4"
  #network = data.google_compute_network.network.name
  
  ip_allocation_policy {
    cluster_secondary_range_name = "pod"
    services_secondary_range_name = "service"
  }

}

# Separately Managed Node Pool
resource "google_container_node_pool" "primary_nodes" {
  name       = "${google_container_cluster.primary.name}-node-pool"
  #location   = var.region
  location   = var.region
  
  cluster    = google_container_cluster.primary.name
  node_count = var.gke_num_nodes
  
   node_locations = [
    "asia-northeast1-a", 
    "asia-northeast1-b"
  ]

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    labels = {
      env = var.project_id
    }

    # preemptible  = true
    #machine_type = "n1-standard-1"
    machine_type = "e2-standard-4"
    tags         = ["gke-node", "${var.project_id}-gke", "sgtag-80", "sgtag-4567"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}


# # Kubernetes provider
# # The Terraform Kubernetes Provider configuration below is used as a learning reference only. 
# # It references the variables and resources provisioned in this file. 
# # We recommend you put this in another file -- so you can have a more modular configuration.
# # https://learn.hashicorp.com/terraform/kubernetes/provision-gke-cluster#optional-configure-terraform-kubernetes-provider
# # To learn how to schedule deployments and services using the provider, go here: https://learn.hashicorp.com/tutorials/terraform/kubernetes-provider.
#
# provider "kubernetes" {
#   #load_config_file = "false"
#
#   host     = google_container_cluster.primary.endpoint
#   username = var.gke_username
#   password = var.gke_password
#
#   client_certificate     = google_container_cluster.primary.master_auth.0.client_certificate
#   client_key             = google_container_cluster.primary.master_auth.0.client_key
#   cluster_ca_certificate = google_container_cluster.primary.master_auth.0.cluster_ca_certificate
# }


resource "kubernetes_pod" "with_pod_affinity" {
  metadata {
    name = "with-pod-affinity"
  }

  spec {
    affinity {
      pod_affinity {
        required_during_scheduling_ignored_during_execution {
          label_selector {
            match_expressions {
              key      = "security"
              operator = "In"
              values   = ["S1"]
            }
          }

          topology_key = "failure-domain.beta.kubernetes.io/zone"
        }
      }

      pod_anti_affinity {
        preferred_during_scheduling_ignored_during_execution {
          weight = 100

          pod_affinity_term {
            label_selector {
              match_expressions {
                key      = "security"
                operator = "In"
                values   = ["S2"]
              }
            }

            topology_key = "failure-domain.beta.kubernetes.io/zone"
          }
        }
      }
    }

    container {
      name  = "with-pod-affinity"
      image = "k8s.gcr.io/pause:2.0"
    }
  }
}
