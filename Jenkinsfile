pipeline {
    agent any

    tools {
        maven 'Maven_Home' 
    }

    environment {
        // Ensure these paths match your server exactly
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
                echo 'Cleaning old builds and packaging the new WAR...'
                // 'clean' is the secret to getting rid of the "Hello World" build
                sh "mvn -f ${PROJECT_DIR}/pom.xml clean package -DskipTests"
            }
        }

        stage('Deploy to Tomcat') {
    steps {
        echo 'Wiping old deployment and Tomcat work cache...'
        // 1. Remove the app and the war
        sh "sudo rm -rf ${TOMCAT_PATH}/devops-app.war"
        sh "sudo rm -rf ${TOMCAT_PATH}/devops-app"
        
        // 2. Clear the compiled JSP cache (This is the "Work" folder)
        // Adjust the path if your tomcat is not in /opt/tomcat
        sh "sudo rm -rf /opt/tomcat/work/Catalina/localhost/devops-app"
        
        // 3. Copy the fresh war
        sh "sudo cp ${WORKSPACE}/${PROJECT_DIR}/target/*.war ${TOMCAT_PATH}/devops-app.war"
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
                    echo "Waiting 20s for Tomcat to expand the new Travel Site..."
                    sleep 20
                    // Note: If you use Tomcat 9/10, ensure the health endpoint is correct
                    def response = sh(script: "curl -s http://localhost:8080/devops-app/", returnStdout: true).trim()
                    if (response.contains('KubeBytes Travel')) {
                        echo "Deployment Successful! Travel Agency is LIVE. ✅"
                    } else {
                        error "Deployment failed or still showing old page! ❌"
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
