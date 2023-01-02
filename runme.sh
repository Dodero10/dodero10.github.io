#!/bin/sh

# If a command fails then the deploy stops
set -e

# Build the project
printf "\033[0;32mDeploying updates to GitHub...\033[0m\n"
hugo -D --buildFuture

echo ""

# Commit and push to GitHub Page repository
printf "\033[0;32mGo to /public...\033[0m\n"
cd public
git add .
echo ""
read -p "Enter your commit message: " msg
echo "\033[0;32mCommitting changes...\033[0m\n"
git commit -m "$msg"
git push
echo ""

# Commit and push to site repository
printf "\033[0;32mGo to root...\033[0m\n"
cd ..
git add .
echo ""
read -p "Enter your commit message: " msg
echo "\033[0;32mCommitting changes...\033[0m\n"
git commit -m "$msg"
git push
printf "\033[0;32mChanges are commited and push successfully! Go to https://puda14.github.io to see.\033[0m\n"
printf "\033[0;32mFinishing...\033[0m\n"
