node {
  def mvnHome
    def myapp
  agent {
    docker {
      image 'docker:dind'
      args '--user root -v /var/run/docker.sock:/var/run/docker.sock'
    }
  }
 stage('Git Clone') {
        checkout scm: [$class: 'GitSCM', branches: [[name: '*/main']], userRemoteConfigs: [[credentialsId: 'github-cred', url: 'https://github.com/Chandrika-Karri/Jenkins.git']]]
        mvnHome = tool 'maven3.9.5'
    }

    stage('Build') {
        // Run the Maven build
        withEnv(["MVN_HOME=$mvnHome"]) {
            sh '"$MVN_HOME/bin/mvn" -Dmaven.test.failure.ignore clean package'
        }
    }

    stage('Send Slack Notify') {
        slackSend channel: '#devops-engineer', color: 'Green', message: 'Maven build has been Success', teamDomain: 'keyspace-workspace', tokenCredentialId: 'slack-cred', username: 'keyspace-workspace'
    }
    
    stage('Build image') {
        myapp = docker.build("klchandrika/webapps:${BUILD_NUMBER}")
    }

    stage('Push image') {
        docker.withRegistry('https://registry.hub.docker.com', 'docker-cred') {
            myapp.push("${BUILD_NUMBER}")
        }
    }
    stage('Update Kubernetes Manifest') {
    
    sh 'git config --global user.email "chandrika.kovvuri@gmail.com"'
    sh 'git config --global user.name "Chandrika-Karri"'
    sh 'git remote set-url origin https://personalaccesstoken@github.com/Chandrika-Karri/Jenkins.git'
    sh 'git pull origin main'
    sh 'sed -i "s|image: klchandrika/webapps:.*|image: klchandrika/webapps:${BUILD_NUMBER}|g" jen-dm.yml'
    sh 'git add jen-dm.yml'
    sh 'git commit -m "Update Docker image tag in Kubernetes manifest"'
    sh 'git fetch origin'
    sh 'git push https://personalaccesstoken@github.com/Chandrika-Karri/Jenkins.git HEAD:main'
  }
   stage ('Deploy To Eks') {
     withKubeConfig(caCertificate: '', clusterName: 'new-cluster', contextName: 'new-cluster', credentialsId: 'eks-cred', namespace: 'default', restrictKubeConfigAccess: false, serverUrl: 'https://9038EF22F95C26C9008752C7B7B71BF7.gr7.us-east-1.eks.amazonaws.com') {
     sh 'kubectl apply -f jen-dm.yml'
    }
  }
 
}
