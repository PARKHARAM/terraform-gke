  pipeline {
    agent any
    tools {
        terraform 'Terraform'

    }

    stages {  

      stage('Git Checkout') {
        steps {
          git branch: 'main', credentialsId: 'gkfka133', url: 'https://github.com/PARKHARAM/terraform-gke' 
         
        }      
      }

      stage('TF Init&Plan') {
        steps {
          sh 'terraform init'
          sh 'terraform plan'
        }      
      }

      

      stage('TF Apply') {
        steps {
          sh 'terraform apply --auto-approve'
        }
      }
      stage('kubectl yaml') {
        steps {
          withCredentials([file(credentialsId: 'haram-gke', variable: 'GC_KEY')]) {
            sh 'gcloud auth activate-service-account --key-file=${GC_KEY}'
            sh 'gcloud container clusters get-credentials haram-326012-gke --region asia-northeast1 --project haram-326012'
            
                 }
          
          sh ("kubectl get nodes") 
          sh ("kubectl apply -f https://download.elastic.co/downloads/eck/1.0.1/all-in-one.yaml")
          sh ("kubectl  apply -f eck.yaml") 
          sh ("kubectl  apply -f nginx.yaml") 
        }
      }
    } 
  }
