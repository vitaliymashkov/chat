pipeline {
    agent any
    environment {
        VERSION_PREFIX = '0.1'
        GIT_URL = 'github.com/vitaliymashkov/chat'
        BRANCH = 'master'
        GITUSER = credentials('f6a9e767-b103-4249-b04f-dca92e758936')
    }
    stages {

        stage('Set build num') {
            steps {
                sh 'npm install'
                sh "npm version ${env.VERSION_PREFIX}.${env.BUILD_ID}"
                sh "echo 'export const VERSION = \"${env.VERSION_PREFIX}.${env.BUILD_ID}\";' > 'src/version.ts'"
            }
        }


        stage('Make CHANGELOG') {
            steps {
                sh 'chmod 777 ./make_changelog.sh'
                sh 'chmod 777 ./CHANGELOG.md'
                sh "./make_changelog.sh ${env.VERSION_PREFIX}.${env.BUILD_ID} `head -n 1 CHANGELOG.md | awk '{print \$2}'`"
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
                sh "git commit -m \"update version to v${env.VERSION_PREFIX}.${env.BUILD_ID}\""
            }
        }

        stage('Push') {
            when {
                expression {
                    currentBuild.result == null || currentBuild.result == 'SUCCESS'
                }
            }
            steps {
                sh "git push https://${env.GITUSER_USR}:${env.GITUSER_PSW}@${env.GIT_URL}.git"
                sh "git push https://${env.GITUSER_USR}:${env.GITUSER_PSW}@${env.GIT_URL}.git --tags"
            }
        }



        stage('Deploy') {
            when {
                expression {
                    currentBuild.result == null || currentBuild.result == 'SUCCESS'
                }
            }
            steps {
                sshPublisher(publishers: [sshPublisherDesc(configName: 'chat', transfers: [sshTransfer(excludes: '', execCommand: '', execTimeout: 120000, flatten: false, makeEmptyDirs: false, noDefaultExcludes: false, patternSeparator: '[, ]+', remoteDirectory: '', remoteDirectorySDF: false, removePrefix: 'public/', sourceFiles: 'public/**/*')], usePromotionTimestamp: false, useWorkspaceInPromotion: false, verbose: false)])
            }
        }
    }
}