// CI only. This pipeline stops after the image is published to Docker Hub —
// deployment is performed manually, as required by the lab brief.

pipeline {

    agent any

    options {
        timestamps()
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timeout(time: 20, unit: 'MINUTES')
    }

    environment {
        // <-- CHANGE THIS to your Docker Hub username / repository
        IMAGE_NAME = 'ahsanrizviii/portfolio'
        IMAGE_TAG  = "${env.BUILD_NUMBER}"
        // ID of the "Username with password" credential stored in Jenkins
        DOCKERHUB_CREDENTIALS = 'dockerhub-creds'
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
                sh '''
                    echo "Workspace contents:"
                    ls -la
                    echo "Commit: $(git rev-parse --short HEAD)"
                '''
            }
        }

        stage('Build') {
            steps {
                sh 'docker build -t "$IMAGE_NAME:$IMAGE_TAG" .'
            }
        }

        stage('Tag') {
            steps {
                sh '''
                    docker tag "$IMAGE_NAME:$IMAGE_TAG" "$IMAGE_NAME:latest"
                    docker images "$IMAGE_NAME"
                '''
            }
        }

        stage('Docker Hub Login') {
            steps {
                withCredentials([usernamePassword(
                        credentialsId: "${DOCKERHUB_CREDENTIALS}",
                        usernameVariable: 'DH_USER',
                        passwordVariable: 'DH_PASS')]) {
                    // --password-stdin keeps the token out of the process list
                    // and out of the build log.
                    sh 'echo "$DH_PASS" | docker login -u "$DH_USER" --password-stdin'
                }
            }
        }

        stage('Push') {
            steps {
                sh '''
                    docker push "$IMAGE_NAME:$IMAGE_TAG"
                    docker push "$IMAGE_NAME:latest"
                '''
            }
        }
    }

    post {
        always {
            sh 'docker logout || true'
        }
        success {
            echo """
            ============================================================
            Published ${IMAGE_NAME}:${IMAGE_TAG} and ${IMAGE_NAME}:latest

            Deploy manually on the Docker host:
              docker pull ${IMAGE_NAME}:latest
              docker rm -f portfolio 2>/dev/null || true
              docker run -d --name portfolio -p 8080:80 ${IMAGE_NAME}:latest
            ============================================================
            """
        }
        failure {
            echo 'Pipeline failed. Check the stage above for the first red step.'
        }
    }
}
