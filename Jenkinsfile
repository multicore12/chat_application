pipeline {
    agent any

    stages {
        stage('Preparation') {
            steps {
                script {
                    // Delete all folders in the workspace
                    sh 'rm -rf */'
                }
            }
        }

        stage('Checkout Git Repository') {
            steps {
                script {
                    checkout([$class: 'GitSCM', branches: [[name: '*/main']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[url: 'https://github.com/multicore12/chat_application.git']]])
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Print the content of the workspace for debugging
                    sh 'ls -la'

                    // Get the Jenkins build number
                    def buildNumber = env.BUILD_NUMBER ?: '0'
                    env.BUILD_NUMBER = buildNumber // Set the environment variable for subsequent stages

                    // Build Docker image using the Dockerfile in the project directory and tag it with the version
                    sh "docker build -t dockertrain44/chat:v${buildNumber} ."
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    // Authenticate with Docker Hub using Jenkins credentials
                    withCredentials([usernamePassword(credentialsId: 'docker', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        // Login to Docker Hub
                        sh "echo ${DOCKER_PASSWORD} | docker login -u ${DOCKER_USERNAME} --password-stdin"

                        // Push the Docker image to Docker Hub
                        sh "docker push dockertrain44/chat:v${BUILD_NUMBER}"
                    }
                }
            }
        }

        stage('Update Deployment File') {
            environment {
                GIT_REPO_NAME = "chat_application"
                GIT_USER_NAME = "multicore12"
            }
            steps {
                withCredentials([string(credentialsId: 'github', variable: 'GITHUB_TOKEN')]) {
                    sh '''
                        git config user.email "projectworksdata@gmail.com"
                        git config user.name "${GIT_USER_NAME}"
                        BUILD_NUMBER=${BUILD_NUMBER}
                        sed -i "s/dockertrain44\\/chat.*/dockertrain44\\/chat:${BUILD_NUMBER}/g" deployment.yaml
                        git add deployment.yaml
                        git commit -m "Update deployment image to version ${BUILD_NUMBER}"
                        git push https://${GITHUB_TOKEN}@github.com/${GIT_USER_NAME}/${GIT_REPO_NAME} HEAD:main
                    '''
                }
            }
        }
    }
}
