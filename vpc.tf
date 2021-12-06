variable "project_id" {
  description = "haram-326012"
}

variable "region" {
  description = "region"
}

provider "google" {
  project = var.project_id
  region  = var.region
  credentials = file("/var/lib/jenkins/key.json")

}

data "google_compute_subnetwork" "subnet" {
  #name    = "sbn-test-1"
  name    = "sbn-test-4"
  project = "vcp-share-network"
  #region  = "asia-northeast3"
  region  = "asia-northeast1"
}
data "google_compute_network" "network" {
  name    = "vpc-network"
}
# VPC


