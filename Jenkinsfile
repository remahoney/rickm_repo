pipeline {
  agent any
  stages {
    stage('Checkout code and prepare environment') {
      steps {
        git url: 'https://github.com/remahoney/Continuous-Delivery-with-Docker-and-Jenkins-Second-Edition.git', branch: 'master'
        sh """
          cd Chapter08/sample1
          chmod +x gradlew
        """
      }
    }
    stage("Run initial test and jacoco tests") {
      steps {
        sh """
          cd Chapter08/sample1
          ./gradlew test
          ./gradlew jacocoTestReport
          ./gradlew jacocoTestCoverageVerification
        """
      }
    }
    stage("Run checkstyleTest, codecoverage, and checkstyle tests") {
      steps {
        sh """
          cd Chapter08/sample1
          ./gradlew checkstyleTest
          #./gradlew CodeCoverage
          #./gradlew checkstyle
        """
      }
    }
    stage("Perform Conditional Tests if a Failure") {
      when {
        expression { currentBuild.result == 'FAILURE' }
      }
      steps {
        echo 'currentBuild failed'
      }
    }
    stage("Perform Conditional Tests if a Success") {
      when {
        expression { currentBuild.result == 'SUCCESS' }
      }
      steps {
        echo 'currentBuild succeeded'
      }
    }
  }
}
post {
  success {
    echo 'pipeline ran perfectly'
  }
  failure {
    echo 'pipeline failure'
  }
  publishHTML (
    target [
      reportDir: 'Chapter08/sample1/build/reports/tests/test',
      reportFiles: 'index.html',
      reportName: "JaCoCo Report"
    ]
  publishHTML (
    target: [
      reportDir: 'Chapter08/sample1/build/reports/tests/test',
      reportFiles: 'index.html',
      reportName: "jacoco checkstyle"
    ]
  )
}
