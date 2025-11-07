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
                        input message: '¿Do you want to apply changes on the infraestructure?'
                        sh 'terraform apply tfplan'
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
                        input message: '¿Do you want Destroy Infraestructure?'
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

// En el Jenkinsfile
    stage('Post-Deploy: SSH EC2') {
    // Solo se ejecuta si el despliegue de Ansible fue solicitado
        when {
            expression { return params.DEPLOY_ANSIBLE }
        }
        steps {
            echo 'Connecting to EC2 to verify deployment...'

            // 1. INYECTAR CREDENCIALES AWS para TERRAFORM OUTPUT
            withCredentials([
                // REEMPLAZA 'aws-creds-id' con el ID de tu credencial AWS real
                [$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-jenkins-carprice'] 
            ]) {
                script {
                    // Leer la IP pública del EC2 usando el output que ya corregiste
                    // Nota: Usamos 'ec2_public_ip' ya que fue expuesto en el módulo raíz.
                    def ec2_ip = sh(script: "cd infra && terraform output -raw ec2_public_ip", returnStdout: true).trim()
                    env.EC2_PUBLIC_IP = ec2_ip
                }
            }
            
        // 2. INYECTAR CREDENCIAL SSH para la conexión de VERIFICACIÓN
        // Necesitas el mismo sshagent que usaste para Ansible
        // REEMPLAZA 'ansible-ssh-key' con el ID de tu credencial SSH real
        sshagent(credentials: ['ansible-ssh-key']) {
            sh """
            # Usamos 'ssh -A' para reenviar la llave inyectada por sshagent.
            # NO NECESITAS el argumento '-i /ruta/a/la/llave.pem' cuando usas sshagent.
            ssh -A -o StrictHostKeyChecking=no ec2-user@${env.EC2_PUBLIC_IP} \\
            'systemctl status carprice'
            """
        }
    }

    post {
            success {
            echo 'Deployment completed successfully!'
            }
            failure {
            echo 'Deployment failed. Check logs and Terraform state.'
            }
    }


    }



}
}