pipeline {
    agent any

    tools {
        maven 'Maven_Home' 
    }

    environment {
        TOMCAT_PATH = '/opt/tomcat/webapps'
        // FIX: According to your screenshot, your pom.xml and src are inside 'addressbook'
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
                echo 'Building the Travel Agency WAR file...'
                // Running maven inside the folder where pom.xml actually lives
                sh "mvn -f ${PROJECT_DIR}/pom.xml clean package -DskipTests"
            }
        }

        stage('Deploy to Tomcat') {
            steps {
                echo 'Performing Deep Clean and Deploying...'
                sh """
                    # 1. Delete old war and expanded folder
                    sudo rm -rf ${TOMCAT_PATH}/devops-app.war
                    sudo rm -rf ${TOMCAT_PATH}/devops-app
                    
                    # 2. Delete Tomcat Work/Cache directory to stop it from remembering "Hello World"
                    sudo rm -rf /opt/tomcat/work/Catalina/localhost/devops-app
                    
                    # 3. Copy the fresh war from the correct target folder
                    sudo cp ${WORKSPACE}/${PROJECT_DIR}/target/*.war ${TOMCAT_PATH}/devops-app.war
                    
                    # 4. Ensure permissions are correct
                    sudo chown testuser:testuser ${TOMCAT_PATH}/devops-app.war
                """
            }
        }

        stage('Trivy FS Scan') {
            steps {
                sh "trivy fs ${PROJECT_DIR} > trivy-fs-report.txt"
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
                    echo "Waiting 20s for deployment..."
                    sleep 20
                    // Checking for your Travel Agency title in the HTML
                    def response = sh(script: "curl -s http://localhost:8080/devops-app/", returnStdout: true).trim()
                    if (response.contains('KubeBytes Travel')) {
                        echo "SUCCESS: Travel Agency Site is LIVE! ✅"
                    } else {
                        error "FAILURE: Still showing old content or page not found! ❌"
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
