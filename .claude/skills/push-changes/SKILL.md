---
name: push-changes
description: Push a new commit with optional versioning, changelog update, and git tag creation.
triggers:
  - "commit and push"
  - "publish update"
  - "release build"
---

Steps:

1. Detect git changes:
   Run:
   git status

   If no changes: exit with message  
   If changes exist: continue

2. Ask:
   > “Do you want to tag this as a versioned release?”  
   Suggest a version like:
   - If last tag is `v1.1.2`, suggest `v1.1.3`
   - When choosing the next tag, take into account whether the changes ammount to a patch, minor, or major version.
   - Let user override or enter custom version

3. Run:
   git diff --cached (or full diff if needed)

   Summarize the key changes for the user and ask:
   > “Would you like me to update `CHANGELOG.md` with these?”

   - If yes:
     - If a version was chosen, create a new section in `CHANGELOG.md`:
       ```
       ## [v1.1.3] - 2024-02-09
       ### Added
       - ...
       ### Changed
       - ...
       ### Fixed
       - ...
       ```

     - If `CHANGELOG.md` has a `[Unreleased]` section:
       > “Move existing `[Unreleased]` entries into this new version?”
       - If yes: migrate them under the new tag

     - If no version selected:
       - Prepend under `[Unreleased]`

4. Ask:
   > “What commit message should I use?”  
   (Suggest one if user doesn't provide.)

5. Commit changes:
   git add .
   git commit -m "[message]"

6. If version selected:
   - Update `MARKETING_VERSION` in `project.yml` to match the new version (without the `v` prefix)
   - Run `xcodegen generate` to regenerate the Xcode project
   - Stage the updated `project.yml` and `Pulse.xcodeproj` before committing
   git tag v1.1.3
   git push origin --tags

7. Push:
   git push

8. Confirm success or show any errors.
