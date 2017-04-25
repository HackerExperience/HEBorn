#!/usr/bin/env groovy

node('elm') {
  stage('Pre-build') {
    step([$class: 'WsCleanup'])

    env.BUILD_VERSION = sh(script: 'date +%Y.%m.%d%H%M', returnStdout: true).trim()
    def ARTIFACT_PATH = "${env.BRANCH_NAME}/${env.BUILD_VERSION}"

    checkout scm

    sh 'make setup'

    stash name: 'source', useDefaultExcludes: false
  }
}

parallel(
  'Lint': {
    node('elm') {
      stage('Lint') {
        step([$class: 'WsCleanup'])
        unstash 'source'

        sh 'make lint'
      }
    }
  },
  'Test': {
    node('elm') {
      stage('Test') {
        step([$class: 'WsCleanup'])
        unstash 'source'

        sh 'make test-long'
      }
    }
  },
  'Compile': {
    node('elm') {
      stage('Lint') {
        step([$class: 'WsCleanup'])
        unstash 'source'

        sh 'make release'

        stash 'release'
      }
    }
  }
)

node('!master') {

  stage('Save artifacts') {
    step([$class: 'WsCleanup'])
    unstash 'release'

    sh "aws s3 cp build/release.tar.gz s3://he2-releases/heborn/${env.BRANCH_NAME}/${env.BUILD_VERSION}.tar.gz --storage-class REDUCED_REDUNDANCY"

  }

  if (env.BRANCH_NAME == 'master'){
    lock(resource: 'heborn-deployment', inversePrecedence: true) {
      stage('Deploy') {
        sh "ssh deployer deploy heborn prod --branch master --version ${env.BUILD_VERSION}"
      }
    }
    milestone()
  }
}

