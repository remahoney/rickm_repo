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
    stage('Run tests and generate reports') {
      steps {
        sh """
          cd Chapter08/sample1
          ./gradlew test
          ./gradlew jacocoTestReport
          ./gradlew jacocoTestCoverageVerification
        """
        publishHTML (
          target: [
            reportDir: 'Chapter08/sample1/build/reports/tests/test',
            reportFiles: 'index.html',
            reportName: "JaCoCo Report"
          ]
        )
      }
    }
    stage("Run and generate report named jacoco checkstyle") {
      steps {
        sh """
          cd Chapter08/sample1
          ./gradlew checkstyleTest
        """
        publishHTML (
          target: [
            reportDir: 'Chapter08/sample1/build/reports/tests/test',
            reportFiles: 'index.html',
            reportName: "jacoco checkstyle"
          ]
        )
      }
    }
  }
}
