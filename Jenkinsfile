pipeline {
    agent any

    environment {
        // Nombre del proyecto de OpenShift donde se desplegará la aplicación
        OPENSHIFT_PROJECT = 'integracion'
        // Nombre de la aplicación en OpenShift
        APP_NAME = 'mi-app'
        // Nombre de la imagen Docker que se construirá (usando el registro interno de OCP)
        IMAGE_NAME = "${APP_NAME}"
        // Etiqueta para la imagen Docker
        IMAGE_TAG = 'latest'
    }

    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/alegre04/tia.git'
            }
        }

        stage('Build Image') {
            steps {
                script {
                    // Construir la imagen Docker y etiquetarla para el registro interno de OCP usando podman
                    sh "podman build -t ${env.IMAGE_NAME}:${env.IMAGE_TAG} ."

                    // Hacer tag de la imagen para el ImageStream de OpenShift usando podman
                    sh "podman tag ${env.IMAGE_NAME}:${env.IMAGE_TAG} image-registry.openshift-image-registry.svc:5000/${env.OPENSHIFT_PROJECT}/${env.IMAGE_NAME}:${env.IMAGE_TAG}"

                    // Iniciar sesión en el registro interno de OpenShift (si es necesario)
                    openshift.withCluster() {
                        openshift.withProject(env.OPENSHIFT_PROJECT) {
                            // Esto intentará usar las credenciales del ServiceAccount del pod
                            // Si necesitas autenticación explícita, podrías necesitar configurar un secreto
                            // y usar 'podman login' dentro del pod de Jenkins.
                            // Sin embargo, para el registro interno en el mismo clúster, esto suele funcionar.
                        }
                    }

                    // Hacer push de la imagen al registro interno de OpenShift usando podman
                    sh "podman push image-registry.openshift-image-registry.svc:5000/${env.OPENSHIFT_PROJECT}/${env.IMAGE_NAME}:${env.IMAGE_TAG}"
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
