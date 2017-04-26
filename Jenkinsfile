#!/usr/bin/env groovy

node('elm') {
  stage('Pre-build') {
    step([$class: 'WsCleanup'])

    env.BUILD_VERSION = sh(script: 'date +%Y.%m.%d%H%M', returnStdout: true).trim()
    def ARTIFACT_PATH = "${env.BRANCH_NAME}/${env.BUILD_VERSION}"

    checkout scm

    sh 'gmake setup'

    stash name: 'source', useDefaultExcludes: false
  }
}

parallel(
  'Lint': {
    node('elm') {
      stage('Lint') {
        step([$class: 'WsCleanup'])

        unstash 'source'

        sh 'gmake lint'
      }
    }
  },
  'Test': {
    node('elm') {
      stage('Test') {
        step([$class: 'WsCleanup'])

        unstash 'source'
        // `stash` won't keep file permissions (why??)
        // so we have to fix them here
        sh 'chmod +x node_modules/.bin/*'

        sh 'gmake test-long'
      }
    }
  },
  'Compile': {
    node('elm') {
      stage('Compile') {
        step([$class: 'WsCleanup'])

        unstash 'source'
        // `stash` won't keep file permissions (why??)
        // so we have to fix them here
        sh 'chmod +x node_modules/.bin/*'

        // Reuse existing compiled files
        sh 'cp -r ~/.elm/elm-stuff/* elm-stuff/'

        sh 'gmake compile'
        sh 'gmake release'

        // Backup compiled files for later reuse
        // TODO: It's being saved but it's not actually working, not sure why
        sh 'rm -rf ~/.elm/elm-stuff/* && cp -r elm-stuff/* ~/.elm/elm-stuff'

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

