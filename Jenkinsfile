#!/usr/bin/env groovy

node('elm') {
  stage('Pre-build') {
    step([$class: 'WsCleanup'])
    
    env.BUILD_VERSION = sh(script: 'date +%Y.%m.%d%H%M', returnStdout: true).trim()
    def ARTIFACT_PATH = "${env.BRANCH_NAME}/${env.BUILD_VERSION}"

    checkout scm

    sh 'gmake prefer-native setup setup-tests'
  }

  stage('Lint') {
    sh 'gmake lint'
  }

  stage('Test') {
    sh 'gmake test-long'
  }

  stage('Compile') {
    withEnv([
      'HEBORN_API_HTTP_URL=https://api.hackerexperience.com/v1',
      'HEBORN_API_WEBSOCKET_URL=wss://api.hackerexperience.com/websocket',
      "HEBORN_VERSION=${env.BUILD_VERSION}"
      ]) {
      sh 'gmake compile release'
      stash 'release'
    }
  }
}

if (env.BRANCH_NAME == 'master') {
  node('!master') {
    stage('Save artifacts') {
      step([$class: 'WsCleanup'])
      unstash 'release'

      sh "aws s3 cp build/release.tar.gz s3://he2-releases/heborn/${env.BRANCH_NAME}/${env.BUILD_VERSION}.tar.gz --storage-class REDUCED_REDUNDANCY"
    }

    lock(resource: 'heborn-deployment', inversePrecedence: true) {
      stage('Deploy') {
        sh "ssh deployer deploy heborn prod --branch master --version ${env.BUILD_VERSION}"
      }
    }
    milestone()
  }
}
