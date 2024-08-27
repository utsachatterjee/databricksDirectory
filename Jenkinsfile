def databricks_deploy(dbx_url, client_id, client_secret,subscription_id, DBX_REPO_MODULE_PATH,TENANT_ID=TENANT_ID ) {
            withCredentials(([
            string(credentialsId: client_secret, variable: 'AZ_CLIENT_SECRET')])){
            sh """#!/bin/bash

            # Set current directory
            DATABRICKS_CLI_PATH=\$(pwd)
            cd ${DBX_REPO_MODULE_PATH}

            # Export databricks host
            export DATABRICKS_HOST="${dbx_url}"

            # Export azure service principal auth
            export ARM_CLIENT_ID="${client_id}"
            export ARM_CLIENT_SECRET="\${AZ_CLIENT_SECRET}"   
            export ARM_TENANT_ID="${TENANT_ID}"
            export ARM_SUBSCRIPTION_ID="${subscription_id}"
            
            echo "starting az login"
            az login --service-principal -u ${client_id} -p ${AZ_CLIENT_SECRET} --tenant ${tenant_id}
            az account set --subscription="${subscription_id}"
            az account show

            for job_name in \$(terragrunt output -json repo | jq -r 'keys[]'); do
                job_id=\$(terragrunt output -json repo | jq -r --arg job_name "\${job_name}" '.[\$job_name]')
                echo "deploying branch ${BRANCH_NAME} to \${DATABRICKS_HOST} \${job_id}"
                \${DATABRICKS_CLI_PATH}/databricks repos update \${job_id} --branch ${BRANCH_NAME}
            done
            
            """
    }
}

