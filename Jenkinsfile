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
          sh 'gcloud container clusters get-credentials haram-326012-gke --region asia-northeast1 --project haram-326012'
          sh 'kubectl apply -f eck.yaml '
        }
      }
    } 
  }
