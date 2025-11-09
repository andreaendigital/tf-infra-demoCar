pipeline {
  agent any


    parameters {
        booleanParam(name: 'PLAN_TERRAFORM', defaultValue: true, description: 'Run terraform plan to preview infrastructure changes')
        booleanParam(name: 'APPLY_TERRAFORM', defaultValue: true, description: 'Apply infrastructure changes using terraform apply')
        booleanParam(name: 'DEPLOY_ANSIBLE', defaultValue: true, description: 'Run Ansible to deploy the Flask application')
        booleanParam(name: 'DESTROY_TERRAFORM', defaultValue: false, description: 'Destroy infrastructure using terraform destroy')
    }

  environment {
    ANSIBLE_DIR       = 'configManagement-carPrice'
    INVENTORY_SCRIPT  = "${ANSIBLE_DIR}/generate_inventory.sh"
    INVENTORY_FILE    = "${ANSIBLE_DIR}/inventory.ini"
    PLAYBOOK_FILE     = "${ANSIBLE_DIR}/playbook.yml"
    
  }




    stages {

        stage('Clone Repositories') {
            steps {
                echo 'Cleaning workspace and cloning repositories...'
                deleteDir()

                // 1. Clona el repo de infraestructura (Terraform)
                // Usamos 'checkout' para forzar la clonación directa en la carpeta 'infra'.
                git branch: 'main', url: 'https://github.com/andreaendigital/tf-infra-demoCar'

                // 2. Clona el repo de configuración (Ansible)
                dir("${ANSIBLE_DIR}") {
                    checkout([$class: 'GitSCM', branches: [[name: 'main']], userRemoteConfigs: [[url: 'https://github.com/andreaendigital/configManagement-carPrice']]])
                }
            }
        }


        stage('Terraform Init') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-jenkins-carprice']]) {
                    dir('infra') {
                        sh 'export AWS_PROFILE=""'
                        sh 'terraform init'
                    }
                }
            }
        }

        stage('Terraform Plan') {
            when {
                expression { return params.PLAN_TERRAFORM }
            }
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-jenkins-carprice']]) {
                    dir('infra') { // .tf files must be here
                        sh 'terraform plan -out=tfplan'
                    }
                }
            }
        }

        stage('Terraform Apply') {
            when {
                expression { return params.APPLY_TERRAFORM }
            }
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-jenkins-carprice']]) {
                    dir('infra') {
                        sh 'terraform apply -auto-approve tfplan'
                    }
                }
            }
        }

        stage('Terraform Destroy') {
            when {
                expression { return params.DESTROY_TERRAFORM }
            }
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-jenkins-carprice']]) {
                    dir('infra') {
                        sh 'terraform destroy -auto-approve'
                    }
                }
            }
        }



        stage('Generate Ansible Inventory') {
            when {
                expression { return params.DEPLOY_ANSIBLE }
            }
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-jenkins-carprice']]) {
                sh "chmod +x ${INVENTORY_SCRIPT}"
                sh "${INVENTORY_SCRIPT}"
                }
            }
        }

        stage('Run Ansible Playbook') {
            when {
                expression { return params.DEPLOY_ANSIBLE }
            }
            steps {
                sshagent(credentials: ['ansible-ssh-key']) {
                sh "ansible-playbook -i ${INVENTORY_FILE} ${PLAYBOOK_FILE} --extra-vars 'ansible_ssh_common_args=\"-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null\"'"
                }
            }
        }


    }


    post {
        success {
            script {
                sh '''
                    curl -X POST https://ingest.us1.signalfx.com/v2/datapoint \
                    -H "X-SF-Token: PZuf3J0L2Op_Qj9hpAJzlw" \
                    -H "Content-Type: application/json" \
                    -d '{"gauge":[{"metric":"jenkins.pipeline.success","value":1,"dimensions":{"job":"''' + env.JOB_NAME + '''","build":"''' + env.BUILD_NUMBER + '''","result":"success"}}]}'
                '''
            }
            echo 'Deployment completed successfully!'
        }
        failure {
            script {
                sh '''
                    curl -X POST https://ingest.us1.signalfx.com/v2/datapoint \
                    -H "X-SF-Token: PZuf3J0L2Op_Qj9hpAJzlw" \
                    -H "Content-Type: application/json" \
                    -d '{"gauge":[{"metric":"jenkins.pipeline.failure","value":1,"dimensions":{"job":"''' + env.JOB_NAME + '''","build":"''' + env.BUILD_NUMBER + '''","result":"failure"}}]}'
                '''
            }
            echo 'Deployment failed. Check logs and Terraform state.'
        }
    }
}
