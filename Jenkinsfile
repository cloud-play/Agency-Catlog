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

        stage('Compile & Static Analysis') {
            steps {
                echo 'Compiling and running initial PMD/CPD...'
                // Generates reports for PMD and Duplicate Code (CPD)
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
                // Generates the Surefire HTML report
                sh "mvn -f ${PROJECT_DIR}/pom.xml verify surefire-report:report"
            }
            post {
                always {
                    junit "**/target/surefire-reports/*.xml"
                }
            }
        }

        stage('Security Gate (PMD Check)') {
            steps {
                echo 'Enforcing Code Standards...'
                // This is the stage that fails if code quality is low
                sh "mvn -f ${PROJECT_DIR}/pom.xml pmd:check" 
                
                withSonarQubeEnv('SonarQube-Server') {
                    sh "mvn -f ${PROJECT_DIR}/pom.xml sonar:sonar"
                }
            }
        }

        stage("Sonar Quality Gate") {
            steps {
                timeout(time: 1, unit: 'HOURS') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Project Site Documentation') {
            steps {
                echo 'Generating Full Maven Site...'
                // Creates the complete website with all reports
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
            // Archives WAR and all HTML reports (Site, PMD, CPD, Surefire)
            archiveArtifacts artifacts: '**/target/*.war, **/target/site/**', allowEmptyArchive: true
        }
    }
}
