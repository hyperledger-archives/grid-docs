#!groovy

// Copyright (c) 2018 Bitwise IO, Inc.
// Licensed under Creative Commons Attribution 4.0 International License
// https://creativecommons.org/licenses/by/4.0/

// Discard old builds after 31 days
properties([[$class: 'BuildDiscarderProperty', strategy:
        [$class: 'LogRotator', artifactDaysToKeepStr: '',
        artifactNumToKeepStr: '', daysToKeepStr: '31', numToKeepStr: '']],
        pipelineTriggers([cron('H 2 * * *')])]);

node ('master') {
    timestamps {
        // Create a unique workspace so Jenkins doesn't reuse an existing one
        ws("workspace/${env.BUILD_TAG}") {
            stage("Clone Repo") {
                checkout scm
            }

            if (!(env.BRANCH_NAME == 'master' && env.JOB_BASE_NAME == 'master')) {
                stage("Check Whitelist") {
                    readTrusted 'bin/whitelist'
                    sh './bin/whitelist "$CHANGE_AUTHOR" /etc/jenkins-authorized-builders'
                }
            }

            stage("Check for Signed-Off Commits") {
                sh '''#!/bin/bash -l
                    if [ -v CHANGE_URL ] ;
                    then
                        temp_url="$(echo $CHANGE_URL |sed s#github.com/#api.github.com/repos/#)/commits"
                        pull_url="$(echo $temp_url |sed s#pull#pulls#)"

                        IFS=$'\n'
                        for m in $(curl -s "$pull_url" | grep "message") ; do
                            if echo "$m" | grep -qi signed-off-by:
                            then
                              continue
                            else
                              echo "FAIL: Missing Signed-Off Field"
                              echo "$m"
                              exit 1
                            fi
                        done
                        unset IFS;
                    fi
                '''
            }

            stage("Lint website") {
                sh 'docker-compose -f docker/compose/run-lint.yaml up --exit-code-from lint-grid-docs'
                sh 'docker-compose down'
            }

            stage("Build website") {
                sh 'BUILDONLY=true docker-compose up jekyll webserver'
                sh 'BUILDONLY=true docker-compose down'
            }

            stage("Archive Build artifacts") {
            archiveArtifacts artifacts: 'generator/archive/htdocs/**'
            }
        }
    }
}

