name: Terraform CI/CD

on:
  push:
    branches:
      - main
      - dev

  pull_request:

env:
  TF_VERSION: 1.13.0
  TF_WORKSPACE: dev

jobs:

  terraform:

    runs-on: ubuntu-latest

    steps:

    - name: Checkout Code
      uses: actions/checkout@v4

    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v3
      with:
        terraform_version: ${{ env.TF_VERSION }}

    - name: Terraform Init
      run: terraform init

    - name: Select Workspace
      run: |
        terraform workspace select $TF_WORKSPACE || \
        terraform workspace new $TF_WORKSPACE

    - name: Terraform Format
      run: terraform fmt -check

    - name: Terraform Validate
      run: terraform validate

    - name: Terraform Plan
      run: terraform plan -out=tfplan

    - name: Upload Plan
      uses: actions/upload-artifact@v4
      with:
        name: tfplan
        path: tfplan

    - name: Terraform Apply
      if: github.ref == 'refs/heads/main'
      run: terraform apply -auto-approve tfplan
