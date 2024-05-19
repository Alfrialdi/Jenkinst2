def secret = 'sshjenkinteam2'
def server = 'team2@103.127.134.76'
def directory = '/home/team2/wayshub-backend'
def branch = 'master'
def namebuild = 'wayshub-backend:1.0'
def dockerHubCredentials = 'dockerHubT2'
def dockerHubRepo = 'alfrialdi24/wayshub-backend'

pipeline{
    agent any
    stages{
        stage ('pull new code'){
           steps{
              sshagent([secret]){
                    sh """ssh -o StricHostKeyChecking=no ${server} << EOF
                    cd ${directory}
                    git pull origin ${branch}
                    echo "Selesai Pulling!"
                    exit
                    EOF"""
              }
           }
        }

        stage ('build the code'){
           steps{
              sshagent([secret]){
                    sh """ssh -o StricHostKeyChecking=no ${server} << EOF
                    cd ${directory}
                    docker build -t {namebuild} .
                    echo "Selesai Building!"
                    exit
                    EOF"""
              }
           }
        }

        stage ('test the code'){
           steps{
              sshagent([secret]){
                    sh """ssh -o StricHostKeyChecking=no ${server} << EOF
                        cd ${directory}
                        docker run -d --name -testcode -p 5009:5000 ${namebuild}
                        if wget --spider -q --server-response http://127.0.0.1:5009/ 2>&1 | grep '404 Not Found'; then
                            echo "Webserver is up and returning 404 as expected!"
                        else
                            echo "Webserver is not responding with expected 404, stopping the process."
                            docker rm -f testcode
                            exit 1
                       fi 
                       docker rm -f tescode
                       echo "Selesai Testing!"
                       exit
                    EOF"""
              }
           }
        }
        
        stage ('deploy'){
           steps{
              sshagent([secret]){
                    sh """ssh -o StricHostKeyChecking=no ${server} << EOF
                    cd ${directory}
                    docker compose down
                    docker compose up -d
                    echo "Selesai Deploy!"
                    exit
                    EOF"""
              }
           }
        }

        stage('push to Docker Hub'){
           steps{
              withCredentials([usernamePassword(credentialsId: dockerHubCredentials, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                sshagant ([secret]) {
                    sh """ ssh -o StricHostKeyChecking=no ${server} << EOF
                    cd ${directory}
                    echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                    docker tag ${namebuild} ${dockerHubRepo}:latest
                    docker push ${dockerHubRepo}:latest
                    echo "Selesai Push ke Docker Hub!"
                    exit
                    EOF"""
                }
              }
            }
         }

         stage ('push notif to discord') {
            steps{
                discordSend description: 'test desc', footer: '', image: '':, link: '', result: 'SUCCESS', scmWebUrl: '', thumbnaik: '', title: 'Discord Notif', webhookURL: ''
            }
         }
   }
}
