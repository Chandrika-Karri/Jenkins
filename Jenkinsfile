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
        checkout scm: [$class: 'GitSCM', branches: [[name: '*/main']], userRemoteConfigs: [[credentialsId: 'github-cred', url: 'https://github.com/kanth868/maven-app.git']]]
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
        myapp = docker.build("kanth868/jenkin-docker:${BUILD_NUMBER}")
    }

    stage('Push image') {
        docker.withRegistry('https://registry.hub.docker.com', 'docker-cred') {
            myapp.push("${BUILD_NUMBER}")
        }
    }
    stage('Update Kubernetes Manifest') {
    
    sh 'git config --global user.email "srikanth33.m@gmail.com"'
    sh 'git config --global user.name "kanth868"'
    sh 'git remote set-url origin https://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@github.com/kanth868/maven-app.git'
    sh 'git pull origin main'
    sh 'sed -i "s|image: kanth868/jenkin-docker:.*|image: kanth868/jenkin-docker:${BUILD_NUMBER}|g" jen-dm.yml'
    sh 'git add jen-dm.yml'
    sh 'git commit -m "Update Docker image tag in Kubernetes manifest"'
    sh 'git fetch origin'
    sh 'git push https://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@github.com/kanth868/maven-app.git HEAD:main'
  }
   stage ('Deploy To Eks') {
     withKubeConfig(caCertificate: '', clusterName: 'new-cluster', contextName: 'new-cluster', credentialsId: 'eks-cred', namespace: 'default', restrictKubeConfigAccess: false, serverUrl: 'https://9038EF22F95C26C9008752C7B7B71BF7.gr7.us-east-1.eks.amazonaws.com') {
     sh 'kubectl apply -f jen-dm.yml'
    }
  }
 
}
