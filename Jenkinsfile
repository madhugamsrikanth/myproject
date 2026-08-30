pipeline{
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
                sh 'python3 test.py'
            }
        }

        stage('Deploy') {
            steps {
                sh 'echo "Deploying from Jenkins Agent"'
            }
        }
    }
}

        
            
                
