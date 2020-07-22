## Lambda DynamoDB Node.js demo

Create a Lambda function zipped and stored in S3 to interact with Dyanmodb.
Also, includes respective IAM roles and custom code versioning scheme. Refer to below for more information.

Quick demo few AWS services and concepts: 

- AWS IAM roles
- AWS DynamoDB Access from Lambda
- Lambda CW logs setup 
- Lambda S3 store 
- Terraform

### Sections

1. [Quick Start](#quick-start)  
2. [Lambda Versioning](#lambda-versioning)  

### Quick Start

1. Setup the environment   
```sh

// setup-env.sh 
export AWS_ACCESS_KEY_ID=<your-aws-key>
export AWS_SECRET_ACCESS_KEY=<your-aws-secret>
export AWS_DEFAULT_REGION=us-east-1

. ./setup-env.sh
```

2. Create Infrastructure  

```sh
terraform init
terraform plan
terraform apply -auto-approve 
```

3. Visit Console and trigger lambda   


### Lambda Versioning 

Created custom versioning of lambda code changes via node.js scripts. The gist of it is when versioning is done through the npm (patch, minor, major) the terraform configuration will pick up changes and push changes based on the version in the `package.json`. 


**Publishing:**
```sh
// Patch
yarn run version:patch

// Minor 
yarn run version:minor

// Major 
yarn run version:major
```

**Deploying:**

```
terraform plan
terraform apply -auto-approve 
```
