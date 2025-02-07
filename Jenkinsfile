def remote = [:]
pipeline {
  agent any
  environment {
    HOST = "compute-2.ru-central1.internal"
    //DIR = "/var/go-server"
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
          def Image = docker.build("anestesia01/bella-go:${env.BUILD_ID}")
          docker.withRegistry('https://registry-1.docker.io', 'hub_token') {
              Image.push()
        }
        }
      }
    }
    stage('Deploy') {
        steps {
            withCredentials([usernamePassword([usernamePassword(credentialsId: 'hub_token', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
              script {
                sshCommand remote: remote, command: """
                  set -ex ; set -o pipefail
                  docker login -u ${USERNAME} -p ${PASSWORD}
                  docker pull ${env.Image}
              """
          }
          }
        }
    }
  }
}

