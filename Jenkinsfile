pipeline {
    agent any

    environment {
        APP_NAME = 'myproject'
        ENV = 'dev'
        CONTAINER_NAME = 'myproject-container'
        IMAGE_NAME = 'myproject'
        DOCKER_REPO = 'srikanthmadhugam/myproject'
	IMAGE_TAG = "build-${BUILD_NUMBER}"   

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

                    docker build \
                        -t $IMAGE_NAME:latest .
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

                        docker tag \
                            $IMAGE_NAME:latest \
                            $DOCKER_REPO:latest

                        docker push \
                            $DOCKER_REPO:latest

                        docker logout
                    '''
                }
            }
        }

        stage('Backup Current Container') {
            steps {
                sh '''
                    echo "Checking current container..."

                    if docker ps -a --format '{{.Names}}' | grep -q "^$CONTAINER_NAME$"; then

                        echo "Saving current image for rollback..."

                        CURRENT_IMAGE=$(docker inspect \
                            --format='{{.Config.Image}}' \
                            $CONTAINER_NAME)

                        echo "$CURRENT_IMAGE" > previous_image.txt

                        echo "Previous image: $CURRENT_IMAGE"

                    else

                        echo "No previous container found."

                        echo "none" > previous_image.txt
                    fi
                '''
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
                        echo "$DOCKER_PASSWORD" | docker login \
                            -u "$DOCKER_USERNAME" \
                            --password-stdin

                        echo "Pulling latest image..."

                        docker pull $DOCKER_REPO:latest

                        echo "Stopping old container..."

                        docker stop $CONTAINER_NAME || true

                        docker rm $CONTAINER_NAME || true

                        echo "Starting new container..."

                        docker run -d \
                            --name $CONTAINER_NAME \
                            -p 5001:5001 \
                            $DOCKER_REPO:latest

                        docker logout
                    '''
                }
            }
        }

        stage('Health Check') {
            steps {
                script {
                    try {
                        sh '''
                            echo "Waiting for application..."
                            sleep 5

                            echo "Checking application health..."

                            curl --fail \
                                http://localhost:5001

                            echo ""
                            echo "Health Check PASSED!"
                        '''

                    } catch (Exception e) {

                        echo "Health Check FAILED!"
                        echo "Starting rollback..."

                        sh '''
                            docker stop $CONTAINER_NAME || true
                            docker rm $CONTAINER_NAME || true

                            PREVIOUS_IMAGE=$(cat previous_image.txt)

                            if [ "$PREVIOUS_IMAGE" != "none" ]; then

                                echo "Restoring previous image..."

                                docker run -d \
                                    --name $CONTAINER_NAME \
                                    -p 5001:5001 \
                                    $PREVIOUS_IMAGE

                                echo "Rollback completed."

                            else

                                echo "No previous version available for rollback."

                            fi
                        '''

                        error("Deployment failed. Rollback completed.")
                    }
                }
            }
        }
    }

    post {
        success {
            echo "================================="
            echo "Deployment SUCCESSFUL"
            echo "Application is healthy"
            echo "================================="
        }

        failure {
            echo "================================="
            echo "Deployment FAILED"
            echo "Rollback was attempted"
            echo "================================="
        }
    }
}
