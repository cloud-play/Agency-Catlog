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

        stage('Compile & PMD Analysis') {
            steps {
                echo 'Running PMD and CPD...'
                // Running PMD and Copy-Paste Detector as requested
                sh "mvn -f ${PROJECT_DIR}/pom.xml clean compile pmd:pmd pmd:cpd"
            }
        }

        stage('Trivy FS Scan') {
            steps {
                sh "trivy fs ${PROJECT_DIR} > trivy-fs-report.txt"
            }
        }

        stage('Unit Test & Surefire Report') {
            steps {
                echo 'Generating Surefire Reports...'
                // Runs tests and creates the HTML report
                sh "mvn -f ${PROJECT_DIR}/pom.xml verify surefire-report:report"
            }
            post {
                always {
                    junit "**/target/surefire-reports/*.xml"
                }
            }
        }

        stage('Security & Code Quality') {
            steps {
                // pmd:check will fail the build if code quality is too low
                sh "mvn -f ${PROJECT_DIR}/pom.xml pmd:check"
                
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

        stage('Generate Project Site') {
            steps {
                echo 'Building full Maven Site documentation...'
                // Aggregates all reports (PMD, Surefire, etc) into one HTML site
                sh "mvn -f ${PROJECT_DIR}/pom.xml surefire-report:report-only site"
            }
        }

        stage('Package & Deploy') {
            steps {
                sh "mvn -f ${PROJECT_DIR}/pom.xml package -DskipTests"
                sh "sudo cp ${WORKSPACE}/${PROJECT_DIR}/target/*.war ${TOMCAT_PATH}/devops-app.war"
            }
        }

        stage('Health Check') {
            steps {
                script {
                    echo "Waiting 30s for Tomcat..."
                    sleep 30 
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
            // Archive everything so students can view reports in Jenkins
            archiveArtifacts artifacts: '**/target/*.war, **/target/site/**', allowEmptyArchive: true
        }
        success {
            echo "Successfully completed build for Kubebytes DevOps Project!"
        }
    }
}
