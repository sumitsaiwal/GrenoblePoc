//Picking a build agent labeled "ec2" to run pipeline on
node {
  stage 'Pull from SCM'
  //Passing the pipeline the ID of my GitHub credentials and specifying the repo for my app
  git credentialsId: 'cacee84c-e05a-46c4-ad9e-441a06259a93', url: 'https://github.com/sumitsaiwal/GrenoblePoc.git'
  //stage 'Test Code'
  //sh 'mvn install'

  stage 'Test and Build app'
  //Running the maven build and archiving the war
  sh 'mvn clean package'
  archive 'target/*.war'

  stage 'Package Image'
  //Packaging the image into a Docker image //CloudBees Docker Custom Build Environment Plugin
  def pkg = docker.build ('sumitsaiwal/grenoble', '.')
  
  stage 'Push Image to DockerHub'
  //Pushing the packaged app in image into DockerHub //CloudBees Docker Custom Build Environment Plugin //Docker Plugin
  docker.withRegistry ('https://index.docker.io/v1/', 'cacee84c-e05a-46c4-ad9e-441a06259a93') {
      sh 'ls -lart'
      pkg.push 'docker-demo'
  }
  stage 'Deploy to ECS'
  //Deploy image to staging in ECS

        sh "aws ecs update-service --service staging-game  --cluster staging --desired-count 0"
        timeout(time: 5, unit: 'MINUTES') {
            waitUntil {
                sh "aws ecs describe-services --services staging-game  --cluster staging  > .amazon-ecs-service-status.json"

                // parse `describe-services` output
                def ecsServicesStatusAsJson = readFile(".amazon-ecs-service-status.json")
                def ecsServicesStatus = new groovy.json.JsonSlurper().parseText(ecsServicesStatusAsJson)
                println "$ecsServicesStatus"
                def ecsServiceStatus = ecsServicesStatus.services[0]
                return ecsServiceStatus.get('runningCount') == 0 && ecsServiceStatus.get('status') == "ACTIVE"
            }
        }
        sh "aws ecs update-service --service staging-game  --cluster staging --desired-count 1"
        timeout(time: 5, unit: 'MINUTES') {
            waitUntil {
                sh "aws ecs describe-services --services staging-game --cluster staging > .amazon-ecs-service-status.json"

                // parse `describe-services` output
                def ecsServicesStatusAsJson = readFile(".amazon-ecs-service-status.json")
                def ecsServicesStatus = new groovy.json.JsonSlurper().parseText(ecsServicesStatusAsJson)
                println "$ecsServicesStatus"
                def ecsServiceStatus = ecsServicesStatus.services[0]
                return ecsServiceStatus.get('runningCount') == 1 && ecsServiceStatus.get('status') == "ACTIVE"
            }
        }
        timeout(time: 5, unit: 'MINUTES') {
            waitUntil {
                try {
                    sh "curl http://35.161.54.12:8080/grenoble"
                    return true
                } catch (Exception e) {
                    return false
                }
            }
        }
        echo "easyleave#${env.BUILD_NUMBER} SUCCESSFULLY deployed to http://52.37.74.74:8080/easyleave"
        input 'Does http://35.161.54.12:8080/grenoble look okay?'
}
