pipeline{
    agent any

    environment{
	APP_NAME='myproject'
	ENV='dev'

}

    stages {

        stage('Build') {
            steps {
                sh 'echo "Building $APP_NAME"'
		sh 'echo "Environment $ENV" '
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
                sh 'echo "Deploying $APP_NAME to $ENV"'
            }
        }
    }
}

        
            
                
