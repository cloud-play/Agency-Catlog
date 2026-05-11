pipeline {
    agent any

    tools {
        maven 'Maven_Home' 
    }

    environment {
        TOMCAT_PATH = '/opt/tomcat/webapps'
        // This targets the specific folder containing your travel site code
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
                // Using -f ensures Maven looks inside the addressbook folder
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
                    
                    # Copy the newly built war from the addressbook target folder
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

    // --- Declarative Post-Build Actions ---
    post {
        always {
            echo 'Cleaning up workspace and archiving artifacts...'
            // Archive the WAR and the Trivy report regardless of build status
            archiveArtifacts artifacts: "${PROJECT_DIR}/target/*.war, trivy-fs-report.txt", allowEmptyArchive: true
        }
        success {
            echo 'Pipeline completed successfully! Sending notification...'
            // Add email or Slack notifications here if configured
        }
        failure {
            echo 'Pipeline failed. Please check the logs for errors in the red stages.'
        }
    }
}
