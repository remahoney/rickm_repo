pipeline {
  agent {
    label 'docker-agent'
  }
// triggers {
//   pollSCM('* * * * *')
// }
  stages {
    stage("Gather GitHub Repository") {
      steps {
        git url: 'https://github.com/remahoney/Continuous-Delivery-with-Docker-and-Jenkins-Second-Edition.git', branch: 'master'
        sh "cd Chapter08/sample1"
      }
    }
    stage("Compile") { 
      steps { sh "./gradlew compileJava" }
    }
    stage("Unit test") {
      steps { sh "./gradlew test" }
    }
    stage("Code coverage") { 
      steps {
        sh "./gradlew jacocoTestReport"
        sh "./gradlew jacocoTestCoverageVerification"
      }
    }
    stage("Static code analysis") { 
      steps {
        sh "./gradlew checkstyleMain"
      }
    }
    stage("Build") { 
      steps { sh "./gradlew build" }
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
        sh "kubectl config use-context docker-desktop"
        sh "kubectl --insecure-skip-tls-verify apply -f hazelcast.yaml"
        sh "kubectl --insecure-skip-tls-verify apply -f deployment.yaml"
        sh "kubectl --insecure-skip-tls-verify apply -f service.yaml"
      }
    }
    stage("Acceptance test") { 
      steps {
        sleep 60
        sh "chmod +x acceptance-test.sh && ./acceptance-test.sh"
      }
    }  
 // Performance test stages
    stage("Release") { 
      steps {
        sh "kubectl config use-context gke_remahoney-msit5330_us-east1_hello-cluster"
        sh "kubectl --insecure-skip-tls-verify apply -f hazelcast.yaml"
        sh "kubectl --insecure-skip-tls-verify apply -f deployment.yaml"
        sh "kubectl --insecure-skip-tls-verify apply -f service.yaml"
      }
    }
  }
}
