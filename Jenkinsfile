def remote = [:]

pipeline {
  agent any
  environment {
    HOST = "compute-2.ru-central1.internal"
    REPO = "anestesia01/bella-go"
    SVC = "server-app"
    PORT = "9100"
    TOKEN = credentials('telegram_token')
    CHAT_ID = "641041957"
    LINK = "<a href=\\\"${BUILD_URL}\\\">${JOB_NAME} #${BUILD_NUMBER}</a>"
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
          def Image = docker.build("${env.REPO}:${env.BUILD_ID}")
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
                  docker run -d -it -p ${env.PORT}:${env.PORT} --name ${env.SVC} "${env.REPO}:${env.BUILD_ID}"
              """
              }
            }
        }
    }
    stage('Check service') {
        steps {
              script {
                  sh """curl -s -o /dev/null -w "%{http_code}" ${env.HOST}:${env.PORT}"""
              }
        }
    }
}
    post {
      success {
        script {
          sh "curl -X POST -H 'Content-Type: application/json' -d '{\"chat_id\": \"${CHAT_ID}\", \"text\": \"${LINK}\n🟢 Deploy succeeded! \", \"parse_mode\": \"HTML\", \"disable_notification\": false}' \"https://api.telegram.org/bot${TOKEN}/sendMessage\""
        }
      }
      failure {
        script {
          sh "curl -X POST -H 'Content-Type: application/json' -d '{\"chat_id\": \"${CHAT_ID}\", \"text\": \"${LINK}\n🔴 Deploy failure! \", \"parse_mode\": \"HTML\", \"disable_notification\": false}' \"https://api.telegram.org/bot${TOKEN}/sendMessage\""
        }
      }
      aborted {
        script {
          sh "curl -X POST -H 'Content-Type: application/json' -d '{\"chat_id\": \"${CHAT_ID}\", \"text\": \"${LINK}\n⚪️ Deploy aborted! \", \"parse_mode\": \"HTML\", \"disable_notification\": false}' \"https://api.telegram.org/bot${TOKEN}/sendMessage\""
        }
      }    
    }
}
