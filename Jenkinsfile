pipeline {
    agent any

    environment {
        APP_NAME = 'myproject'
        ENV = 'dev'
    }

    stages {

        stage('Build') {
            steps {
                sh '''
                    echo "Building $APP_NAME"
                    echo "Environment: $ENV"
                    java --version
                    git --version
                    python3 --version
                '''
            }
        }

        stage('Test') {
            steps {
                sh '''
                    echo "Running Python tests..."
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
                        echo "$DOCKER_PASSWORD" | docker login \
                            -u "$DOCKER_USERNAME" \
                            --password-stdin

                        docker tag myproject:latest \
                            $DOCKER_USERNAME/myproject:latest

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

                        echo "Pulling latest image..."

                        docker pull \
                            $DOCKER_USERNAME/myproject:latest

                        echo "Stopping old container..."

                        docker stop myproject-container || true
                        docker rm myproject-container || true

                        echo "Starting new container..."

                        docker run -d \
                            --name myproject-container \
                            -p 5001:5001 \
                            $DOCKER_USERNAME/myproject:latest

                        docker logout
                    '''
                }
            }
        }

        stage('Health Check') {
            steps {
                sh '''
                    echo "Waiting for application to start..."
                    sleep 5

                    echo "Checking application health..."

                    curl --fail http://localhost:5001

                    echo ""
                    echo "Health Check PASSED!"
                    echo "Application is running successfully."
                '''
            }
        }
    }

    post {
        success {
            echo 'CI/CD Pipeline completed successfully!'
        }

        failure {
            echo 'CI/CD Pipeline failed!'
            echo 'Check the failed stage for details.'
        }
    }
}
