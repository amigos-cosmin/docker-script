# Use the official Node.js image as the base image
FROM node:14.15.4

# Set the working directory inside the container
WORKDIR /app

# Copy the package.json and yarn.lock files to the container
COPY package.json yarn.lock ./

RUN apt-get update && \
    apt-get install -y git && \
    apt-get install -y awscli && \
    npm install -g serverless && \
    yarn install --local

# Install dependencies
RUN yarn install --frozen-lockfile

# Copy the rest of the application files to the container
COPY . .

# Set the entrypoint to the script
ENTRYPOINT ["/bin/bash", "deploy.sh"]

