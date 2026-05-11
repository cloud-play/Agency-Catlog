pipeline {
    agent any

    tools {
        maven 'Maven_Home' 
    }

    environment {
        TOMCAT_PATH = '/opt/tomcat/webapps'
        // Your code and pom.xml are inside this subdirectory
        PROJECT_DIR = 'addressbook' 
    }

    stages {
        stage('Git Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/cloud-play/devops001.git'
            }
        }

        stage('Compile & Package') {
            steps {
                echo 'Building Travel Agency WAR...'
                // Use -f to point to the pom.xml inside the addressbook folder
                sh "mvn -f ${PROJECT_DIR}/pom.xml clean package -DskipTests"
            }
        }

        stage('Deploy to Tomcat') {
            steps {
                echo 'Cleaning Tomcat and Deploying New Site...'
                sh """
                    sudo rm -rf ${TOMCAT_PATH}/devops-app.war
                    sudo rm -rf ${TOMCAT_PATH}/devops-app
                    sudo rm -rf /opt/tomcat/work/Catalina/localhost/devops-app
                    
                    # Copying the specific war built from the addressbook folder
                    sudo cp ${WORKSPACE}/${PROJECT_DIR}/target/*.war ${TOMCAT_PATH}/devops-app.war
                    sudo chown testuser:testuser ${TOMCAT_PATH}/devops-app.war
                """
            }
        }

        stage('Trivy FS Scan') {
            steps {
                sh "trivy fs ${PROJECT_DIR} > trivy-fs-report.txt"
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube-Server') {
                    sh "mvn -f ${PROJECT_DIR}/pom.xml sonar:sonar"
                }
            }
        }

        stage('Health Check') {
            steps {
                script {
                    sleep 20
                    def response = sh(script: "curl -s http://localhost:8080/devops-app/", returnStdout: true).trim()
                    if (response.contains('KubeBytes Travel')) {
                        echo "SUCCESS: Site is Live! ✅"
                    } else {
                        error "FAILURE: Still showing Hello World or Error! ❌"
                    }
                }
            }
        }
    }
}
