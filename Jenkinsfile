pipeline {
    agent any

    tools {
        maven 'Maven_Home' 
    }

    environment {
        TOMCAT_PATH = '/opt/tomcat/webapps'
        PROJECT_DIR = 'devops-ci-cd-webapp'
    }

    stages {
        stage('Git Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/cloud-play/devops001.git'
            }
        }

        stage('Compile & Package') {
            steps {
                echo 'Generating WAR file...'
                // Use 'package' instead of 'compile' so the .war file is actually created
                sh "mvn -f ${PROJECT_DIR}/pom.xml clean package -DskipTests"
            }
        }

        stage('Deploy to Tomcat') {
            steps {
                echo 'Deploying to Tomcat...'
                // 1. Delete old files to ensure fresh output
                sh "sudo rm -rf ${TOMCAT_PATH}/devops-app.war"
                sh "sudo rm -rf ${TOMCAT_PATH}/devops-app"
                
                // 2. Copy the fresh war
                sh "sudo cp ${WORKSPACE}/${PROJECT_DIR}/target/*.war ${TOMCAT_PATH}/devops-app.war"
            }
        }

        stage('Trivy FS Scan') {
            steps {
                sh "trivy fs ${PROJECT_DIR} > trivy-fs-report.txt"
                sh 'cat trivy-fs-report.txt'
            }
        }

        stage('Unit Test & Surefire') {
            steps {
                sh "mvn -f ${PROJECT_DIR}/pom.xml surefire-report:report"
            }
            post {
                always {
                    junit "**/target/surefire-reports/*.xml"
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube-Server') {
                    sh "mvn -f ${PROJECT_DIR}/pom.xml sonar:sonar"
                }
            }
        }

        stage("Sonar Quality Gate") {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Project Documentation (Site)') {
            steps {
                sh "mvn -f ${PROJECT_DIR}/pom.xml site"
            }
        }

        stage('Health Check') {
            steps {
                script {
                    echo "Waiting for Tomcat to extract the app..."
                    sleep 20
                    def response = sh(script: "curl -s http://localhost:8080/devops-app/actuator/health", returnStdout: true).trim()
                    if (response.contains('"status":"UP"')) {
                        echo "Application is HEALTHY! ✅"
                    } else {
                        error "Application is UNHEALTHY! ❌"
                    }
                }
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: '**/target/*.war, **/target/site/**', allowEmptyArchive: true
        }
    }
}
