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
                     sh 'terraform init -backend=false -input=false'
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

                     env.IMAGE_TAG = "3.7.1-${env.GIT_SHA}-b${env.BUILD_NUMBER}"
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

                ACTIVE_CLUSTER_COUNT="$(aws ecs describe-clusters \
                  --clusters vendure-production-cluster \
                  --region ap-south-1 \
                  --query "length(clusters[?status=='ACTIVE'])" \
                  --output text)"

                if [ "$ACTIVE_CLUSTER_COUNT" -gt 0 ]; then

                CURRENT_STOREFRONT_TASK_DEFINITION="$(aws ecs describe-services \
                  --cluster vendure-production-cluster \
                  --services vendure-storefront-service \
                  --region ap-south-1 \
                  --query 'services[0].taskDefinition' \
                  --output text)"

               if [ -n "$CURRENT_STOREFRONT_TASK_DEFINITION" ] && \
                  [ "$CURRENT_STOREFRONT_TASK_DEFINITION" != "None" ]; then

               CURRENT_STOREFRONT_IMAGE_URI="$(aws ecs describe-task-definition \
                 --task-definition "$CURRENT_STOREFRONT_TASK_DEFINITION" \
                 --region ap-south-1 \
                 --query "taskDefinition.containerDefinitions[?name=='vendure-storefront'].image | [0]" \
                 --output text)"

              if [ -n "$CURRENT_STOREFRONT_IMAGE_URI" ] && \
                 [ "$CURRENT_STOREFRONT_IMAGE_URI" != "None" ]; then

              export TF_VAR_storefront_image_uri="$CURRENT_STOREFRONT_IMAGE_URI"

              echo "Preserving currently deployed Storefront image"
        fi
    fi
