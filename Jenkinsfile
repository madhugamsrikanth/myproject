pipeline {
    agent any

    environment {
        APP_NAME = 'myproject'
        ENV = 'dev'
    }

    stages {

        stage('Build') {
            steps {
                sh 'echo "Building $APP_NAME"'
                sh 'echo "Environment $ENV"'
                sh 'java --version'
                sh 'git --version'
                sh 'python3 --version'
            }
        }

        stage('Test') {
            steps {
                sh '''
                    echo "Running tests..."
                    python3 test.py
                '''
            }
        }

        stage('Docker Build') {
            steps {
                sh '''
                    echo "Building Docker image..."
                    docker --version
                    docker build -t myproject:latest .
                '''
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
                        echo "Logging into Docker Hub..."

                        echo "$DOCKER_PASSWORD" | docker login \
                            -u "$DOCKER_USERNAME" \
                            --password-stdin

                        echo "Tagging Docker image..."

                        docker tag myproject:latest \
                            $DOCKER_USERNAME/myproject:latest

                        echo "Pushing image to Docker Hub..."

                        docker push \
                            $DOCKER_USERNAME/myproject:latest

                        docker logout
                    '''
                }
            }
        }

        stage('Deploy') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'docker-hub-creds',
                    usernameVariable: 'DOCKER_USERNAME',
                    passwordVariable: 'DOCKER_PASSWORD'
                )]) {

                    sh '''
                        echo "Logging into Docker Hub..."

                        echo "$DOCKER_PASSWORD" | docker login \
                            -u "$DOCKER_USERNAME" \
                            --password-stdin

                        echo "Pulling latest image from Docker Hub..."

                        docker pull \
                            $DOCKER_USERNAME/myproject:latest

                        echo "Stopping old container..."

                        docker stop myproject-container || true

                        echo "Removing old container..."

                        docker rm myproject-container || true

                        echo "Starting new container..."

                        docker run -d \
                            --name myproject-container \
                            -p 5001:5001 \
                            $DOCKER_USERNAME/myproject:latest

                        echo "Deployment completed successfully!"

                        docker logout
                    '''
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully!'
        }

        failure {
            echo 'Pipeline failed!'
        }
    }
}
