#!/usr/bin/env groovy

// Docker images
@Library('github.com/lamping7/Firmware-ci-lib') _

// ROS tests
def sitl_tests = [
  [
    name: "ROS vtol mission new 1",
    test: "mavros_posix_test_mission.test",
    mission: "vtol_new_1",
    vehicle: "standard_vtol"
  ],
  [
    name: "ROS vtol mission new 2",
    test: "mavros_posix_test_mission.test",
    mission: "vtol_new_2",
    vehicle: "standard_vtol"
  ],
  [
    name: "ROS vtol mission old 1",
    test: "mavros_posix_test_mission.test",
    mission: "vtol_old_1",
    vehicle: "standard_vtol"
  ],
  [
    name: "ROS vtol mission old 2",
    test: "mavros_posix_test_mission.test",
    mission: "vtol_old_2",
    vehicle: "standard_vtol"
  ],
  [
    name: "ROS MC mission box",
    test: "mavros_posix_test_mission.test",
    mission: "multirotor_box",
    vehicle: "iris"
  ],
  [
    name: "ROS offboard att",
    test: "mavros_posix_tests_offboard_attctl.test",
    mission: "",
    vehicle: "iris"
  ],
  [
    name: "ROS offboard pos",
    test: "mavros_posix_tests_offboard_posctl.test",
    mission: "",
    vehicle: "iris"
  ]
]

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
          def tests = [:]

          for (def i = 0; i < sitl_tests.size(); i++) {
            tests.put(sitl_tests[i].name, createSITLTest(sitl_tests[i]))
          }

          parallel tests
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

def createBuildNode(String docker_repo, String target) {
  return {
    node {
      docker.image(docker_repo).inside('-e CCACHE_BASEDIR=${WORKSPACE} -v ${CCACHE_DIR}:${CCACHE_DIR}:rw') {
        stage(target) {
          sh('export')
          checkout scm
          sh('make distclean')
          sh('git fetch --tags')
          sh('ccache -z')
          sh('make ' + target)
          sh('ccache -s')
          sh('make sizes')
          archiveArtifacts(allowEmptyArchive: true, artifacts: 'build/**/*.px4, build/**/*.elf', fingerprint: true, onlyIfSuccessful: true)
          sh('make distclean')
        }
      }
    }
  }
}

def createSITLTest(Map sitl_test) {
  return {
    node {
      docker.image(dockerImages.getROS()).inside('-e CCACHE_BASEDIR=${WORKSPACE} -v ${CCACHE_DIR}:${CCACHE_DIR}:rw') {
        stage(sitl_test.name) {
        try {
            sh('export')
            checkout scm
            sh('make distclean; rm -rf .ros; rm -rf .gazebo')
            sh('git fetch --tags')
            sh('ccache -z')
            sh('make posix_sitl_default')
            sh('make posix_sitl_default sitl_gazebo')
            sh('./test/rostest_px4_run.sh ' + sitl_test.test + ' mission:=' + sitl_test.mission + ' vehicle:=' + sitl_test.vehicle)
            sh('ccache -s')
            sh('make sizes')
            sh('pwd')
          }
          catch (exc) {
            archiveArtifacts(allowEmptyArchive: true, artifacts: '.ros/**/rosunit-*.xml, .ros/**/rostest-*.log')
            //re-throw to Jenkins
            throw(exc)
          }
          finally {
            sh ('pwd')
            sh ('find . -name *.ulg -print -quit')
            sh ('pwd')
            sh ('./Tools/upload_log.py -q --description "${JOB_NAME}: ${STAGE_NAME}" --feedback "${JOB_NAME} ${CHANGE_TITLE} ${CHANGE_URL}" --source CI `find . -name *.ulg -print -quit`')
            sh ('./Tools/ecl_ekf/process_logdata_ekf.py `find . -name *.ulg -print -quit`')
            archiveArtifacts(allowEmptyArchive: true, artifacts: '.ros/**/*.ulg, .ros/**/*.pdf, .ros/**/*.csv')
            sh('make distclean; rm -rf .ros; rm -rf .gazebo')
          }
        }
      }
    }
  }
}
