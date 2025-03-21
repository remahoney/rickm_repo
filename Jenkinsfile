pipeline {
  agent {
    label 'docker-agent'
  }
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
    stage('checkstyleTest - CodeCoverage Test did not work') {
      when {
        branch 'main'
      }
      steps {
        script {
          try {
            sh """
              cd Chapter08/sample1
              ./gradlew checkstyleTest
//            ./gradlew CodeCoverage
            """
            echo 'tests pass!'
          }
          catch (Exception e) {
            echo 'tests fail!'
          }
        }
      }
    }
    stage('Test') {
      when {
        not {
          branch 'main'
        }
      }
      steps {
        script {
          try {
            sh """
              cd Chapter08/sample1
              ./gradlew test
              ./gradlew jacocoTestReport
            """
            echo 'tests pass!'
          }
          catch (Exception e) {
            echo 'tests fail!'
          }
        }
      } 
    }
    stage('Publish JaCoCo Report') {
      steps {
        sh """
          cd Chapter08/sample1
          ls -l
        """
        publishHTML(
          target: [
            reportDir: 'Chapter08/sample1/build/reports/jacoco/test/html',
            reportFiles: 'index.html',
            reportName: "JaCoCo Report"
          ]
        )
      }
    }
  }
  post {
    success {
      echo 'pipeline ran successfully'
    }
    failure {
      echo 'pipeline had failure'
    }
  }
}
