pipeline {
  agent {
    label 'dockerslave'
  }
  tools {
    // Install the Maven version configured as "M3" and add it to the path.
    maven "M3"
  }
  environment {
    IMAGE = readMavenPom().getArtifactId()
    VERSION = readMavenPom().getVersion()
  }
  stages {
    stage('Clear running apps') {
      steps {
        // Clear previous instances of app built
        sh 'docker rm -f pandaapp || true'
      }
    }
    stage('Build and Junit') {
      steps {
        // Run Maven on a Unix agent.
        sh "mvn clean install"
      }
    }   
    stage('Build Docker image'){
      steps {
        sh "mvn package -Pdocker"
      }
    }
    stage('Run Docker app') {
      steps {
        sh "docker run -d -p 0.0.0.0:8080:8080 --name pandaapp ${IMAGE}:${VERSION}"
      }
    }
    stage('Test Selenium') {
      steps {
        sh "mvn test -Pselenium"
      }
    }
    stage('Deploy jar to artifactory') {
      steps {
        configFileProvider([configFile(fileId: '5cc99d94-ac82-447e-9411-ad6e5e3f900d', variable: 'MAVEN_GLOBAL_SETTINGS')]) {
          sh "mvn -s $MAVEN_GLOBAL_SETTINGS deploy -Dmaven.test.skip=true -e"
        }
      }     
    }
    stage('Run Terraform') {
      steps {
        dir('infrastructure/terraform') {
          withCredentials(
            [file(credentialsId: 'ssh-aws-ed25519-nopass',
                  variable: 'ssh-key-igi-aws')]) {
            sh "cp \$terraformpanda ../ssh-aws-ed25519-nopass"
          }
          withCredentials(
            [[$class: 'AmazonWebServicesCredentialsBinding',
              credentialsId: 'igi-almost-root']] {
              sh 'terraform init && terraform apply -auto-approve'
            }
          )
        }
      }
    }
    stage('Copy Ansible Role') {
      steps {
        sh '''
        cp -r infrastructure/ansibe/panda/ \
          /etc/ansible/roles/
           '''
      }
    }
    stage('Run Ansible') {
      steps {
        dir('infrastructure/ansible') {
          sh 'chmod 600 ../id_ed25519_aws-nopass'
          sh 'ansible-playbook -i ./inventory playbook.yml'
        }
      }
    }
  }
  post {
    always {  
      sh 'docker stop pandaapp'
      deleteDir()
    }
  }
}
