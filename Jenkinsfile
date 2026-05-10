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
                echo 'Running Initial PMD and CPD...'
                // Clean and generate raw PMD/CPD data
                sh "mvn -f ${PROJECT_DIR}/pom.xml clean compile pmd:pmd pmd:cpd"
            }
        }

        stage('Trivy FS Scan') {
            steps {
                sh "trivy fs ${PROJECT_DIR} > trivy-fs-report.txt"
            }
        }

        stage('Unit Test & Surefire') {
            steps {
                // Generates surefire reports
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
                echo 'Enforcing PMD Standards...'
                // mvn pmd:check is what failed in your last build
                // If you want to skip failure, change this to pmd:pmd
                sh "mvn -f ${PROJECT_DIR}/pom.xml pmd:check" 
            }
        }

        stage('Project Site Documentation') {
            steps {
                echo 'Generating full HTML Documentation site...'
                // Generates the full site including surefire-report-only
                sh "mvn -f ${PROJECT_DIR}/pom.xml surefire-report:report-only site"
            }
        }

        stage('Package & Deploy') {
            steps {
                sh "mvn -f ${PROJECT_DIR}/pom.xml package -DskipTests"
                sh "sudo cp ${WORKSPACE}/${PROJECT_DIR}/target/*.war ${TOMCAT_PATH}/devops-app.war"
            }
        }
    }

    post {
        always {
            // This is key for your training: archives all HTML reports for viewing
            archiveArtifacts artifacts: '**/target/*.war, **/target/site/**', allowEmptyArchive: true
        }
        success {
            echo "Build Success! All quality gates passed for Kubebytes."
        }
    }
}
