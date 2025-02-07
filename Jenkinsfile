def remote = [:]
pipeline {
  agent any
  environment {
    HOST = "89.169.168.67"
    DIR = "/var/go-server"
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
          def Image = docker.build("anestesia01/bella-go:${env.BUILD_ID}")
          Image.push()
      }
    }
  }
}

