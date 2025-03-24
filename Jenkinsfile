pipeline {
  agent {
    docker {
      image 'dlambrig/gradle-agent:latest'
      args '-v /var/run/docker.sock:/var/run/docker.sock'
      alwaysPull true
      customWorkspace '/home/jenkins/.gradle/workspace'
    }
  {
  environment {
    REGISTRY = "https://localhost:5001" 
    REGISTRY_HOST = "localhost:5001"
    PROJECT_DIR = "Chapter08/sample1"
    IMAGE_NAME = "calculator"
    IMAGE_TAG = "${BUILD_NUMBER}"
  }
  stages {
    stage('Checkout code and prepare environment') {
      steps {
        git url: 'https://github.com/remahoney/Continuous-Delivery-with-Docker-and-Jenkins-Second-Edition.git', branch: 'master'
          sh """
            cd $PROJECT_DIR
            chmod +x gradlew
            cp $(find build -name \^jar) .
          """
      }
    }
    stage('Initialize Gradlew Build') {
      steps {
        sh """
          set -e
          cd $PROJECT_DIR
          ./gradlew build
        """
      }
    }
    stage('Run Tests') {
      steps {
        script {
          if (env.BRANCH_NAME == 'main') {
            sh '.gradlew checkstyleTest'
        } else if (env.BRANCH_NAME == 'feature' || env.BRANCH_NAME == 'playground') {
            sh './runTests.sh'
        }
      }
    }
    stage('Login to Registry and Build Container') {
      when {
        expression { 
          env.BRANCH_NAME != 'playground' && currentBuild.result == 'SUCCESS'
        }
      }
      steps {
        script {
          withCredentials([usernamePassword(credentialsId: 'docker-registry', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
        sh """
          set -e
          cd ${PROJECT_DIR}
          echo "\$DOCKER_PASS" | docker login \$REGISTRY -u \$DOCKER_USER --password-stdin            
          def IMAGE_NAME = env.BRANCH_NAME == 'main' ? 'calculator' : 'calculator-feature'
          def IMAGE_TAG = env.BRANCH_NAME == 'main' ? '1.0' : '0.1'
          docker build -t repository/${IMAGE_NAME}:${IMAGE_TAG} .
          docker tag ${IMAGE_NAME} ${REGISTRY_HOST}/${IMAGE_NAME}:${IMAGE_TAG}
          docker push repository/${IMAGE_NAME}:${IMAGE_TAG}
        """
        }
      }
    }
  }
  post {
    always {
      echo 'Pipeline Execution Complete'
    }
  }
}
