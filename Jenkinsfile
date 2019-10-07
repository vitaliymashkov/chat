import java.util.Date

def start = new Date()
def stepStart = new Date()
def err = null

String repo = 'WebUi'  // TODO take from env
String jobInfoShort = "${env.JOB_NAME} ${env.BUILD_DISPLAY_NAME}"
String jobInfo = "${env.JOB_NAME} ${env.BUILD_DISPLAY_NAME} \n${env.BUILD_URL}"
String buildStatus
String timeSpent
String changelog
String commitHash
String commitText

currentBuild.result = "SUCCESS"

env.VERSION_PREFIX = '1.7.4'
if (env.BRANCH_NAME == null) {
    env.BRANCH_NAME = sh(returnStdout: true, script: 'git rev-parse --abbrev-ref HEAD').trim()
}
if (env.BRANCH_NAME == "master") {
    env.ENV = 'prod'
    env.envName = 'Production'
} else if (env.BRANCH_NAME == "master_eu") {
    env.ENV = 'prod_eu'
    env.envName = 'Production EU'
} else if (env.BRANCH_NAME == "staging") {
    env.ENV = 'staging_robo'
    env.envName = 'Staging Robo'
} else if (env.BRANCH_NAME == "dev") {
    env.ENV = 'devsrv'
    env.envName = 'DEV Server'
} else  {
    env.ENV = 'devsrv'
    env.envName = 'DEV Server'
}

