pipeline {
    
 // options {
 //   ansiColor('xterm')
 // }
  
  environment {
    dockerimagename = "vladreamer/myweb"
    dockerImage = ""
  }

  agent {
    kubernetes {
      yaml '''
        apiVersion: v1
        kind: Pod
        spec:
          containers:
          - name: kubectl
            image: alpine/k8s:1.28.14
            command:
            - /bin/cat
            tty: true 
          - name: docker
            image: docker:latest
            command:
            - /bin/cat
            tty: true
            volumeMounts:
             - mountPath: /var/run/docker.sock
               name: docker-sock
          volumes:
          - name: docker-sock
            hostPath:
              path: /var/run/docker.sock    
        '''
    }
  }
  stages {
    stage('Checkout Source') {
      steps { 
        echo 'Checkout..'
        container('docker') {
        git branch: 'main',
                url: 'https://github.com/vladreamer/jenkins-kub-deployment.git'

        sh "ls -lat"
        }
      }
    }
    stage('Build-Docker-Image') {
      steps{
        echo 'Building..'
        container('docker') {
         script {
           dockerImage = docker.build dockerimagename + ":$BUILD_NUMBER"
          }
        }
      }
    }
    
    stage('Pushing Image') {
      environment {
              registryCredential = 'dockerhub-credentials'
           }
      steps{
        container('docker') {
         script {
          docker.withRegistry( 'https://registry.hub.docker.com', registryCredential ) {
          dockerImage.push()
            }
          }
        } 
      }
    }
    //stage('Deploying React.js container to Kubernetes') {
    //  steps {
    //    script {
    //      kubernetesDeploy(configs: "deployment.yaml", "service.yaml")
    //    }
    //  }
    //}
    stage('Deploy App to Kubernetes') {     
      steps {
        container('kubectl') {
          withCredentials([string(credentialsId: 'mykubeconfig', variable: 'jenkins')]) {
            sh 'sed -i "s/<TAG>/${BUILD_NUMBER}/" myweb.yaml'
            sh 'kubectl apply -f myweb.yaml'
          }
        }
      }
    }   
    
  }  
    post {
      always {
        container('docker') {
          sh 'docker logout'
         }
       }
     }
}
