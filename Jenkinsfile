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

        stage('Compile & PMD') {
            steps {
                sh "mvn -f ${PROJECT_DIR}/pom.xml clean compile pmd:pmd"
            }
        }

        stage('Trivy FS Scan') {
            steps {
                sh "trivy fs ${PROJECT_DIR} > trivy-fs-report.txt"
                sh 'cat trivy-fs-report.txt'
            }
        }

        stage('Unit Test & Coverage') {
            steps {
                sh "mvn -f ${PROJECT_DIR}/pom.xml verify"
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

        stage("Quality Gate") {
            steps {
                timeout(time: 1, unit: 'HOURS') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Package') {
            steps {
                sh "mvn -f ${PROJECT_DIR}/pom.xml package -DskipTests"
            }
        }

        stage('Deploy to Tomcat') {
            steps {
                // Using sudo as Jenkins user often lacks write access to /opt
                sh "sudo cp ${WORKSPACE}/${PROJECT_DIR}/target/*.war ${TOMCAT_PATH}/devops-app.war"
            }
        }

        stage('Health Check') {
            steps {
                script {
                    echo "Waiting 30s for Tomcat to deploy..."
                    sleep 30 
                    
                    // Note: URL includes the war name 'devops-app' as the context
                    def response = sh(script: "curl -s http://localhost:8080/devops-app/actuator/health", returnStdout: true).trim()
                    
                    echo "Response from App: ${response}"
                    
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
        success {
            echo "Successfully completed build for Kubebytes DevOps Project!"
        }
        failure {
            echo "Pipeline failed. Check logs for specific errors."
        }
    }
}
