pipeline {
    agent any

    tools {
        maven 'Maven_Home' 
    }

    environment {
        TOMCAT_PATH = '/opt/tomcat/webapps'
        // CRITICAL: Pointing to the subdirectory containing your Travel site code
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
                echo 'Generating WAR file from addressbook directory...'
                // Using -f ensures Maven uses the pom.xml inside the addressbook folder
                sh "mvn -f ${PROJECT_DIR}/pom.xml clean package -DskipTests"
            }
        }

        stage('Deploy to Tomcat') {
            steps {
                echo 'Deploying to Tomcat and clearing internal caches...'
                // 1. Delete old files and Tomcat's internal JSP cache folder
                sh "sudo rm -rf ${TOMCAT_PATH}/devops-app.war"
                sh "sudo rm -rf ${TOMCAT_PATH}/devops-app"
                sh "sudo rm -rf /opt/tomcat/work/Catalina/localhost/devops-app"
                
                // 2. Copy the fresh war from the addressbook target folder
                sh "sudo cp ${WORKSPACE}/${PROJECT_DIR}/target/*.war ${TOMCAT_PATH}/devops-app.war"
                
                // 3. Fix ownership so Tomcat can read the new site
                sh "sudo chown testuser:testuser ${TOMCAT_PATH}/devops-app.war"
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
                    echo "Waiting 20 seconds for Tomcat to extract the new site..."
                    sleep 20
                    // Checking for your Travel Site title in the page source
                    def response = sh(script: "curl -s http://localhost:8080/devops-app/", returnStdout: true).trim()
                    if (response.contains('KubeBytes Travel')) {
                        echo "Application is HEALTHY and Live! ✅"
                    } else {
                        error "Application is still showing old content! ❌"
                    }
                }
            }
        }
    }

    post {
        always {
            echo 'Archiving build artifacts and reports...'
            // Captures the WAR and reports regardless of build success/failure
            archiveArtifacts artifacts: '**/target/*.war, **/target/site/**, trivy-fs-report.txt', allowEmptyArchive: true
        }
        success {
            echo 'Deployment Finished Successfully!'
        }
        failure {
            echo 'Pipeline failed. Check stage logs for errors.'
        }
    }
}
