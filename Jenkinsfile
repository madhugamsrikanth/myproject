pipeline{
    agent any

    environment{
	APP_NAME='myproject'
	ENV='dev'
	DEMO_CREDS=credentials('demo-credential')

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
	stage('Docker Build') {
    steps {
	sh 'docker --version'
        sh 'docker build -t myproject .'
    }
}
	stage('Docker run'){
	steps{
		sh 'docker run -rm myproject'
		}

	}
	stage('Credentials Test'){
		steps{
			sh 'echo "username is:$DEMO_CREDS_USR" '
			sh 'echo "password is:$DEMO_CREDS_PSW" '
	}

}

        stage('Deploy') {
            steps {
                sh 'echo "Deploying $APP_NAME to $ENV"'
            }
        }
    }
}

        
            
                
