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
	stage('Docker Build') {
    steps {
	sh 'docker --version'
        sh 'docker build -t myproject .'
    }
}
stage('Docker Push') {
    steps {
        withCredentials([usernamePassword(
            credentialsId: 'docker-hub-creds',
            usernameVariable: 'DOCKER_USERNAME',
            passwordVariable: 'DOCKER_PASSWORD'
        )]) {
            sh '''
                echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
                docker tag myproject:latest $DOCKER_USERNAME/myproject:latest
                docker push $DOCKER_USERNAME/myproject:latest
                docker logout
            '''
        }
    }
}
	stage('Docker run'){
	steps{
		sh 'docker run --rm myproject'
		}

	}

        stage('Deploy') {
    steps {
        sh '''
            docker stop myproject-container || true
            docker rm myproject-container || true

            docker run -d \
              --name myproject-container \
              -p 5001:5001 \
              myproject
        '''
    }
}
        
            
                