pipeline {
    agent {
        node {
            label 'webui-staging'
        }
    }
    stages {
        stage('Checkout') {
            steps {
                sh 'echo "Checkout"'
                echo env.BRANCH_NAME
                checkout scm
                script {
                    stepStart = new Date()
                    changelog = changeLogs()
                    if (changelog) {
                        changelog = "Changes in *${repo}* repository *${env.BRANCH_NAME}* branch detected\n" + changelog
                    } else {
                        commitHash = sh(returnStdout: true, script: 'git rev-parse HEAD').trim().take(7)
                        commitText = sh(returnStdout: true, script: 'git show -s --format=format:"*%s*  _by %an_" HEAD').trim()
                        changelog = "No changes in *${repo}* repository *${env.BRANCH_NAME}* branch detected\n"
                        changelog = changelog + "Building for commit: \n`${commitHash}` ${commitText}"
                    }
                }
                echo changelog
                // slackSend channel: env.SLACK_CHANEL, message: "${changelog}"
                sh "npm version ${env.VERSION_PREFIX}-${env.BUILD_ID} --allow-same-version  --no-git-tag-version"
                sh 'npm install'
            }
            post {
                always {
                    script {
                        timeSpent = "\nTime spent: ${timeDiff(stepStart)}"
                    }
                    // slackSend channel: env.SLACK_CHANEL, message: "Checkout Step ${timeSpent}"
                }
                failure {
                    script {
                        timeSpent = "\nTime spent: ${timeDiff(start)}"
                    }
                    // slackSend channel: env.SLACK_CHANEL, color: 'danger', message: "Build failed: ${jobInfo} ${timeSpent}"
                }
            }
        }
        stage('Tests') {
            when {
                expression {
                    currentBuild.result == null || currentBuild.result == 'SUCCESS'
                }
            }
            steps {
                script {
                    stepStart = new Date()
                }
                sh 'echo "Tests"'
                // slackSend channel: env.SLACK_CHANEL, color: "#439FE0", message: "Tests started: ${jobInfoShort}"
                // sh "npm run test:coverage"
            }
            post {
                always {
                     sh 'echo "always Tests"'
                     script {
                         timeSpent = "\nTime spent: ${timeDiff(stepStart)}"
                     }
                     // slackSend channel: env.SLACK_CHANEL, message: "Tests Step ${timeSpent}"
                }
                failure {
                    script {
                        timeSpent = "\nTime spent: ${timeDiff(start)}"
                    }
                    // slackSend channel: env.SLACK_CHANEL, color: 'danger', message: "Build failed: ${jobInfo} ${timeSpent}"
                }
            }
        }
        stage('Build') {
            when {
                expression {
                    currentBuild.result == null || currentBuild.result == 'SUCCESS'
                }
            }
            steps {
                script {
                    stepStart = new Date()
                }
                sh 'echo "Build"'
                // slackSend channel: env.SLACK_CHANEL, color: "#439FE0", message: "Building started: ${jobInfoShort}"
                sh "npm run build -- --env=${env.ENV}"
            }
            post {
                always {
                     sh 'echo "always Build"'
                     jiraSendBuildInfo site: 'roborecruiter.atlassian.net'
                     script {
                          timeSpent = "\nTime spent: ${timeDiff(stepStart)}"
                     }
                     // slackSend channel: env.SLACK_CHANEL, message: "Build Step ${timeSpent}"
                }
                failure {
                    script {
                        timeSpent = "\nTime spent: ${timeDiff(start)}"
                    }
                    // slackSend channel: env.SLACK_CHANEL, color: 'danger', message: "Build failed: ${jobInfo} ${timeSpent}"
                }
            }
        }
        stage('Publish') {
            when {
                expression {
                    currentBuild.result == null || currentBuild.result == 'SUCCESS'
                }
            }
            steps {
                script {
                    stepStart = new Date()
                }
                sh 'echo "Publish"'
                // slackSend channel: env.SLACK_CHANEL, color: "#439FE0", message: "Publish artifacts started: ${jobInfoShort}"
                // slackSend channel: env.SLACK_CHANEL, color: "#439FE0", message: "${env.envName} (${env.VERSION_PREFIX}-${env.BUILD_ID}) <${env.HOST}RoboCromeExt${env.artifactPrefix}-${env.VERSION_PREFIX}.${env.BUILD_ID}.zip|Zip> | <${env.HOST}RoboCromeExt${env.artifactPrefix}-${env.VERSION_PREFIX}.${env.BUILD_ID}.crx|CRX>"
            }
            post {
                always {
                     sh 'echo "always Publish"'
                     script {
                          timeSpent = "\nTime spent: ${timeDiff(stepStart)}"
                     }
                     // slackSend channel: env.SLACK_CHANEL, message: "Build Step ${timeSpent}"
                }
                failure {
                    script {
                        timeSpent = "\nTime spent: ${timeDiff(start)}"
                    }
                    // slackSend channel: env.SLACK_CHANEL, color: 'danger', message: "Build failed: ${jobInfo} ${timeSpent}"
                }
                success {
                    script {
                        timeSpent = "\nTime spent: ${timeDiff(start)}"
                        if (currentBuild.previousBuild == null) {
                            buildStatus = 'First time build'
                        } else if (currentBuild.previousBuild.result == 'SUCCESS') {
                            buildStatus = 'Build complete'
                        } else {
                            buildStatus = 'Back to normal'
                        }
                    }
                    // slackSend channel: env.SLACK_CHANEL, color: 'good', message: "${buildStatus}: ${jobInfo} ${timeSpent}"
                }
            }
        }
    }
}

def timeDiff(st) {
    def delta = (new Date()).getTime() - st.getTime()
    def seconds = delta.intdiv(1000) % 60
    def minutes = delta.intdiv(60 * 1000) % 60

    return "${minutes} min ${seconds} sec"
}

@NonCPS
def prevBuildLastCommitId() {
    def prev = currentBuild.previousBuild
    def items = null
    def result = null
    if (prev != null && prev.changeSets != null && prev.changeSets.size() && prev.changeSets[prev.changeSets.size() - 1].items.length) {
        items = prev.changeSets[prev.changeSets.size() - 1].items
        result = items[items.length - 1].commitId
    }
    return result
}

@NonCPS
def commitInfo(commit) {
    return commit != null ? "`${commit.commitId.take(7)}`  *${commit.msg}*  _by ${commit.author}_ \n" : ""
}

@NonCPS
def changeLogs() {
    String msg = ""
    def changeLogSets = currentBuild.changeSets

    for (int i = 0; i < changeLogSets.size(); i++) {
        def entries = changeLogSets[i].items
        for (int j = 0; j < entries.length; j++) {
            def entry = entries[j]
            msg = msg + "${commitInfo(entry)}"
        }
    }
    return msg
}
