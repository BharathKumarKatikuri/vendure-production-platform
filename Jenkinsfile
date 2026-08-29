pipeline {
    agent any

    tools {
        nodejs 'node20'
    }

    options {
        skipDefaultCheckout(true)
        disableConcurrentBuilds()
    }

    stages {

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
                     env.GIT_SHA = sh(
                         script: 'git rev-parse --short HEAD',
                         returnStdout: true
                     ).trim()

                     env.IMAGE_TAG = "3.7.1-${env.GIT_SHA}"
                     env.SERVER_IMAGE_URI = "974268348514.dkr.ecr.ap-south-1.amazonaws.com/vendure-production:${env.IMAGE_TAG}"
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



         stage('AWS ECR Authentication') {
             steps {
                 withCredentials([[
                     $class: 'AmazonWebServicesCredentialsBinding',
                     credentialsId: 'vendure-jenkins-ecr'
                  ]])   {
                         sh '''
                             aws sts get-caller-identity
                             aws ecr get-login-password \
                               --region ap-south-1 \
                             | docker login \
                               --username AWS \
                               --password-stdin \
                               974268348514.dkr.ecr.ap-south-1.amazonaws.com
                           '''
                        }
              }
           }


           stage('Terraform Production Plan') {
    steps {
        withCredentials([[
            $class: 'AmazonWebServicesCredentialsBinding',
            credentialsId: 'vendure-jenkins-terraform'
        ]]) {
            sh '''
                set +x

                ROLE_CREDS="$(aws sts assume-role \
                  --role-arn arn:aws:iam::974268348514:role/vendure-terraform-deployer \
                  --role-session-name "jenkins-${BUILD_NUMBER}" \
                  --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]' \
                  --output text)"

                export AWS_ACCESS_KEY_ID="$(printf '%s\n' "$ROLE_CREDS" | awk '{print $1}')"
                export AWS_SECRET_ACCESS_KEY="$(printf '%s\n' "$ROLE_CREDS" | awk '{print $2}')"
                export AWS_SESSION_TOKEN="$(printf '%s\n' "$ROLE_CREDS" | awk '{print $3}')"

                unset ROLE_CREDS

                aws sts get-caller-identity

                cd infrastructure/terraform

                terraform init -reconfigure

                terraform plan \
                  -var-file="environments/production.tfvars" \
                  -var="server_image_uri=${SERVER_IMAGE_URI}" \
                  -out=tfplan
            '''
           }
      }
}
        }
         post {
             always {
                 script {
                     if (env.IMAGE_TAG) {
                         sh """
                             docker rmi vendure-production:${IMAGE_TAG} || true
                         """
                     }
                 }
             }
         }

}


