   pipeline {
    agent any

    stages {

        stage('Build') {
            steps {
                sh 'echo "Building on Jenkins Agent"'
                sh 'java --version'
                sh 'git --version'
            }
        }

        stage('Test') {
            steps {
                sh 'echo "Running tests on Jenkins Agent"'
            }
        }

        stage('Deploy') {
            steps {
                sh 'echo "Deploying from Jenkins Agent"'
            }
        }
    }
}

        
            
                
