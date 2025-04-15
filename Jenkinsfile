pipeline {
    agent any

    environment {
        // Nombre del proyecto de OpenShift donde se desplegará la aplicación
        OPENSHIFT_PROJECT = 'tu-proyecto-openshift'
        // Nombre de la aplicación en OpenShift
        APP_NAME = 'mi-app'
        // Nombre de la imagen Docker que se construirá
        IMAGE_NAME = 'registry.example.com/tu-namespace/${APP_NAME}'
        // Etiqueta para la imagen Docker
        IMAGE_TAG = 'latest'
        // Nombre del secreto de credenciales de Docker en OpenShift (si es necesario)
        DOCKER_REGISTRY_SECRET = 'docker-registry-secret'
    }

    stages {
        stage('Checkout') {
            steps {
                git credentialsId: 'gitlab-credentials', url: 'https://github.com/alegre04/tia.git'
            }
        }

        stage('Build Image') {
            steps {
                script {
                    // Iniciar sesión en el registro de Docker de OpenShift
                    openshift.withCluster() {
                        openshift.withProject(env.OPENSHIFT_PROJECT) {
                            if (env.DOCKER_REGISTRY_SECRET) {
                                openshift.login(DOCKER_REGISTRY_SECRET)
                            }
                        }
                    }

                    // Construir la imagen Docker
                    sh "docker build -t ${env.IMAGE_NAME}:${env.IMAGE_TAG} ."

                    // Hacer push de la imagen al registro de OpenShift
                    openshift.withCluster() {
                        openshift.withProject(env.OPENSHIFT_PROJECT) {
                            sh "docker push ${env.IMAGE_NAME}:${env.IMAGE_TAG}"
                        }
                    }
                }
            }
        }

        stage('Compile Application') {
            steps {
                sh 'mvn clean package'
            }
        }

        stage('Deploy to OpenShift') {
            steps {
                script {
                    openshift.withCluster() {
                        openshift.withProject(env.OPENSHIFT_PROJECT) {
                            // Aplicar el archivo de despliegue de OpenShift
                            openshift.apply("-f", "openshift/deployment.yaml")

                            // Opcional: Aplicar el archivo de servicio de OpenShift
                            // openshift.apply("-f", "openshift/service.yaml")

                            // Esperar a que el despliegue se complete
                            openshift.rolloutStatus("dc/${env.APP_NAME}")
                        }
                    }
                }
            }
        }
    }
}
