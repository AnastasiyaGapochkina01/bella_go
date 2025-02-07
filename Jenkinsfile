def remote = [:]
def Image
pipeline {
  agent any
  environment {
    HOST = "compute-2.ru-central1.internal"
    REPO = "anestesia01/bella-go"
    SVC = "server-app"
  }
  stages {
    stage('Configure credentials') {
      steps {
        withCredentials([sshUserPrivateKey(credentialsId: 'jenkins_ssh_key', keyFileVariable: 'private_key', usernameVariable: 'username')]) {
          script {
            remote.name = "${env.HOST}"
            remote.host = "${env.HOST}"
            remote.user = "$username"
            remote.identity = readFile("$private_key")
            remote.allowAnyHosts = true
          }
        }
      }
    }
    stage('Build and Push image') {
      steps {
        script {
          Image = docker.build("${env.REPO}:${env.BUILD_ID}")
          docker.withRegistry('https://registry-1.docker.io', 'hub_token') {
              Image.push()
        }
        }
      }
    }
    stage('Pull image') {
        steps {
            withCredentials([usernamePassword(credentialsId: 'hub_token', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
              script {
                sshCommand remote: remote, command: """
                  set -ex ; set -o pipefail
                  docker login -u ${USERNAME} -p ${PASSWORD}
                  docker pull "${env.REPO}:${env.BUILD_ID}"
              """
              }
            }
        }
    }
    stage('Deploy server') {
        steps {
            withCredentials([usernamePassword(credentialsId: 'hub_token', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
              script {
                sshCommand remote: remote, command: """
                  set -ex ; set -o pipefail
                  docker rm ${env.SVC} --force 2> /dev/null || true
                  docker run -d -it -p 9100:9100 --name ${env.SVC} "${env.REPO}:${env.BUILD_ID}"
              """
              }
            }
        }
    }
  }
}