fi

               cd infrastructure/terraform
               terraform init -reconfigure -input=false

                terraform plan \
                  -input=false \
                  -var-file="environments/production.tfvars" \
                  -var="server_image_uri=${SERVER_IMAGE_URI}" \
                  -out=tfplan
            '''

           }
      }
  }




        stage('Production Approval') {
            steps {
                timeout(time: 30, unit: 'MINUTES') {
                input(
                    message: 'Deploy Vendure production infrastructure using this Terraform plan?',
                    ok: 'Deploy'
        )
      }
   }
}


        stage('Terraform Production Apply') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'vendure-jenkins-terraform'
                ]]) {
                    sh '''
                        set +x

                        ROLE_CREDS="$(aws sts assume-role \
                          --role-arn arn:aws:iam::974268348514:role/vendure-terraform-deployer \
                          --role-session-name "jenkins-apply-${BUILD_NUMBER}" \
                          --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]' \
                          --output text)"


                          export AWS_ACCESS_KEY_ID="$(printf '%s\n' "$ROLE_CREDS" | awk '{print $1}')"
                          export AWS_SECRET_ACCESS_KEY="$(printf '%s\n' "$ROLE_CREDS" | awk '{print $2}')"
                          export AWS_SESSION_TOKEN="$(printf '%s\n' "$ROLE_CREDS" | awk '{print $3}')"
                          unset ROLE_CREDS
                          aws sts get-caller-identity

                          cd infrastructure/terraform
                          terraform apply -input=false tfplan
                    '''
                  }
              }
           }


        stage('Push Server Image to ECR') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'vendure-jenkins-ecr'
        ]]) {
            sh '''
                aws ecr get-login-password \
                  --region ap-south-1 \
                | docker login \
                  --username AWS \
                  --password-stdin \
                  974268348514.dkr.ecr.ap-south-1.amazonaws.com

                docker tag \
                  "vendure-production:${IMAGE_TAG}" \
                  "${SERVER_IMAGE_URI}"

                docker push "${SERVER_IMAGE_URI}"
            '''
        }
    }
}


        stage('Verify Application Secret') {
            steps {
                script {
                    def currentVersionCount = ''

                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'vendure-jenkins-terraform'
                    ]]) {
                        currentVersionCount = sh(
                            script: '''
                                set +x

                                ROLE_CREDS="$(aws sts assume-role \
                                  --role-arn arn:aws:iam::974268348514:role/vendure-terraform-deployer \
                                  --role-session-name "jenkins-secret-check-${BUILD_NUMBER}" \
                                  --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]' \
                                  --output text)"

                                export AWS_ACCESS_KEY_ID="$(printf '%s\n' "$ROLE_CREDS" | awk '{print $1}')"
                                export AWS_SECRET_ACCESS_KEY="$(printf '%s\n' "$ROLE_CREDS" | awk '{print $2}')"
                                export AWS_SESSION_TOKEN="$(printf '%s\n' "$ROLE_CREDS" | awk '{print $3}')"

                                unset ROLE_CREDS

                                CURRENT_VERSION="$(aws secretsmanager describe-secret \
                                  --secret-id vendure-production/app \
                                  --region ap-south-1 \
                                  --query 'length(values(not_null(VersionIdsToStages, `{}`))[?contains(@, `AWSCURRENT`)])' \
                                  --output text)"

                                printf '%s' "$CURRENT_VERSION"
                            ''',
                            returnStdout: true
                        ).trim()
                    }

                    if (currentVersionCount == '0') {
                        timeout(time: 30, unit: 'MINUTES') {
                        input(
                            message: 'Populate vendure-production/app with SUPERADMIN_USERNAME, SUPERADMIN_PASSWORD, and COOKIE_SECRET, then continue.',
                            ok: 'Verify Secret'
                        )
                     }

                        withCredentials([[
                            $class: 'AmazonWebServicesCredentialsBinding',
                            credentialsId: 'vendure-jenkins-terraform'
                        ]]) {
                            sh '''
                                set +x

                                ROLE_CREDS="$(aws sts assume-role \
                                  --role-arn arn:aws:iam::974268348514:role/vendure-terraform-deployer \
                                  --role-session-name "jenkins-secret-verify-${BUILD_NUMBER}" \
                                  --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]' \
                                  --output text)"

                                export AWS_ACCESS_KEY_ID="$(printf '%s\n' "$ROLE_CREDS" | awk '{print $1}')"
                                export AWS_SECRET_ACCESS_KEY="$(printf '%s\n' "$ROLE_CREDS" | awk '{print $2}')"
                                export AWS_SESSION_TOKEN="$(printf '%s\n' "$ROLE_CREDS" | awk '{print $3}')"

                                unset ROLE_CREDS

                                CURRENT_VERSION="$(aws secretsmanager describe-secret \
                                  --secret-id vendure-production/app \
                                  --region ap-south-1 \
                                  --query 'length(values(not_null(VersionIdsToStages, `{}`))[?contains(@, `AWSCURRENT`)])' \
                                  --output text)"

                                test "$CURRENT_VERSION" -gt 0

                                echo "Application secret has an AWSCURRENT version"
                            '''
                        }
                    } else {
                        echo 'Application secret already has an AWSCURRENT version'
                    }
                }
            }
        }


        stage('Deploy API') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'vendure-jenkins-terraform'
        ]]) {
            sh '''
                set +x

                ROLE_CREDS="$(aws sts assume-role \
                  --role-arn arn:aws:iam::974268348514:role/vendure-terraform-deployer \
                  --role-session-name "jenkins-api-deploy-${BUILD_NUMBER}" \
                  --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]' \
                  --output text)"

                export AWS_ACCESS_KEY_ID="$(printf '%s\n' "$ROLE_CREDS" | awk '{print $1}')"
                export AWS_SECRET_ACCESS_KEY="$(printf '%s\n' "$ROLE_CREDS" | awk '{print $2}')"
                export AWS_SESSION_TOKEN="$(printf '%s\n' "$ROLE_CREDS" | awk '{print $3}')"

                unset ROLE_CREDS

                API_TASK_DEFINITION_ARN="$(terraform \
                  -chdir=infrastructure/terraform \
                  output -raw api_task_definition_arn)"

                  test -n "$API_TASK_DEFINITION_ARN"

                API_TASK_IMAGE="$(aws ecs describe-task-definition \
                  --task-definition "$API_TASK_DEFINITION_ARN" \
                  --region ap-south-1 \
                  --query "taskDefinition.containerDefinitions[?name=='vendure-api'].image | [0]" \
                  --output text)"

                test "$API_TASK_IMAGE" = "$SERVER_IMAGE_URI"

                echo "API task definition verified: ${API_TASK_DEFINITION_ARN}"

                aws ecs update-service \
                  --cluster vendure-production-cluster \
                  --service vendure-api-service \
                  --task-definition "$API_TASK_DEFINITION_ARN" \
                  --desired-count 1 \
                  --region ap-south-1 \
                  >/dev/null

                aws ecs wait services-stable \
                  --cluster vendure-production-cluster \
                  --services vendure-api-service \
                  --region ap-south-1

                ALB_DNS="$(aws elbv2 describe-load-balancers \
                  --names vendure-production-alb \
                  --region ap-south-1 \
                  --query 'LoadBalancers[0].DNSName' \
                  --output text)"

                curl --fail --silent --show-error \
                  --connect-timeout 5 \
                  --max-time 20 \
                  --retry 3 \
                  --retry-delay 2 \
                  --retry-connrefused \
                  -H 'Content-Type: application/json' \
                  --data '{"query":"{ __typename }"}' \
                  "http://${ALB_DNS}/shop-api"

                echo
                echo "Vendure API deployment is healthy"
            '''
        }
    }
}


       stage('Deploy Worker') {
           steps {
               withCredentials([[
                   $class: 'AmazonWebServicesCredentialsBinding',
                   credentialsId: 'vendure-jenkins-terraform'
        ]]) {
            sh '''
                set +x

                ROLE_CREDS="$(aws sts assume-role \
                  --role-arn arn:aws:iam::974268348514:role/vendure-terraform-deployer \
                  --role-session-name "jenkins-worker-deploy-${BUILD_NUMBER}" \
                  --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]' \
                  --output text)"

                export AWS_ACCESS_KEY_ID="$(printf '%s\n' "$ROLE_CREDS" | awk '{print $1}')"
                export AWS_SECRET_ACCESS_KEY="$(printf '%s\n' "$ROLE_CREDS" | awk '{print $2}')"
                export AWS_SESSION_TOKEN="$(printf '%s\n' "$ROLE_CREDS" | awk '{print $3}')"

                unset ROLE_CREDS

                WORKER_TASK_DEFINITION_ARN="$(terraform \
                  -chdir=infrastructure/terraform \
                  output -raw worker_task_definition_arn)"

                test -n "$WORKER_TASK_DEFINITION_ARN"

                WORKER_TASK_IMAGE="$(aws ecs describe-task-definition \
                  --task-definition "$WORKER_TASK_DEFINITION_ARN" \
                  --region ap-south-1 \
                  --query "taskDefinition.containerDefinitions[?name=='vendure-worker'].image | [0]" \
                  --output text)"

                test "$WORKER_TASK_IMAGE" = "$SERVER_IMAGE_URI"

                echo "Worker task definition verified: ${WORKER_TASK_DEFINITION_ARN}"

                aws ecs update-service \
                  --cluster vendure-production-cluster \
                  --service vendure-worker-service \
                  --task-definition "$WORKER_TASK_DEFINITION_ARN" \
                  --desired-count 1 \
                  --region ap-south-1 \
                  >/dev/null

                aws ecs wait services-stable \
                  --cluster vendure-production-cluster \
                  --services vendure-worker-service \
                  --region ap-south-1

                RUNNING_COUNT="$(aws ecs describe-services \
                  --cluster vendure-production-cluster \
                  --services vendure-worker-service \
                  --region ap-south-1 \
                  --query 'services[0].runningCount' \
                  --output text)"

                test "$RUNNING_COUNT" -eq 1

                echo "Vendure Worker deployment is healthy"
            '''
        }
    }
}


       stage('Build Production Storefront') {
           steps {
               withCredentials([[
                   $class: 'AmazonWebServicesCredentialsBinding',
                   credentialsId: 'vendure-jenkins-terraform'
           ]]) {
            sh '''
                set +x

                ROLE_CREDS="$(aws sts assume-role \
                  --role-arn arn:aws:iam::974268348514:role/vendure-terraform-deployer \
                  --role-session-name "jenkins-storefront-build-${BUILD_NUMBER}" \
                  --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]' \
                  --output text)"

                export AWS_ACCESS_KEY_ID="$(printf '%s\n' "$ROLE_CREDS" | awk '{print $1}')"
                export AWS_SECRET_ACCESS_KEY="$(printf '%s\n' "$ROLE_CREDS" | awk '{print $2}')"
                export AWS_SESSION_TOKEN="$(printf '%s\n' "$ROLE_CREDS" | awk '{print $3}')"

                unset ROLE_CREDS

                ALB_DNS="$(aws elbv2 describe-load-balancers \
                  --names vendure-production-alb \
                  --region ap-south-1 \
                  --query 'LoadBalancers[0].DNSName' \
                  --output text)"

                export STOREFRONT_API_URL="http://${ALB_DNS}/shop-api"

                cd app

                docker build \
                  -f apps/storefront/Dockerfile \
                  --build-arg VENDURE_SHOP_API_URL="${STOREFRONT_API_URL}" \
                  -t "vendure-production-storefront:${IMAGE_TAG}" \
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
                    "vendure-production-storefront:${IMAGE_TAG}"
                '''
             }
        }


        stage('Push Storefront Image to ECR') {
            steps {
                script {
                    env.STOREFRONT_IMAGE_URI = "974268348514.dkr.ecr.ap-south-1.amazonaws.com/vendure-production-storefront:${env.IMAGE_TAG}"
                }

                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'vendure-jenkins-ecr'
                ]]) {
                    sh '''
                        aws ecr get-login-password \
                        --region ap-south-1 \
                        | docker login \
                        --username AWS \
                        --password-stdin \
                        974268348514.dkr.ecr.ap-south-1.amazonaws.com

                        docker tag \
                        "vendure-production-storefront:${IMAGE_TAG}" \
                        "${STOREFRONT_IMAGE_URI}"

                        docker push "${STOREFRONT_IMAGE_URI}"
            '''
                     }
              }
         }


         stage('Terraform Storefront Plan') {
             steps {
                 withCredentials([[
                     $class: 'AmazonWebServicesCredentialsBinding',
                     credentialsId: 'vendure-jenkins-terraform'
                 ]]) {
                     sh '''
                         set +x

                         ROLE_CREDS="$(aws sts assume-role \
                         --role-arn arn:aws:iam::974268348514:role/vendure-terraform-deployer \
                         --role-session-name "jenkins-storefront-plan-${BUILD_NUMBER}" \
                         --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]' \
                         --output text)"

                         export AWS_ACCESS_KEY_ID="$(printf '%s\n' "$ROLE_CREDS" | awk '{print $1}')"
                         export AWS_SECRET_ACCESS_KEY="$(printf '%s\n' "$ROLE_CREDS" | awk '{print $2}')"
                         export AWS_SESSION_TOKEN="$(printf '%s\n' "$ROLE_CREDS" | awk '{print $3}')"

                          unset ROLE_CREDS

                          cd infrastructure/terraform

                          terraform plan \
                            -input=false \
                            -var-file="environments/production.tfvars" \
                            -var="server_image_uri=${SERVER_IMAGE_URI}" \
                            -var="storefront_image_uri=${STOREFRONT_IMAGE_URI}" \
                            -out=tfplan-storefront
            '''
                        }
                }
          }


          stage('Validate Storefront Terraform Plan') {
              steps {
                  dir('infrastructure/terraform') {
                      sh '''
                          python3 scripts/validate_storefront_plan.py tfplan-storefront
                      '''
        }
    }
}


          stage('Terraform Storefront Apply') {
              steps {
                  withCredentials([[
                      $class: 'AmazonWebServicesCredentialsBinding',
                      credentialsId: 'vendure-jenkins-terraform'
                  ]]) {
                      sh '''
                          set +x

                          ROLE_CREDS="$(aws sts assume-role \
                          --role-arn arn:aws:iam::974268348514:role/vendure-terraform-deployer \
                          --role-session-name "jenkins-storefront-apply-${BUILD_NUMBER}" \
                          --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]' \
                          --output text)"

                          export AWS_ACCESS_KEY_ID="$(printf '%s\n' "$ROLE_CREDS" | awk '{print $1}')"
                          export AWS_SECRET_ACCESS_KEY="$(printf '%s\n' "$ROLE_CREDS" | awk '{print $2}')"
                          export AWS_SESSION_TOKEN="$(printf '%s\n' "$ROLE_CREDS" | awk '{print $3}')"

                          unset ROLE_CREDS

                          cd infrastructure/terraform

                          terraform apply -input=false tfplan-storefront
                       '''
                         }
                 }
            }


            stage('Deploy Storefront') {
                steps {
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'vendure-jenkins-terraform'
                    ]]) {
                        sh '''
                            set +x

                            ROLE_CREDS="$(aws sts assume-role \
                              --role-arn arn:aws:iam::974268348514:role/vendure-terraform-deployer \
                              --role-session-name "jenkins-storefront-deploy-${BUILD_NUMBER}" \
                              --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]' \
                              --output text)"

                            export AWS_ACCESS_KEY_ID="$(printf '%s\n' "$ROLE_CREDS" | awk '{print $1}')"
                            export AWS_SECRET_ACCESS_KEY="$(printf '%s\n' "$ROLE_CREDS" | awk '{print $2}')"
                            export AWS_SESSION_TOKEN="$(printf '%s\n' "$ROLE_CREDS" | awk '{print $3}')"


                            unset ROLE_CREDS
                            STOREFRONT_TASK_DEFINITION_ARN="$(terraform \
                              -chdir=infrastructure/terraform \
                              output -raw storefront_task_definition_arn)"

                            test -n "$STOREFRONT_TASK_DEFINITION_ARN"

                            STOREFRONT_TASK_IMAGE="$(aws ecs describe-task-definition \
                              --task-definition "$STOREFRONT_TASK_DEFINITION_ARN" \
                              --region ap-south-1 \
                              --query "taskDefinition.containerDefinitions[?name=='vendure-storefront'].image | [0]" \
                              --output text)"

                            test "$STOREFRONT_TASK_IMAGE" = "$STOREFRONT_IMAGE_URI"

                            echo "Storefront task definition verified: ${STOREFRONT_TASK_DEFINITION_ARN}"


                           aws ecs update-service \
                             --cluster vendure-production-cluster \
                             --service vendure-storefront-service \
                             --task-definition "$STOREFRONT_TASK_DEFINITION_ARN" \
                             --desired-count 1 \
                             --region ap-south-1 \
                             >/dev/null

                           aws ecs wait services-stable \
                             --cluster vendure-production-cluster \
                             --services vendure-storefront-service \
                             --region ap-south-1

                           ALB_DNS="$(aws elbv2 describe-load-balancers \
                             --names vendure-production-alb \
                             --region ap-south-1 \
                             --query 'LoadBalancers[0].DNSName' \
                             --output text)"

                          curl --fail --silent --show-error \
                            --connect-timeout 5 \
                            --max-time 20 \
                            --retry 3 \
                            --retry-delay 2 \
                            --retry-connrefused \
                            "http://${ALB_DNS}/health"

                          echo
                          echo "Vendure Storefront deployment is healthy"
                    '''
                  }
              }
          }



          stage('Production E2E Validation') {
              steps {
                  withCredentials([[
                      $class: 'AmazonWebServicesCredentialsBinding',
                      credentialsId: 'vendure-jenkins-terraform'
                  ]]) {
                      sh '''
                          set +x

                          ROLE_CREDS="$(aws sts assume-role \
                            --role-arn arn:aws:iam::974268348514:role/vendure-terraform-deployer \
                            --role-session-name "jenkins-e2e-${BUILD_NUMBER}" \
                            --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]' \
                            --output text)"

                         export AWS_ACCESS_KEY_ID="$(printf '%s\n' "$ROLE_CREDS" | awk '{print $1}')"
                         export AWS_SECRET_ACCESS_KEY="$(printf '%s\n' "$ROLE_CREDS" | awk '{print $2}')"
                         export AWS_SESSION_TOKEN="$(printf '%s\n' "$ROLE_CREDS" | awk '{print $3}')"

                         unset ROLE_CREDS

                         ALB_DNS="$(aws elbv2 describe-load-balancers \
                           --names vendure-production-alb \
                           --region ap-south-1 \
                           --query 'LoadBalancers[0].DNSName' \
                           --output text)"

                        echo "Validating Storefront health..."
                        curl --fail --silent --show-error \
                          --connect-timeout 5 \
                          --max-time 20 \
                          --retry 3 \
                          --retry-delay 2 \
                          --retry-connrefused \
                          "http://${ALB_DNS}/health"

                        echo
                        echo "Validating Vendure Shop API..."
                        curl --fail --silent --show-error \
                          --connect-timeout 5 \
                          --max-time 20 \
                          --retry 3 \
                          --retry-delay 2 \
                          --retry-connrefused \
                          -H 'Content-Type: application/json' \
                          --data '{"query":"{ __typename }"}' \
                          "http://${ALB_DNS}/shop-api"

                        echo
                        echo "Validating Storefront root..."
                        curl --fail --silent --show-error \
                          --connect-timeout 5 \
                          --max-time 20 \
                          --retry 3 \
                          --retry-delay 2 \
                          --retry-connrefused \
                          --output /dev/null \
                          "http://${ALB_DNS}/"

                        echo "Production E2E validation passed"
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
                             docker rmi vendure-production-storefront:${IMAGE_TAG} || true
                """
                     }

                     if (env.SERVER_IMAGE_URI) {
                         sh """
                             docker rmi "${SERVER_IMAGE_URI}" || true
                         """
                    }

                     if (env.STOREFRONT_IMAGE_URI) {
                         sh """
                             docker rmi "${STOREFRONT_IMAGE_URI}" || true
                         """
                     }
                   }

                   sh '''
                       docker logout 974268348514.dkr.ecr.ap-south-1.amazonaws.com || true

                       rm -f infrastructure/terraform/tfplan
                       rm -f infrastructure/terraform/tfplan-storefront
                       rm -f infrastructure/terraform/tfplan-storefront.json
                  '''
               }
           }


    }


