<!-- ABOUT THIS PROJECT -->
# Data Services databricks Job IAC

## Built With

This project is built with the following:

[![Terragrunt][Terragrunt.io]][Terragrunt-url]
[![Terraform][Terraform.io]][Terraform-url]
[![AzureCli][AzureCli.com]][AzureCli-url]
[![Go][Go.dev]][Go-url]

<!-- GETTING STARTED -->
# Getting Started

## Prerequisites

Will need local admin on your machine to do local development

### Install Packages with Nix

1. Install the [Nix Package Manager](https://nixos.org/download) to you system. You'll need admin access to install it initially
2. Verify that a `shell.nix` file exists in the repo
3. Run the following command: `nix-shell`
4. You're done! Nix should have dropped you into a virtual shell and downloaded all the necessary packages to run your product

#### Shell Nix Software Versions

The default versions provided for the product and specified in the `shell.nix` file

|  Software  | Version |
|:----------:|:-------:|
|  terraform |  1.5.5  |
| terragrunt |  0.57.1 |
|  azurecli  |  2.53.0 |
|     go     |   1.21  |
|     jq     |   1.7   |
|   tflint   |  0.48.0 |

### Install Packages Manually

Get the below packages and install them manually to your local machine

- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
- [Terrafrom](https://developer.hashicorp.com/terraform/tutorials/azure-get-started/install-cli)
- [Terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/install/)
- [Tflint](https://github.com/terraform-linters/tflint#installation) for local linting
- [GoLang](https://go.dev/doc/install) for Terratest
- [Jq](https://jqlang.github.io/jq/)

### Product Coding Standards & Style Guide

- [Terraform Style Guide](https://docs.gruntwork.io/guides/style/terraform-style-guide/)

## Setup

These additional steps are needed for a first-time configuration if this was just forked from the template project.

1. Make sure all **prerequisites** are installed, locally
2. Update **README.md** and **CONTRIBUTING.md**, appropriately
3. Update **env.hcl** files with application specific variables
4. Update the **utilities/azlogin/azlogin.json** file with the pertinient information
5. Explore the provided **base starting module** and run tests to check setup
6. Start having fun building your application by adding more `modules/tests` and environment impls

Example steps of building out more of your application IAC:

1. Add a new `modules/azure/compute` if you need a vm in your base vnet and resource group
2. Tests for the compute module can use the base module by defining base and source it relative `../../../base`
3. This can be exanded on with any of your modules, it can also point to branchs via git ref instead of local relative
4. Once you are satisfied with a new module and passing tests add it to your `_common` with its defaults and environemnt vars
5. Lay out impl/env changes with new folder - example `azure/east-us/jenkins_controller`. Pick a logical descriptive folder name
6. Drop in the standard `terragrunt.hcl` file and make sure it point to your new `_common` module

<!-- USAGE EXAMPLES -->
# Usage

## Running Linting Commands

```bash
## How to run terragrunt linting
terragrunt hclfmt

## How to run terraform linting
terraform fmt -recursive

tflint <relative_module_path>
tflint ./modules/azure/vnet/
```

## Running Terratest

```bash
## Env inputs
## These will be project specific. Here is example of two secret terraform variables being set.
export ANSIBLE_GIT_TOKEN = '<AnsibleRepoToken>'
export ANSIBLE_VAULT_PASS = '<VaultPassword>'

## Run all Tests
go test ./... -timeout 1000s -v

## Run specific
go test ./... -timeout 1000s -run <NameofTest> -v
#Examples
go test ./... -timeout 1000s -run TestRGOnlyExample -v
go test ./... -timeout 1000s -run TestRGWithVNetExample -v

## If a test passes locally and you dont make a change it is cached and doesnt rerun. This cleans cache and forces a reruns
go clean -testcache
```

## Running Terragrunt via Utility Script

Requires a LinuxOS, MacOS, Nix Shell, or a Container Image running on a VM. The Jenkinsfile makes use of these commands.

NOTE: Must use service principal

```bash
## Validate the terraform/grunt setup. This will init testing modules and backend
./login_and_grunt.sh <env> <tg_arg> <module>
./login_and_grunt.sh sbx validate      # validate module(s) with changes only
./login_and_grunt.sh sbx validate base # validate specific module
./login_and_grunt.sh sbx validate-all  # validate all modules 

## This will run via a validate, but if you need to regenerate terraform cache and lock files run this
./login_and_grunt.sh sbx init      # init module(s) with changes only
./login_and_grunt.sh sbx init base # init specific module
./login_and_grunt.sh sbx init-all  # init all modules

## If you want to run a plan to see changes before applying. These commands output a tf.plan binary that is consumed by the apply.
./login_and_grunt.sh sbx plan      # plan module(s) with changes only
./login_and_grunt.sh sbx plan base # plan specific module
./login_and_grunt.sh sbx plan-all  # plan all modules

## If you want to run a apply. REQUIRES and plan be run before-hand. (DEPLOYMENT)
./login_and_grunt.sh sbx apply      # apply module(s) with changes only
./login_and_grunt.sh sbx apply base # apply specific module
./login_and_grunt.sh sbx apply-all  # apply all modules

## If you want to destroy infrastructure, CAREFUL. 
./login_and_grunt.sh sbx destroy      # apply module(s) with changes only
./login_and_grunt.sh sbx destroy base # apply specific module (RECOMMEND using when destroying)
./login_and_grunt.sh sbx destroy-all  # apply all modules (use when you want ALL resources destroyes. CAREFUL)

## Use the following command to CHECK formatting all terragrunt and terraform files
./login_and_grunt.sh sbx fmt

## Use the following command to CLEAN terragrunt and terraform cache
./login_and_grunt.sh sbx clean
```

## Running Terragrunt Directly

### Authenticating Via Service Principal

**Windows OS users:**

```powershell
## Powershell Setup
## For cache, set this to avoid windows path char limit.
$env:TERRAGRUNT_DOWNLOAD = 'c:/terragrunt_cache'
# exporting variables need for auth
$env:ARM_CLIENT_ID = "<your_app_registration_client_id>"
$env:ARM_CLIENT_SECRET = "<your_app_registration_client_secret>"
$env:ARM_TENANT_ID="<wcg_tenant_id>"
$env:ARM_SUBSCRIPTION_ID="<wcg_subscription_id>"
# example secrets to pass terraform from environment variables use get_env("ANSIBLE_GIT_TOKEN") in terragrunt hcl
$env:ANSIBLE_GIT_TOKEN = '<AnsibleRepoToken>'
$env:ANSIBLE_VAULT_PASS = '<VaultPassword>'
```

**MacOS, Linux, WSL2 users:**

You'll need to export the ARM variables to your shell to authenticate with a service principal

```bash
# Export variables to authenticate
export ARM_CLIENT_ID="<your_app_registration_client_id>"
export ARM_CLIENT_SECRET="<your_app_registration_client_secret>"
export ARM_TENANT_ID="<wcg_tenant_id>"
export ARM_SUBSCRIPTION_ID="<wcg_subscription_id>"
```

Alternative #1 - Export the ARM variables via sourcing the azlogin.sh script.

```bash
# The command with authenticate and export the ARM variables to your shell. Vars are driven from azlogin.json. export ARM_CLIENT_SECRET first
export ARM_CLIENT_SECRET="<your_app_registration_client_secret>"
source ./utilities/azlogin/azlogin.sh
```

Alternative #2 - Using `shell.nix` and `env.list` file.
NOTE: The shellHooks in `shell.nix` looks for and sources export variables in a file called `env.list`, This file is already added to the .gitignore file

1. Create the `env.list` file and add your variables

    ```bash
    # sample env.list

    # exporting client secret
    export ARM_CLIENT_SECRET="<your_app_registration_client_secret>"
    # Other options DEBUG, ERROR, WARN, TRACE
    export TF_LOG="INFO" 
    # Example TF variable to be read from shell
    export TF_VAR_aks_cluster_name="devsecops-cluster"
    ```

2. Run `nix-shell`

### Authenticating Via User (az login via browser)

NOTE: WILL NOT WORK IF IN A DOCKER CONTAINER

The command opens a browser window and autheticates the user via the azure log in portal

```bash
az login
```

### Terragrunt Commands

```bash
## How to run Deployments
## Depending on where you run from, you get different scope of your action
cd impl/<env> (operates on a whole env)
cd impl/<env>/<cloud> (operates on a whole cloud)
cd impl/<env>/<cloud>/<region> (operates on a whole region)
cd impl/<env>/<cloud>/<module> (operates on a whole module)

## Validate the terraform/grunt setup. This will init testing modules and backend
terragrunt run-all validate

## This will run via a validate, but if you need to regenerate terraform cache and lock files run this
terragrunt run-all init

## if you change a ton of inputs/outputs of modules you may need to run this.
terragrunt run-all refresh

## If you want to run a play to see changes before applying
terragrunt run-all plan
terragrunt run-all apply

## If you want to destroy infrastructure, be aware what directory you are in. It will destroy all within.
terragrunt run-all destroy
```

# Contributing Guidelines

Please see [CONTRIBUTING.md](CONTRIBUTING.md)

# Code of Conduct

Please see [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)

<!-- CONTACT -->
# Contact

**Product Maintainer**: Team Name - <team_email@wcgclinical.com>

**Project Link**: [https://bitbucket.org/wcgclinical/repo_name](https://bitbucket.org/wcgclinical/repo_name/src)

**Template Maintainer**: The [original project template](https://bitbucket.org/wcgclinical/template_cloud_deploy_pattern/src/main/) is maintained by the [Enterprise DevSecOps](enterprise_devsecops@wcgclinical.com) team

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->

[Terraform.io]: https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white
[Terraform-url]: https://www.terraform.io/
[Terragrunt.io]: https://img.shields.io/badge/terragrunt-%235835CC.svg?style=for-the-badge&logo=terragrunt&logoColor=white
[Terragrunt-url]: https://terragrunt.gruntwork.io/
[AzureCli.com]: https://img.shields.io/badge/azure_cli-%230072C6.svg?style=for-the-badge&logo=microsoftazure&logoColor=white
[AzureCli-url]: https://learn.microsoft.com/en-us/cli/azure/install-azure-cli
[Go.dev]: https://img.shields.io/badge/go-%2300ADD8.svg?style=for-the-badge&logo=go&logoColor=white
[Go-url]: https://go.dev/