pipeline {
    agent {
        node {
            label 'linux'
        }
    }
    options { 
        buildDiscarder logRotator(daysToKeepStr: '14', numToKeepStr: '5')
    }
    parameters {
        separator name: "DESTROY_IMPLEMENTATION", sectionHeader: "Destroy Implementation", separatorStyle: "border-width: 0", sectionHeaderStyle: """background-color: #ec7063; text-align: center padding: 4px; color: #343434; font-size: 22px; font-weight: normal; text-transform: uppercase; font-family: 'Orienta', sans-serif; letter-spacing: 1px; font-style: italic;"""
        booleanParam (description: 'Check if you want to destroy resources related to your features or environments', name: 'TERRAGRUNT_DESTROY', defaultValue: false)
        string description: 'Input the implementation name you wish to destroy', name: 'IMPLEMENTATION_TO_DESTROY', trim: true
        separator name: "DEPLOY_IMPLEMENTATION", sectionHeader: "Deploy Implementation", separatorStyle: "border-width: 0", sectionHeaderStyle: """background-color: #7ea6d3; text-align: center padding: 4px; color: #343434; font-size: 22px; font-weight: normal; text-transform: uppercase; font-family: 'Orienta', sans-serif; letter-spacing: 1px; font-style: italic;"""
        string description: 'Input the implementation name you wish to deploy', name: 'IMPLEMENTATION_TO_DEPLOY', trim: true
        separator name: "RUN_ALL_IMPLEMENTATIONS", sectionHeader: "Deploy All Implementations", separatorStyle: "border-width: 0", sectionHeaderStyle: """background-color: #dbdb8e; text-align: center padding: 4px; color: #343434; font-size: 22px; font-weight: normal; text-transform: uppercase; font-family: 'Orienta', sans-serif; letter-spacing: 1px; font-style: italic;"""
        booleanParam (description: 'Run all implementations', name: 'DEPLOY_ALL' , defaultValue: true)
    }

    environment{

        CONDAPATH  = "/home/jenkins/anaconda3/"
        CONDAENV   = "temp"
        CONDA_PYTHON_VERSION  = "3.10"
        DBX_CLI_VERSION   = "0.212.1"
        BITBUCKET_USER = credentials('bitbucket-app-user')
        BITBUCKET_PWD = credentials('bitbucket-app-password')
        TENANT_ID                   = "<>"
        SBX_DBX_WORKSPACE_URL       = "<>"
        SBX_ARM_CLIENT_ID           = "<>"
        SBX_ARM_SUBSCRIPTION_ID     = "<>"
        SBX_ARM_CLIENT_SECRET_ID    = "<>"
        SBX_REPO_MODULE_PATH        = "./impl/sbx/azure/east-us/repo"
        PRD_DBX_WORKSPACE_URL       = "<>"
        PRD_ARM_CLIENT_ID           = "<>"
        PRD_ARM_SUBSCRIPTION_ID     = "<>"
        PRD_ARM_CLIENT_SECRET_ID    = "<>"
        PRD_REPO_MODULE_PATH        = "./impl/prd/azure/east-us/repo"

    }
    stages {
        stage("Install Dependencies") {
            steps {
                script {
                    sh """#!/bin/bash
                    if ${CONDAPATH}/bin/conda list -n ${CONDAENV}; then
                       ${CONDAPATH}/bin/conda env remove --name ${CONDAENV}
                    fi

                    ${CONDAPATH}/bin/conda create --name ${CONDAENV} python=${CONDA_PYTHON_VERSION}

                    echo "Activating conda ${CONDAENV} environment"
                    source ${CONDAPATH}/bin/activate ${CONDAENV}

                    # Install non-legacy databricks cli
                    echo "Installing databricks cli"
                    curl -Lo databricks_cli_${DBX_CLI_VERSION}_linux_amd64.zip https://github.com/databricks/cli/releases/download/v${DBX_CLI_VERSION}/databricks_cli_${DBX_CLI_VERSION}_linux_amd64.zip
                    curl -Lo databricks.zip.sha256 https://github.com/databricks/cli/releases/download/v${DBX_CLI_VERSION}/databricks_cli_${DBX_CLI_VERSION}_SHA256SUMS

                    if grep 'databricks_cli_${DBX_CLI_VERSION}_linux_amd64.zip' databricks.zip.sha256 | sha256sum -c; then
                        echo "Checksum verification passed for databricks-cli"
                        unzip -o databricks_cli_${DBX_CLI_VERSION}_linux_amd64.zip databricks
                        ./databricks -v
                    else
                        echo "Checksum verification failed for databricks-cli"
                        exit 1
                    fi

                    # Install specific version of terraform, will use .terraform-version file for specific version
                    tfenv install
                    """
                }
            }
        }
        // Nested Stages Block
        stage('Dynamic Destroy ->') {
            when {
                allOf {
                    expression { params.TERRAGRUNT_DESTROY == true }
                    expression { params.IMPLEMENTATION_TO_DESTROY != '' }
                }
            }
            steps {
                script {
                    // feature branch
                    if (env.BRANCH_NAME.startsWith('feature/')) {
                        stage("Destroy Resources for Feature in SBX") {
                            withCredentials([string(credentialsId: '<>', variable: 'SBX_ARM_CLIENT_SECRET')]) {
                                // Run destroy in SBX
                                    sh """#!/bin/bash
                                    export ARM_CLIENT_SECRET=\${SBX_ARM_CLIENT_SECRET}
                                    ./login_and_grunt.sh sbx destroy \${IMPLEMENTATION_TO_DESTROY}
                                    """
                            }
                        }
                    }
                    // develop branch
                    if (env.BRANCH_NAME == 'develop') {
                        stage("Destroy Resources DEV") {
                            withCredentials([string(credentialsId: '<>', variable: 'DEV_ARM_CLIENT_SECRET')]) {
                                // Run destroy DEV
                                sh """#!/bin/bash                             
                                export ARM_CLIENT_SECRET=\${DEV_ARM_CLIENT_SECRET}
                                ./login_and_grunt.sh dev destroy \${IMPLEMENTATION_TO_DESTROY}
                                """
                            }
                        }
                    }
                    // release/next branch
                    if (env.BRANCH_NAME.startsWith('release/')) {
                        stage("Deploy Resources in TST") {
                            withCredentials([string(credentialsId: '<>', variable: 'TST_ARM_CLIENT_SECRET')]) {
                                // Run destroy in TST
                                sh """#!/bin/bash
                                export ARM_CLIENT_SECRET=\${TST_ARM_CLIENT_SECRET}
                                ./login_and_grunt.sh tst destroy \${IMPLEMENTATION_TO_DESTROY}
                                """
                            }
                        }
                    }
                    // main branch
                    if (env.BRANCH_NAME == 'main') {
                        stage("Destroy Resources in PRD") {
                            withCredentials([string(credentialsId: '<>', variable: 'PRD_ARM_CLIENT_SECRET')]) {
                                // Run destroy in PRD
                                sh """#!/bin/bash
                                export ARM_CLIENT_SECRET=\${PRD_ARM_CLIENT_SECRET}
                                ./login_and_grunt.sh prd destroy \${IMPLEMENTATION_TO_DESTROY}
                                """
                            }
                        }
                    }
                }
            }
        }
        // Nested Stages Block
        stage('Pre Build Checks ->'){
            when {
                allOf {
                    expression { params.TERRAGRUNT_DESTROY != true }
                    expression { params.IMPLEMENTATION_TO_DESTROY == '' }
                }
            }
            steps {
                script {
                    // Install specific version of terraform, will use .terraform-version file for specific version
                    stage('Install TFenv') {
                        sh """#!/bin/bash
                        tfenv install
                        """
                    }
                }
            }
        }
        // Nested Stages Block
        stage('Pre Scan and Tests ->'){
            when {
                allOf {
                    expression { params.TERRAGRUNT_DESTROY != true }
                    expression { params.IMPLEMENTATION_TO_DESTROY == '' }
                }
            }
            steps {
                script {
                    // Run IaC Tests
                    stage("Run IaC Tests") {
                        try {
                            sh """#!/bin/bash                           
                            # Auth to Cloud here, store cred session for test.
                            # Pipeline creds that bulkheaded to this team/Product
                            # az login --user  --tenant

                            # Run terratest here. We should look at detecting changes here and running only those possibly. 
                            # Go test will cach on the local host
                            # go test ./... -timeout 10000s -v
                        """
                        } catch(err) {
                            step([$class: 'JUnitResultArchiver', testResults: '--junit-xml=${TESTRESULTPATH}/TEST-*.xml'])
                            if (currentBuild.result == 'UNSTABLE')
                                currentBuild.result = 'FAILURE'
                            throw err
                        }
                    }
                }
            }
        }
        // Nested Stages Block
        stage('Dynamic Build & Deploy ->') {
            when {
                allOf {
                    expression { params.TERRAGRUNT_DESTROY != true }
                    expression { params.IMPLEMENTATION_TO_DESTROY == '' }
                }
            }
            steps {
                script {
                    // feature branch not sandbox
                    if (env.BRANCH_NAME.startsWith('feature') && env.BRANCH_NAME != 'feature/sandbox') {
                        stage("Plan against SBX") {
                            withCredentials([string(credentialsId: '<>', variable: 'SBX_ARM_CLIENT_SECRET')]) {
                                // Run a plan to SBX
                                sh """#!/bin/bash
                                export ARM_CLIENT_SECRET=\${SBX_ARM_CLIENT_SECRET}
                                if [[ \${DEPLOY_ALL} == "true" ]]; then RUN_ALL='-all'; fi
                                ./login_and_grunt.sh sbx plan\${RUN_ALL}
                                """
                            }
                        }
                    }
                    // feature branch sandbox
                    if (env.BRANCH_NAME == 'feature/sandbox') {
                        stage("Deploy SBX") {
                            withCredentials([string(credentialsId: '<>', variable: 'SBX_ARM_CLIENT_SECRET')]) {
                                sh """#!/bin/bash
                                export ARM_CLIENT_SECRET=\${SBX_ARM_CLIENT_SECRET}
                                if [[ \${DEPLOY_ALL} == "true" ]]; then RUN_ALL='-all'; fi
                                ./login_and_grunt.sh sbx plan\${RUN_ALL}
                                ./login_and_grunt.sh sbx apply\${RUN_ALL}  
                                """
                                databricks_deploy(SBX_DBX_WORKSPACE_URL,SBX_ARM_CLIENT_ID, SBX_ARM_CLIENT_SECRET_ID, SBX_ARM_SUBSCRIPTION_ID, SBX_REPO_MODULE_PATH)
                            }
                        }
                    }
                    // develop branch and PR
                    if (env.BRANCH_NAME.startsWith('PR-') && env.CHANGE_TARGET == 'develop') {
                        stage("Validate against Dev") {
                            withCredentials([string(credentialsId: '<>', variable: 'DEV_ARM_CLIENT_SECRET')]) {
                                // Run a plan on PR against Dev
                                sh """#!/bin/bash
                                export ARM_CLIENT_SECRET=\${DEV_ARM_CLIENT_SECRET}
                                if [[ \${DEPLOY_ALL} == "true" ]]; then RUN_ALL='-all'; fi
                                ./login_and_grunt.sh dev plan\${RUN_ALL}                         
                                """
                                databricks_deploy(DEV_DBX_WORKSPACE_URL,DEV_ARM_CLIENT_ID, DEV_ARM_CLIENT_SECRET_ID, DEV_ARM_SUBSCRIPTION_ID, DEV_REPO_MODULE_PATH)
                            }
                        }
                    }
                    if (env.BRANCH_NAME == 'develop') {
                        stage("Deploy Dev") {
                            withCredentials([string(credentialsId: '<>', variable: 'DEV_ARM_CLIENT_SECRET')]) {
                                // Run a plan & apply to DEV
                                sh """#!/bin/bash
                                export ARM_CLIENT_SECRET=\${DEV_ARM_CLIENT_SECRET}
                                if [[ \${DEPLOY_ALL} == "true" ]]; then RUN_ALL='-all'; fi
                                ./login_and_grunt.sh dev plan\${RUN_ALL}
                                ./login_and_grunt.sh dev apply\${RUN_ALL}                              
                                """
                                databricks_deploy(DEV_DBX_WORKSPACE_URL,DEV_ARM_CLIENT_ID, DEV_ARM_CLIENT_SECRET_ID, DEV_ARM_SUBSCRIPTION_ID, DEV_REPO_MODULE_PATH)
                            }
                        }
                    }
                    // release/next branch and PR
                    if (env.BRANCH_NAME.startsWith('PR-') && env.CHANGE_TARGET == 'release/next') {
                        stage("Validate against TST") {
                            withCredentials([string(credentialsId: '<>-tst', variable: 'TST_ARM_CLIENT_SECRET')]) {
                                // Run a plan on PR against TST
                                sh """#!/bin/bash
                                export ARM_CLIENT_SECRET=\${TST_ARM_CLIENT_SECRET}
                                if [[ \${DEPLOY_ALL} == "true" ]]; then RUN_ALL='-all'; fi
                                ./login_and_grunt.sh tst plan\${RUN_ALL}                         
                                """
                                databricks_deploy(TST_DBX_WORKSPACE_URL,TST_ARM_CLIENT_ID, TST_ARM_CLIENT_SECRET_ID, TST_ARM_SUBSCRIPTION_ID, TST_REPO_MODULE_PATH)
                            }
                        }
                    }
                    if (env.BRANCH_NAME.startsWith('release/next')) {
                        stage("Deploy TST") {
                            withCredentials([string(credentialsId: '<>-tst', variable: 'TST_ARM_CLIENT_SECRET')]) {
                                // Run a plan & apply to TST
                                sh """#!/bin/bash
                                export ARM_CLIENT_SECRET=\${TST_ARM_CLIENT_SECRET}
                                if [[ \${DEPLOY_ALL} == "true" ]]; then RUN_ALL='-all'; fi
                                ./login_and_grunt.sh tst plan\${RUN_ALL}
                                ./login_and_grunt.sh tst apply\${RUN_ALL}                                
                                """
                                databricks_deploy(TST_DBX_WORKSPACE_URL,TST_ARM_CLIENT_ID, TST_ARM_CLIENT_SECRET_ID, TST_ARM_SUBSCRIPTION_ID, TST_REPO_MODULE_PATH)
                            }
                        }
                    }
                    // main branch and PR
                    if (env.BRANCH_NAME.startsWith('PR-') && env.CHANGE_TARGET == 'main') {
                        stage("Validate against PRD") {
                            withCredentials([string(credentialsId: '<>-prd', variable: 'PRD_ARM_CLIENT_SECRET')]) {
                                // Run a plan on PR against PRD
                                sh """#!/bin/bash
                                export ARM_CLIENT_SECRET=\${PRD_ARM_CLIENT_SECRET}
                                if [[ \${DEPLOY_ALL} == "true" ]]; then RUN_ALL='-all'; fi
                                ./login_and_grunt.sh prd plan\${RUN_ALL}                         
                                """
                                databricks_deploy(PRD_DBX_WORKSPACE_URL,PRD_ARM_CLIENT_ID, PRD_ARM_CLIENT_SECRET_ID, PRD_ARM_SUBSCRIPTION_ID, PRD_REPO_MODULE_PATH)
                            }
                        }
                    }
                    if (env.BRANCH_NAME == 'main') {
                        stage("Deploy PRD") {
                            withCredentials([string(credentialsId: '<>-prd', variable: 'PRD_ARM_CLIENT_SECRET')]) {
                                // Run a plan & apply to PRD
                                sh """#!/bin/bash
                                export ARM_CLIENT_SECRET=\${PRD_ARM_CLIENT_SECRET}
                                if [[ \${DEPLOY_ALL} == "true" ]]; then RUN_ALL='-all'; fi
                                ./login_and_grunt.sh prd plan\${RUN_ALL}
                                ./login_and_grunt.sh prd apply\${RUN_ALL}                          
                                """
                                databricks_deploy(PRD_DBX_WORKSPACE_URL,PRD_ARM_CLIENT_ID, PRD_ARM_CLIENT_SECRET_ID, PRD_ARM_SUBSCRIPTION_ID, PRD_REPO_MODULE_PATH)
                            }
                        }
                    }
                }
            }
        }
        // Nested Stages Block
        stage('Post Build & Deploy Test ->'){
            when {
                allOf {
                    expression { params.TERRAGRUNT_DESTROY != true }
                    expression { params.IMPLEMENTATION_TO_DESTROY == '' }
                }
            }
            steps {
                script {
                    // Install specific version of terraform, will use .terraform-version file for specific version
                    stage('Run Integration Tests') {
                        sh """#!/bin/bash                        
                        # Need to discuss what we want to run here
                        # Something that checks that services are up
                        """
                    }
                    // Perform Terraform Lint
                    stage('Report Test Results') {
                        sh """#!/bin/bash                        
                        echo "Stubbed for now until we figure out post deploy tests"
                        """
                        //junit "**/reports/junit/*.xml"
                    }
                }
            }
        }
    }
    post {
        // Clean after build
        always {
            cleanWs(cleanWhenNotBuilt: false,
                    deleteDirs: true,
                    disableDeferredWipeout: true,
                    notFailBuild: true,
                    patterns: [[pattern: 'build_cache/**', type: 'EXCLUDE']])
        }
    }
}

