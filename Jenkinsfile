def secret = 'sshjenkinteam2'
def server = 'team2@103.127.134.76'
def directory = '/home/team2/wayshub/wayshub-backend'
def branch = 'master'
def namebuild = 'wayshub-backend-prod'
def dockerHubCredentials = 'dockerHubT2'
def dockerHubRepo = 'alfrialdi24/wayshub-backend'

pipeline{
    agent any
    stages{
        stage ('Pull new code'){
           steps{
              sshagent([secret]){
                    sh """ssh -o StrictHostKeyChecking=no ${server} << EOF
                    cd ${directory}
                    git pull origin ${branch}
                    echo "Selesai Pulling!"
                    exit
                    EOF"""
              }
           }
        }

        stage ('Build the code'){
           steps{
              sshagent([secret]){
                    sh """ssh -o StrictHostKeyChecking=no ${server} << EOF
                    cd ${directory}
                    docker build -t {namebuild} .
                    echo "Selesai Building!"
                    exit
                    EOF"""
              }
           }
        }

        stage ('Test the code'){
           steps{
              sshagent([secret]){
                    sh """ssh -o StrictHostKeyChecking=no ${server} << EOF
                        cd ${directory}
                        docker run -d --name testcode -p 5009:5000 ${namebuild}
                        if wget --spider -q --server-response http://127.0.0.1:5009/ 2>&1 | grep '404 Not Found'; then
                            echo "Webserver is up and returning 404 as expected!"
                        else
                            echo "Webserver is not responding with expected 404, stopping the process."
                            docker rm -f testcode
                            exit 1
                       fi 
                       docker rm -f testcode
                       echo "Selesai Testing!"
                       exit
                    EOF"""
              }
           }
        }
        
        stage ('deploy'){
           steps{
              sshagent([secret]){
                    sh """ssh -o StrictHostKeyChecking=no ${server} << EOF
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
                  sshagent([secret]) {
                     sh """ssh -o StrictHostKeyChecking=no ${server} << EOF
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
                discordSend description: 'Sukses Push', footer: '', image: '', link: '', result: 'SUCCESS', scmWebUrl: '', thumbnail: '', title: 'Discord Notif', webhookURL: 'https://discord.com/api/webhooks/1240153086937403503/69pvZz1C_FUnfKFmT8xn_J2cJzThsEdS5NKgR4ySdDChzzANgSShMttNsFzr5WSup84b'
            }
         }
   }
}
