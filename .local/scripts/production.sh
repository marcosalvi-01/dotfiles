#!/bin/bash

echo "If you want to use this you have to manually remove the exit, it is here just for safety"
exit 0

# stof script on errors
set -e

echo "Checking out 'file' branch..."
git checkout file

echo "Please update the top-level version to 'main' in pom.xml manually..."
nvim pom.xml

echo "Building the project..."
mvn clean install -DskipTests

echo "Staging changes..."
git add .
git add -f ./target/*.jar

echo "Committing changes..."
git commit -m 'update jar name'

echo "Switching to 'main' branch..."
git checkout main

echo "Merging 'file' branch into 'main'..."
git merge file

echo "Pushing changes to origin/main..."
git push origin

echo "Creating 'production' branch..."
git branch production

echo "Pushing 'production' branch to origin..."
git push --set-upstream origin production

echo "Script execution completed successfully."

