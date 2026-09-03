pipeline {
    agent any

    environment {
        APP_NAME = 'myproject'
        ENV = 'dev'
        CONTAINER_NAME = 'myproject-container'
        DOCKER_REPO = 'srikanthmadhugam/myproject'
        IMAGE_TAG = "build-${BUILD_NUMBER}"
    }

    stages {

        stage('Build') {
            steps {
                sh '''
                    echo "Building $APP_NAME"
                    echo "Environment: $ENV"
                    echo "Build Number: $BUILD_NUMBER"

                    java --version
                    git --version
                    python3 --version
                '''
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
                    echo "Building version: $IMAGE_TAG"

                    docker build \
                        -t $DOCKER_REPO:$IMAGE_TAG .
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

                        echo "Pushing $DOCKER_REPO:$IMAGE_TAG"

                        docker push \
                            $DOCKER_REPO:$IMAGE_TAG

                        docker logout
                    '''
                }
            }
        }

        stage('Get Previous Version') {
            steps {
                script {
                    def previousBuild = currentBuild.previousBuild

                    if (previousBuild != null) {
                        env.PREVIOUS_TAG = "build-${previousBuild.number}"
                        echo "Previous version: ${env.PREVIOUS_TAG}"
                    } else {
                        env.PREVIOUS_TAG = "none"
                        echo "No previous version available."
                    }
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
                        echo "$DOCKER_PASSWORD" | docker login \
                            -u "$DOCKER_USERNAME" \
                            --password-stdin

                        echo "Pulling new version:"
                        echo "$DOCKER_REPO:$IMAGE_TAG"

                        docker pull \
                            $DOCKER_REPO:$IMAGE_TAG

                        echo "Stopping old container..."

                        docker stop $CONTAINER_NAME || true
                        docker rm $CONTAINER_NAME || true

                        echo "Starting new version..."

                        docker run -d \
                            --name $CONTAINER_NAME \
                            -p 5001:5001 \
                            $DOCKER_REPO:$IMAGE_TAG

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

                            echo "Checking application..."

                            curl --fail \
                                http://localhost:5001

                            echo ""
                            echo "Health Check PASSED!"
                        '''

                    } catch (Exception e) {

                        echo "Health Check FAILED!"
                        echo "Starting rollback..."

                        if (env.PREVIOUS_TAG != "none") {

                            withCredentials([usernamePassword(
                                credentialsId: 'docker-hub-creds',
                                usernameVariable: 'DOCKER_USERNAME',
                                passwordVariable: 'DOCKER_PASSWORD'
                            )]) {

                                sh '''
                                    echo "$DOCKER_PASSWORD" | docker login \
                                        -u "$DOCKER_USERNAME" \
                                        --password-stdin

                                    echo "Rolling back to:"
                                    echo "$DOCKER_REPO:$PREVIOUS_TAG"

                                    docker pull \
                                        $DOCKER_REPO:$PREVIOUS_TAG

                                    docker stop $CONTAINER_NAME || true
                                    docker rm $CONTAINER_NAME || true

                                    docker run -d \
                                        --name $CONTAINER_NAME \
                                        -p 5001:5001 \
                                        $DOCKER_REPO:$PREVIOUS_TAG

                                    docker logout

                                    echo "Rollback completed!"
                                '''
                            }

                        } else {

                            echo "No previous version available."
                        }

                        error("Deployment failed. Rollback was attempted.")
                    }
                }
            }
        }
    }

    post {
        success {
            echo "================================"
            echo "DEPLOYMENT SUCCESSFUL"
            echo "Version: $IMAGE_TAG"
            echo "Application is healthy"
            echo "================================"
        }

        failure {
            echo "================================"
            echo "DEPLOYMENT FAILED"
            echo "Rollback was attempted"
            echo "================================"
        }
    }
}
