def VERSION = 'UNKNOWN'

pipeline {
    agent any
    environment {
        VERSION_PREFIX = '0.2.1'
        GIT_URL = 'github.com/vitaliymashkov/chat'
        GITUSER = credentials('f6a9e767-b103-4249-b04f-dca92e758936')
    }
    stages {

        stage('Set build num') {
            steps {
                script {
                    if (env.BRANCH_NAME == 'master') {
                        VERSION = sh(returnStdout: true, script: 'echo ${env.VERSION_PREFIX}')
                    } else {
                        VERSION = sh(returnStdout: true, script: 'echo ${env.VERSION_PREFIX}-DEV.${env.BUILD_ID}')
                    }
                    sh 'npm install'
                    sh "npm version $VERSION"
                    sh "echo 'export const VERSION = \"$VERSION\";' > 'src/version.ts'"
                }
            }
        }


        stage('Make CHANGELOG') {
            when {
                expression {
                    currentBuild.result == null || currentBuild.result == 'SUCCESS'
                }
            }
            steps {
                sh 'chmod 777 ./make_changelog.sh'
                sh 'chmod 777 ./CHANGELOG.md'
                sh "./make_changelog.sh $VERSION `head -n 1 CHANGELOG.md | awk '{print \$2}'`"
            }
        }

        stage('Build') {
            when {
                expression {
                    currentBuild.result == null || currentBuild.result == 'SUCCESS'
                }
            }
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
                sh "git commit -m \"update version to v$VERSION\""
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
                script {
                    if (env.BRANCH_NAME == 'master') {
                        echo "Not apply deploy"
                    } else {
                        sshPublisher(publishers: [sshPublisherDesc(configName: 'chat', transfers: [sshTransfer(excludes: '', execCommand: '', execTimeout: 120000, flatten: false, makeEmptyDirs: false, noDefaultExcludes: false, patternSeparator: '[, ]+', remoteDirectory: '', remoteDirectorySDF: false, removePrefix: 'public/', sourceFiles: 'public/**/*')], usePromotionTimestamp: false, useWorkspaceInPromotion: false, verbose: false)])
                    }
                }
            }
        }
    }
}