pipeline {
  agent {
    docker {
      image 'dlambrig/gradle-agent:latest'
      args '-v /var/run/docker.sock:/var/run/docker.sock'
      alwaysPull true
      customWorkspace '/home/jenkins/.gradle/workspace'
    }
  }
  environment {
    REGISTRY = "https://localhost:5001" // Replace with actual registry address
    REGISTRY_HOST = "localhost:5001" // Replace with actual registry address
    PROJECT_DIR = "Chapter08/sample1"
    IMAGE_NAME = "calculator"
    IMAGE_TAG = "${BUILD_NUMBER}" // Example tag
  }
  stages {
    stage('Checkout code and prepare environment') {
      steps {
        git url: 'https://github.com/remahoney/Continuous-Delivery-with-Docker-and-Jenkins-Second-Edition.git', branch: 'master'
          sh """
            cd ${PROJECT_DIR}
            chmod +x gradlew
            cp $(find build -name \^jar) .
          """
        }
      }
    }
    stage('Build') {
      steps {
        sh """
          set -e
          cd ${PROJECT_DIR}
          ./gradlew build
        """
      }
    }
    stage('Set Variables') {
      steps {
        script {
          if (env.BRANCH_NAME == 'main') {
            IMAGE_NAME = 'calculator'
            IMAGE_TAG = '1.0'
            checkstyleTest = true
          } else if (env.BRANCH_NAME.startsWith('feature/')) {
              IMAGE_NAME = 'calculator-feature'
              IMAGE_TAG = '0.1'
              checkstyleTest = false
          } else if (env.BRANCH_NAME == 'playground') {
              IMAGE_NAME = null
              checkstyleTest = false
          } else {
              error "Unsupported branch: ${env.BRANCH_NAME}"
          }
        }
      }
    }
    stage('Run Tests') {
      steps {
        script {
          sh 'cd ${PROJECT_DIR}'    
          if (checkstyleTest && env.BRANCH_NAME == 'main') {
            sh 'gradlew checkstyleTest'
          }
        }
      }
    }
    stage('Login to Registry and Build Image') {
      steps {
        script {
          withCredentials([usernamePassword(credentialsId: 'docker-registry', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
        sh """
          set -e
          cd ${PROJECT_DIR}
          echo "\$DOCKER_PASS" | docker login \$REGISTRY -u \$DOCKER_USER --password-stdin
          docker build -t ${IMAGE_NAME} .
          docker tag ${IMAGE_NAME} ${REGISTRY_HOST}/${IMAGE_NAME}:${IMAGE_TAG}
          docker push ${REGISTRY_HOST}/${IMAGE_NAME}:${IMAGE_TAG}
        """}
        }
      }
    }
    stage('Build Container') {
      when {
        expression {
          return IMAGE_NAME != null // Skip container creation for 'playground' branch
        }
      }
      steps {
        script {
          sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
        }
      }
    }
    stage('Push to Local Repository') {
      when {
        expression {
          return IMAGE_NAME != null // Skip pushing for 'playground' branch
        }
      }
      steps {
        script {
          sh "docker tag ${IMAGE_NAME}:${IMAGE_TAG} localhost:5001/${IMAGE_NAME}:${IMAGE_TAG}"
          sh "docker push localhost:5001/${IMAGE_NAME}:${IMAGE_TAG}"
        }
      }
    }
  }
}
