pipeline {
    agent any

    tools {
    maven 'Maven_Home' // Changed from 'Maven3' to 'Maven_Home'
}

    stages {
        stage('Git Checkout') {
            steps {
                // Pulling your code from the repository
                git 'https://github.com/your-username/your-repo.git'
            }
        }

        stage('Build & Unit Test') {
            steps {
                echo 'Building and running tests...'
                // Clean and compile the code while running unit tests
                sh 'mvn clean install'
            }
        }

        stage('Static Code Analysis (PMD)') {
            steps {
                echo 'Running PMD to check for code smells...'
                // Generates the pmd.xml and pmd.html reports
                // 'mvn pmd:check' could be used here to fail the build on violations
                sh 'mvn pmd:pmd'
            }
        }

        stage('Check for Duplicate Code (CPD)') {
            steps {
                echo 'Running Copy-Paste Detector...'
                sh 'mvn pmd:cpd'
            }
        }

        stage('Generate Surefire Report') {
            steps {
                echo 'Generating Surefire Test Reports...'
                // Generates the HTML version of test results
                sh 'mvn surefire-report:report-only'
            }
        }

        stage('Project Documentation (Site)') {
            steps {
                echo 'Generating full project documentation site...'
                // Combines all reports (PMD, Surefire, etc.) into one site
                sh 'mvn site'
            }
        }
    }

    post {
        always {
            // Archive the artifacts so you can view them in the Jenkins UI
            archiveArtifacts artifacts: 'target/*.war, target/site/**', allowEmptyArchive: true
            
            // This publishes the reports directly to the Jenkins project page
            junit '**/target/surefire-reports/*.xml'
        }
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed. Please check the logs and PMD/Surefire reports.'
        }
    }
}
