pipeline {
    agent any

    tools {
        // Matches the name in your Jenkins Global Tool Configuration
        maven 'Maven_Home' 
    }

    stages {
        stage('Git Checkout') {
            steps {
                // IMPORTANT: Ensure this URL matches your public repo
                git 'https://github.com/cloud-play/Agency-Catlog.git'
            }
        }

        stage('Build & Unit Test') {
            steps {
                echo 'Building and running tests...'
                // clean install triggers the 'test' phase and JaCoCo 'prepare-agent'
                sh 'mvn clean install'
            }
        }

        stage('Code Coverage (JaCoCo)') {
            steps {
                echo 'Generating Code Coverage Report...'
                // Generates the coverage data for Jenkins/Sonar
                sh 'mvn jacoco:report'
            }
        }

        stage('Static Code Analysis (PMD)') {
            steps {
                echo 'Running PMD Analysis...'
                // Generates PMD and CPD reports
                sh 'mvn pmd:pmd pmd:cpd'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                echo 'Pushing metrics to SonarQube...'
                // Useful for future training when you connect a Sonar server
                // sh 'mvn sonar:sonar' 
                echo 'Skipping actual scan until Sonar server is configured.'
            }
        }

        stage('Reports & Site Generation') {
            steps {
                echo 'Generating Surefire and Project Site...'
                sh 'mvn surefire-report:report-only site'
            }
        }
    }

    post {
        always {
            // Archives the WAR file and all HTML reports for students to see
            archiveArtifacts artifacts: 'target/*.war, target/site/**, target/site/jacoco/**', allowEmptyArchive: true
            
            // Displays test results in the Jenkins "Test Result Trend" graph
            junit '**/target/surefire-reports/*.xml'
        }
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed. Check the Console Output for Maven or Git errors.'
        }
    }
}
