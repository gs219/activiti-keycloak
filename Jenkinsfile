pipeline {
    agent {
        label "jenkins-maven"
    }
    environment {
      ORG               = 'activiti'
      APP_NAME          = 'activiti-keycloak'
      CHARTMUSEUM_CREDS = credentials('jenkins-x-chartmuseum')
      GITHUB_CHARTS_REPO    = "https://github.com/Activiti/activiti-cloud-helm-charts.git"
      GITHUB_HELM_REPO_URL = "https://activiti.github.io/activiti-cloud-helm-charts/"
    }
    stages {
      stage('CI Build and push snapshot') {
        when {
          branch 'PR-*'
        }
        environment {
          PREVIEW_VERSION = "0.0.0-SNAPSHOT-$BRANCH_NAME-$BUILD_NUMBER"
          PREVIEW_NAMESPACE = "$APP_NAME-$BRANCH_NAME".toLowerCase()
          HELM_RELEASE = "$PREVIEW_NAMESPACE".toLowerCase()
        }
        steps {
          container('maven') {
            sh 'export VERSION=$PREVIEW_VERSION && skaffold build -f skaffold.yaml'
            // skip building docker image for now
            // sh "jx step post build --image $DOCKER_REGISTRY/$ORG/$APP_NAME:$PREVIEW_VERSION"
             dir("./charts/$APP_NAME") {
               sh "make build"
             }
          }
        }
      }
      stage('Build Release') {
        when {
          branch 'master'
        }
        steps {
          container('maven') {
            // ensure we're not on a detached head
            sh "git checkout master"
            sh "git config --global credential.helper store"

            sh "jx step git credentials"
            // so we can retrieve the version in later steps
            sh "echo \$(jx-release-version) > VERSION"
           
            dir ("./charts/$APP_NAME") {
              sh "make tag"  
              sh "make build"
            }
 
            sh 'export VERSION=`cat VERSION` && skaffold build -f skaffold.yaml'

            sh "jx step post build --image $DOCKER_REGISTRY/$ORG/$APP_NAME:\$(cat VERSION)"
          }
        }
      }
      stage('Promote to Environments') {
        when {
          branch 'master'
        }
        steps {
          container('maven') {
            dir ("./charts/$APP_NAME") {
             // sh 'jx step changelog --version v\$(cat ../../VERSION)'

              // release the helm chart
              sh 'make release'
              sh 'make github'  
              // promote through all 'Auto' promotion Environments
              // sh 'jx promote -b --all-auto --timeout 1h --version \$(cat ../../VERSION) --no-wait'
              sh 'jx step git credentials'
              sh 'make updatebot/push-version'

            }
          }
        }
      }
    }  
    
    post {
        always {
            cleanWs()
        }
    }
}
