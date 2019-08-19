#!/usr/bin/env groovy
// https://github.com/freebsd/freebsd-ci/blob/master/scripts/build/build-test.groovy
// http://stackoverflow.com/a/40294220

// https://JENKINS_HOST/scriptApproval/ - for script approval

import java.util.Date

def start = new Date()
def err = null

String repo = 'lambdaImporter-test'  // TODO take from env
String jobInfoShort = "${env.JOB_NAME} ${env.BUILD_DISPLAY_NAME}"
String jobInfo = "${env.JOB_NAME} ${env.BUILD_DISPLAY_NAME} \n${env.BUILD_URL}"
String buildStatus
String timeSpent
String changelog
String commitHash
String commitText

currentBuild.result = "SUCCESS"

try {

node('webui-staging')  {
    parameters {
        string(name: 'S3_BUCKET', defaultValue: 'ats-contacts-importers-sam-live', description: '')
        string(name: 'S3_PREFIX', defaultValue: 'live', description: '')
        string(name: 'AWS_REGION', defaultValue: 'us-east-1', description: '')
        string(name: 'CAPABILITY', defaultValue: 'CAPABILITY_IAM CAPABILITY_AUTO_EXPAND', description: '')
        string(name: 'SLACK_CHANEL', defaultValue: 'webui_dev_deploy', description: '')
        string(name: 'SAM_TEMPLATE', defaultValue: 'live.yaml', description: '')
        string(name: 'SAM_OUTPUT_TEMPLATE', defaultValue: 'live-packaged.yaml', description: '')
        string(name: 'STACK_NAME', defaultValue: 'ats-importers-live', description: '')
    }
    env.PATH = "/home/ubuntu/.local/bin:/usr/local/bin:${env.PATH}"  // for nodejs projects
    // Mark the code checkout 'stage'
    stage (name : 'Checkout') {
        // Get the code from the repository
        checkout scm
        env.BRANCH_NAME = sh(returnStdout: true, script: 'git rev-parse --abbrev-ref HEAD').trim()
        changelog = changeLogs()
        if (changelog) {
            changelog = "Changes in *${repo}* repository *${env.BRANCH_NAME}* branch detected\n" + changelog
            slackSend channel: params.SLACK_CHANEL, message: "${changelog}"
        } else {
            commitHash = sh(returnStdout: true, script: 'git rev-parse HEAD').trim().take(7)
            commitText = sh(returnStdout: true, script: 'git show -s --format=format:"*%s*  _by %an_" HEAD').trim()
            changelog = "No changes in *${repo}* repository *${env.BRANCH_NAME}* branch detected\n"
            changelog = changelog + "Building for commit: \n`${commitHash}` ${commitText}"
            slackSend channel: params.SLACK_CHANEL, message: "${changelog}"
        }
    }
}

} catch (caughtError) {

    err = caughtError
    currentBuild.result = "FAILURE"

} finally {

    timeSpent = "\nTime spent: ${timeDiff(start)}"

    if (err) {
        slackSend channel: params.SLACK_CHANEL, color: 'danger', message: "Build failed: ${jobInfo} ${timeSpent}"
        throw err
    } else {
        if (currentBuild.previousBuild == null) {
            buildStatus = 'First time build'
        } else if (currentBuild.previousBuild.result == 'SUCCESS') {
            buildStatus = 'Build complete'
        } else {
            buildStatus = 'Back to normal'
        }
        slackSend channel: params.SLACK_CHANEL, color: 'good', message: "${buildStatus}: ${jobInfo} ${timeSpent}"

        slackSend channel: params.SLACK_CHANEL, color: 'good', message: "*${env.BRANCH_NAME}* branch deployed"
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
