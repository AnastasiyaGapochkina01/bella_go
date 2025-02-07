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
    stage('build') {
      steps {
        sshCommand remote: remote, command: """
          set -ex ; set -o pipefail
          cd $DIR
          docker build -t go-server .
        """
      }
    }
  }
}

