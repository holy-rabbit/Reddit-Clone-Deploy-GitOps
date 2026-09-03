#!/bin/bash

# Prompt user for commit message with default fallback
read -p "Enter commit message (Press Enter for default 'New Update'): " msg

# Use default message if input is empty
commit_msg="${msg:-New Update}"

echo "==> Staging changes..."
git add .

echo "==> Committing with message: '$commit_msg'..."
git commit -m "$commit_msg"

echo "==> Pushing to origin master:main..."
git push origin master:main

echo "==> Done!"
