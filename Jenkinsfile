#!/usr/bin/env groovy

@Library('github.com/lamping7/Firmware-ci-lib') _

pipeline {
  agent none
  stages {

    stage('Style Check') {
      steps {
        script {
          node {
            docker.image(dockerImages.getBase()).inside('-e CCACHE_BASEDIR=$WORKSPACE -v ${CCACHE_DIR}:${CCACHE_DIR}:rw') {
              sh('make submodulesclean')
              sh('make check_format')
            }
          }
        }
      }
    }

    stage('ROS Mission Tests') {
      steps {
        script {
          def test_defs = rosTests.getROSTests()
          def test_nodes = [:]

          for (def i = 0; i < test_defs.size(); i++) {
            test_nodes.put(test_defs[i].name, createSITLTest(test_defs[i]))
          }

          parallel test_nodes
        } // script
      } // steps
    } // ROS Mission Tests

  } // stages

  environment {
    CCACHE_DIR = '/tmp/ccache'
    CI = true
  }
  options {
    buildDiscarder(logRotator(numToKeepStr: '10', artifactDaysToKeepStr: '30'))
    timeout(time: 60, unit: 'MINUTES')
  }
}
