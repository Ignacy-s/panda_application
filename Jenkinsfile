pipeline {
    agent {
      label '007'
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
    }
    post {
        always {  
            sh 'docker stop pandaapp'
            deleteDir()
        }
    }
}
