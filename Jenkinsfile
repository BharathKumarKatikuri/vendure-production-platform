pipeline {
    agent any 
    
    tools {
        nodejs 'node20'
    }

    options {
        skipDefaultCheckout(true)
        disableConcurrentBuilds()
    }
  
    parameters {
        string(
            name: 'VENDURE_SHOP_API_URL',
            defaultValue: '',
            description: 'Vendure Shop API URL used during Storefront build',
            trim: true
        )
    }

    stages{


        stage('Validate Parameters') {
            steps {
                script {
                    if (!params.VENDURE_SHOP_API_URL?.trim()) {
                        error('VENDURE_SHOP_API_URL is required')
                }
            }
        }
     }

    
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
    

         stage('Install Dependencies') {
             steps {
                 dir('app') {
                     sh 'npm ci --no-audit --no-fund'
                 }
              }
         }

         
         stage('Application Validation') {
             steps {
                 dir('app') {
                     sh 'npm run build -w server'
                     sh 'npm run lint -w storefront'
                     sh 'npm exec -w storefront -- next typegen'
                     sh 'npm run check-types -w storefront'
                     
                 }
             }
         }
         
        
         stage('Terraform Validation') {
             steps {
                 dir('infrastructure/terraform') {
                     sh 'terraform fmt -check -recursive'
                     sh 'terraform init -backend=false'
                     sh 'terraform validate'
                 }
              }
         }
    
          
         stage('Build Server Image') {
             steps {
                 script {
                     env.IMAGE_TAG = sh(
                         script: 'git rev-parse --short HEAD',
                         returnStdout: true
                     ).trim()
                  }
                     
                     dir('app') {
                         sh "docker build -f apps/server/Dockerfile -t vendure-production:${env.IMAGE_TAG} ."
                     }      
              }           
         }


         stage('Security Scan - Server') {
             steps {
                 sh """
                     docker run --rm \
                     -v /var/run/docker.sock:/var/run/docker.sock \
                     -v trivy-cache:/root/.cache/trivy \
                     aquasec/trivy:0.74.0 image \
                     --scanners vuln \
                     --severity HIGH,CRITICAL \
                     --ignore-unfixed \
                     --exit-code 1 \
                     vendure-production:${env.IMAGE_TAG}
                 """
             }
         }
     
           

         stage('Build Storefront Image') {
             steps {
                 dir('app') {
                     sh '''
                         docker build \
                           -f apps/storefront/Dockerfile \
                           --build-arg VENDURE_SHOP_API_URL="${VENDURE_SHOP_API_URL}" \
                           -t vendure-production-storefront:${IMAGE_TAG} \
                           .
                     '''
                 }
             }
         }

         
         stage('Security Scan - Storefront') {
             steps {
                 sh '''
                     docker run --rm \
                     -v /var/run/docker.sock:/var/run/docker.sock \
                     -v trivy-cache:/root/.cache/trivy \
                     aquasec/trivy:0.74.0 image \
                     --scanners vuln \
                     --severity HIGH,CRITICAL \
                     --ignore-unfixed \
                     --exit-code 1 \
                     vendure-production-storefront:${IMAGE_TAG}
             
               '''
             }
         }
 }
         
         post {
             always {
                 script {
                     if (env.IMAGE_TAG) {
                         sh """
                             docker rmi vendure-production:${IMAGE_TAG} || true
                             docker rmi vendure-production-storefront:${IMAGE_TAG} || true
                         """
                     }
                 }
             }
         }
                    
}


