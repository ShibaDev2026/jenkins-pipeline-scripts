def call(Map config = [:]) {
    def githubCredentials = config.githubCredentials ?: error('githubCredentials is required')

    pipeline {
        agent {
            label 'docker-agent'
        }

        options {
            timestamps()
            disableConcurrentBuilds()
        }

        environment {
            GITHUB_CREDENTIALS = credentials("${githubCredentials}")
            CD_ENABLED          = 'false'
        }

        stages {
            stage('Checkout') {
                steps {
                    checkout scm
                }
            }

            stage('CI') {
                steps {
                    sh """
                        bash \${WORKSPACE}@libs/jenkins-pipeline/resources/scripts/ci.sh
                    """
                }
            }

            stage('CD') {
                when {
                    expression { env.CD_ENABLED == 'true' }
                }
                steps {
                    sh """
                        bash \${WORKSPACE}@libs/jenkins-pipeline/resources/scripts/cd.sh
                    """
                }
            }
        }

        post {
            always {
                cleanWs()
            }
            success {
                echo "Pipeline SUCCESS — ${env.JOB_NAME} #${env.BUILD_NUMBER}"
            }
            failure {
                echo "Pipeline FAILED — ${env.JOB_NAME} #${env.BUILD_NUMBER}"
            }
        }
    }
}
