---
name: setup-git
description: Initialize a Git repository and prepare the project for GitHub by asking for the repo URL.
triggers:
  - "initialize git"
  - "prepare for GitHub"
  - "setup version control"
---

Prompt the user:

> "What is the GitHub repository URL you’d like to push this project to? (e.g., https://github.com/yourusername/your-repo.git)"

Then perform the following steps:

1. Initialize Git:
  git init

2. Create `.gitignore` with typical entries for iOS projects:
  DerivedData/
  *.xcworkspace
  *.xcodeproj/project.xcworkspace/
  *.xcuserdata/
  *.xcuserstate
  build/
  *.pbxuser

3. Create `LICENSE` (MIT):
  MIT License
  (fill in year and name)

4. Confirm `README.md` is present.

5. Stage and commit:
  git add .
  git commit -m "Initial commit"

6. Configure remote and push using the URL provided by the user:
  git remote add origin [USER_PROVIDED_URL]
  git branch -M main
  git push -u origin main

Claude should validate the URL format and confirm before pushing.
