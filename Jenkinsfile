pipeline {
  agent {
    label 'docker-agent'
  }
  stages {
    stage("Gather GitHub Repository") {
      steps {
        git url: 'https://github.com/remahoney/Continuous-Delivery-with-Docker-and-Jenkins-Second-Edition.git', branch: 'master'
        sh ''' 
        cd Chapter08/sample1
        pwd
        ls -l
        chmod +x gradlew
        '''
      }
    }
    stage("Compile") {
      steps {
        sh '''
        cd Chapter08/sample1
        ./gradlew compileJava
        '''
      }
    }
    stage("Unit test") {
      steps {
        sh '''
        cd Chapter08/sample1
        ./gradlew test
        '''
      }
    }
    stage("Code coverage") {
      steps {
        sh '''
        cd Chapter08/sample1
        ./gradlew jacocoTestReport
        ./gradlew jacocoTestCoverageVerification
        '''
      }
    }
    stage("Static code analysis") { 
      steps {
        sh '''
        cd Chapter08/sample1
        ./gradlew checkstyleMain
        '''
      }
    }
    stage("Build") {
      steps {
        sh '''
        cd Chapter08/sample1
        ./gradlew build
        '''
      }
    }
    stage("Docker build") { 
      steps {
        sh "docker build -t remahoney/calculator:${BUILD_TIMESTAMP} ."
      }
    }
    stage("Docker push") { 
      steps {
        sh "docker push remahoney/calculator:${BUILD_TIMESTAMP}"
      }
    }
    stage("Update version") { 
      steps {
        sh "sed -i 's/{{VERSION}}/${BUILD_TIMESTAMP}/g' deployment.yaml"
      }
    }
    stage("Deploy to Staging") {
      steps {
        sh '''
        cd Chapter08/sample1
        kubectl config use-context docker-desktop
        kubectl --insecure-skip-tls-verify apply -f hazelcast.yaml
        kubectl --insecure-skip-tls-verify apply -f deployment.yaml
        kubectl --insecure-skip-tls-verify apply -f service.yaml
        '''
      }
    }
    stage("Acceptance test") { 
      steps {
        sleep 60
        sh "chmod +x acceptance-test.sh && ./acceptance-test.sh"
      }
    }
  }
}
