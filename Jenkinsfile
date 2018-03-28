
pipeline {
    agent any
    environment {
        VERSION_PREFIX = '0.1'
        GIT_URL = 'https://github.com/vitaliymashkov/chat.git'
        APP_NAME = 'chat'
        BRANCH = 'master'
    }
    stages {
        stage('checkout') {
            steps {
                checkout([$class: 'GitSCM', branches: [[name: '*/${BRANCH}']], doGenerateSubmoduleConfigurations: false, extensions: [[$class: 'LocalBranch', localBranch: '${BRANCH}']], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'f6a9e767-b103-4249-b04f-dca92e758936', name: 'origin', url: '${GIT_URL}']]])
            }
        }

        stage('Set build num') {
            steps {
                sh 'npm install'
                sh "npm version 0.1.${env.BUILD_ID}"
                sh "echo 'export const VERSION = \"${VERSION_PREFIX}.${env.BUILD_ID}\";' > 'src/version.ts'"
            }
        }


        stage('Make CHANGELOG') {
            steps {
                sh 'chmod 777 ./make_changelog.sh'
                sh 'chmod 777 ./CHANGELOG.md'
                sh "./make_changelog.sh ${VERSION_PREFIX}.${env.BUILD_ID} `head -n 1 CHANGELOG.md | awk '{print \$2}'`"
            }
        }

        stage('Build') {
            steps {
                sh 'npm run build'
            }
        }

        stage('Test') {
            when {
                expression {
                    currentBuild.result == null || currentBuild.result == 'SUCCESS'
                }
            }
            steps {
                echo "Tests not defined"
            }
        }

        stage('Commit') {
            when {
                expression {
                    currentBuild.result == null || currentBuild.result == 'SUCCESS'
                }
            }
            steps {
                sh 'git add .'
                sh "git commit -m \"update version to v${VERSION_PREFIX}.${env.BUILD_ID}\""
            }
        }

        stage('Push') {
            environment {
              GITUSER = credentials('f6a9e767-b103-4249-b04f-dca92e758936')
            }
            when {
                expression {
                    currentBuild.result == null || currentBuild.result == 'SUCCESS'
                }
            }
            steps {
                sh "git push https://${GITUSER_USR}:${GITUSER_PSW}@${GIT_URL}"
                sh "git push https://${GITUSER_USR}:${GITUSER_PSW}@${GIT_URL} --tags"
            }
        }



        stage('Deploy') {
            when {
                expression {
                    currentBuild.result == null || currentBuild.result == 'SUCCESS'
                }
            }
            steps {
                sshPublisher(publishers: [sshPublisherDesc(configName: '${APP_NAME}', transfers: [sshTransfer(excludes: '', execCommand: '', execTimeout: 120000, flatten: false, makeEmptyDirs: false, noDefaultExcludes: false, patternSeparator: '[, ]+', remoteDirectory: '', remoteDirectorySDF: false, removePrefix: 'public/', sourceFiles: 'public/**/*')], usePromotionTimestamp: false, useWorkspaceInPromotion: false, verbose: false)])
            }
        }
    }
}