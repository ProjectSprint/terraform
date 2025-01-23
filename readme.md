# ProjectSprint Infrastrucure

## Prerequisite
- [Terraform CLI](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
- Environment Variables (I recommend [direnv](https://direnv.net/) to setup the environment)
    ```bash
    export AWS_ACCESS_KEY_ID=""
    export AWS_SECRET_ACCESS_KEY=""
    export AWS_REGION=""
    export TF_VAR_PROJECTSPRINT_VM_PUBLIC_KEY=""
    ```
## How to start
1. `cd` to `aws/prod`
2. run `terraform init` (only needed at the first time, or when you add a new [Terraform Module](https://developer.hashicorp.com/terraform/language/modules))
3. run `terraform plan -lock=false` to know the changes that will happen to the Infrastrucure
4. (if you are the administrator) run `terraform apply` to execute
## How to contribute
- Fork this project
- `git clone` the forked project
- Do modification that are needed (your ProjectSprint account should be able to run `terraform plan -lock=false`)
- If finished, create a pull request to this repo
