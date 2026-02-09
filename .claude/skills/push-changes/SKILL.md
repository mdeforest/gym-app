---
name: push-changes
description: Prepare and push a new commit by reviewing diffs, updating the changelog, prompting for commit message, and optionally tagging a release.
triggers:
  - "push to GitHub"
  - "commit and push"
  - "publish update"
---

Steps:

1. Run:
   git status

2. If uncommitted changes exist:
   - Run: git diff --cached (or git diff if nothing staged)

3. Summarize the changes.
   Ask the user:
   > “Would you like me to update CHANGELOG.md with the following summary?”

   - If yes:
     - Prepend to CHANGELOG.md under a section like:
       ## [Unreleased]
       ### Added
       - [feature summary]
       ### Changed
       - [modified behavior]
       ### Fixed
       - [bug fixes]

4. Ask:
   > “What commit message should I use?”  
   (Optionally suggest one based on diff.)

5. Run:
   git add .
   git commit -m "[message]"

6. Ask:
   > “Would you like to tag this commit with a version number (e.g., v1.2.0)?”

   - If yes:
     git tag v[version]
     git push origin --tags

7. Push the changes:
   git push

8. Confirm success or display error output if push fails.
