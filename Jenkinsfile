pipeline{
    agent any
    tools{
        jdk 'jdk17'
        nodejs 'NodeJs'
    }
    environment {
        SCANNER_HOME=tool 'sonar-scanner'
    }
    stages {
        stage('clean workspace'){
            steps{
                cleanWs()
            }
        }
        stage('Checkout'){
            steps{
                git branch: 'main', url: 'https://github.com/elisemomo/Tetris-game.git'
            }
        }
        stage("Sonarqube Analysis "){
            steps{
                withSonarQubeEnv('sonar-server') {
                    sh ''' $SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=Tetrisgame \
                    -Dsonar.projectKey=Tetrisgame '''
                }
            }
        }
        stage("quality gate"){
           steps {
                script {
                    waitForQualityGate abortPipeline: false, credentialsId: 'sonar-token' 
                }
            } 
        }
        stage('Install Dependencies') {
            steps {
                sh "npm install"
            }
        }
        stage('OWASP FS SCAN') {
            steps {
                dependencyCheck additionalArguments: '--scan ./ --disableYarnAudit --disableNodeAudit', odcInstallation: 'Dependency-Check'
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }
        stage('TRIVY FS SCAN') {
            steps {
                sh "trivy fs . > trivyfs.txt"
            }
        }
        stage("Docker Build and Push"){
            steps{
                script{
                   withDockerRegistry(credentialsId: 'Docker_hub', toolName: 'Docker_hub'){   
                       sh "docker build -t tetrisgame ."
                       //sh "docker tag tetrisgame mukomelise/tetrisgame:latest"
                       sh "docker push mukomelise/tetrisgame:latest"
                    }
                }
            }
        }
        stage("TRIVY SCAN"){
            steps{
                sh "trivy image mukomelise/tetrisgame:latest > trivyimage.txt" 
            }
        }
       stage('Update Deployment File') {
            steps {
                script {
                    withCredentials([string(credentialsId: 'github', variable: 'GITHUB_TOKEN')]) {
                       NEW_IMAGE_NAME = "aakibkhan1212/tetrisv1:latest"  
                       sh "sed -i 's|image: .*|image: $NEW_IMAGE_NAME|' deployment.yml"
                       sh 'git add deployment.yml'
                       sh "git commit -m 'Update deployment image to $NEW_IMAGE_NAME'"
                       sh "git push @github.com/${GIT_USER_NAME}/${GIT_REPO_NAME">https://${GITHUB_TOKEN}@github.com/${GIT_USER_NAME}/${GIT_REPO_NAME} HEAD:main"
                    }
                }
            }
        } 
    }
}
