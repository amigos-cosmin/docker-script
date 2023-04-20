# #!/bin/bash

export AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY"
export AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS"


if [[ "$#" -ne 3 ]]; then
  echo "Error: Invalid number of inputs. Please provide 3 inputs: stack, env, region"
  exit 1
fi

# Inputs
stack="$1"
env="$2"
region="$3"

app="autorama-mgmt-notifier"

# Validate inputs
if [[ "$stack" == "rpa" || "$stack" == "grid" ]]; then
    echo "Valid stack input"
else
    echo "Invalid stack input. Please enter 'rpa' or 'grid'."
    exit 1
fi

if [[ "$env" != "dev" && "$env" != "uat" && "$env" != "prod" ]]; then
  echo "Error: Invalid env input. Please enter 'dev', 'uat', or 'prod'."
  exit 1
fi

if [[ -z "$region" ]]; then
  echo "Error: Region input is required."
  exit 1
fi

# Clone the github repo for the ENV vars copy the file then delete the repo
git clone https://"$GITHUB_USERNAME":"$PAT"@github.com/Autorama/autorama-app-config.git

# Copy the .env file out in the root directory and rename it to .env.server
cp autorama-app-config/env/"$stack"/"$app"/.env."$env" .env.server

# Remove the cloned repo
rm -rf autorama-app-config


# Check if the .env.$env file exists
if [ ! -f .env.server ]; then
  echo "Error: .env.server file not found."
  exit 1
fi

# Install
yarn install --local

# Set aws profile and run sls deploy command
sh -c "REGION=$region sls deploy --stage $env --env server --force --verbose"
 
if [ $? -ne 0 ]; then
  echo "Error: aws-vault failed to execute. Please check the AWS credentials and try again."
  exit 1
fi

