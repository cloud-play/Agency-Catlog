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
                // Pulling your code from the repository
                git branch: 'main', url: 'https://github.com/cloud-play/devops001.git'
            }
        }

        stage('Compile & Static Analysis') {
            steps {
                echo 'Running PMD and CPD analysis...'
                // Generates reports for PMD and Duplicate Code (CPD)
                sh "mvn -f ${PROJECT_DIR}/pom.xml clean compile pmd:pmd pmd:cpd"
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
                echo 'Running Unit Tests and generating Surefire reports...'
                // Generates surefire-report:report as requested
                sh "mvn -f ${PROJECT_DIR}/pom.xml verify surefire-report:report"
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
                // Reduced timeout for training purposes to avoid 1-hour hangs
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Project Documentation (Site)') {
            steps {
                echo 'Generating full project documentation site...'
                // Combines all reports into one site as requested
                sh "mvn -f ${PROJECT_DIR}/pom.xml surefire-report:report-only site"
            }
        }

        stage('Package & Deploy') {
    steps {
        // Build the new package
        sh "mvn -f ${PROJECT_DIR}/pom.xml package -DskipTests"
        
        // 1. Remove the old .war AND the expanded folder
        // 2. Copy the new .war
        sh """
            sudo rm -rf ${TOMCAT_PATH}/devops-app.war
            sudo rm -rf ${TOMCAT_PATH}/devops-app
            sudo cp ${WORKSPACE}/${PROJECT_DIR}/target/*.war ${TOMCAT_PATH}/devops-app.war
        """
    }
}

        stage('Health Check') {
            steps {
                script {
                    echo "Waiting for deployment..."
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
            // Archive all generated reports (PMD, CPD, Surefire, Site)
            archiveArtifacts artifacts: '**/target/*.war, **/target/site/**', allowEmptyArchive: true
        }
    }
}
