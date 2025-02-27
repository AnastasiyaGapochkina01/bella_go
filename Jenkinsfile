def remote = [:]
def git_url = "git@github.com:AnastasiyaGapochkina01/bella_go.git"
pipeline {
  agent any
   parameters {
        gitParameter name: 'branch', type: 'PT_BRANCH', sortMode: 'DESCENDING_SMART', selectedValue: 'NONE', quickFilterEnabled: true
   }
  environment {
    HOST = "158.160.92.181"
    REPO = "anestesia01/bella-go"
    SVC = "go-server"
    PRJ_DIR = "/var/www/go-server"
    //PORT = "9100"
    //TOKEN = credentials('telegram_token')
    //CHAT_ID = "641041957"
    //LINK = "<a href=\\\"${BUILD_URL}\\\">${JOB_NAME} #${BUILD_NUMBER}</a>"
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
    stage('Cloning repo') {
      steps{
        checkout([$class: 'GitSCM', branches: [[name: "${branch}"]], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'jenkins_ssh_key', url: "$git_url"]]])
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
                  sudo docker pull "${env.REPO}:${env.BUILD_ID}"
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
                  cd ${env.PRJ_DIR}
                  sudo git checkout ${branch}
                  sudo git fetch
                  export GO_IMG="${env.REPO}:${env.BUILD_ID}"
                  export SVC_NAME="${env.SVC}"
                  envsubst < compose.tmpl | sudo tee compose.yml
                  docker compose up -d
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
}
