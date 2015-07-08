
==============================
README to IMAS Data Dictionary
==============================

Development Workflow
--------------------
In order to get you started on making changes to the Data Dictionary (DD), please follow the steps provided here. These steps adhere to the Development Workflow guidelines for the IMAS DD in particular.

**NOTE:** The IMAS DD has an explicitly different branch structure than the master-develop scheme. The DD does not have a master branch, nor a develop branch. The DD has multiple released versions that allow concurrent development. The development workflow reflects this and the git repository contains major version release branches (release/1, release/2, release/3,..) that co-exist. Before features or bugfixes are included in the release branches, they are developed in branches (called feature/... and bugfix/...).

These are the steps to follow.

**NOTE:** These steps are fully described in the Development Guidelines document. Please read and apply them carefully. 

**NOTE:** This file addresses the issue [IMAS-37](https://jira.iter.org/browse/IMAS-37).

###    1. Open a new issue   
- Go to jira.iter.org (login if necessary)    
- Click [Create Issue] button   
- Select Project: (IMAS Core Components)
- Selet Type: New Feature (or Improvement, or Bug, or Report)   
- Select Affected version: (3.0 -- the current)   
- Select Compnonent: (Data Dictionary)
- Write a summary
- Write a description   
- Submit issue    

### 2. Open and view the issue      
- Go to jira.iter.org and login   
- Click on the JIRA logo or [Dashboards]    
- You can find your issues in the list    

### 3. Start Progress, when you want to start working on it     
- Open the issue    
- Click [Start Progress]    
- Optionally provide a comment    

### 4. Create a development branch to address the issue     
- View the issue    
- Click the [Create Branch] link    
- You will be transferred to git.iter.org   
- Login if necessary    
- Select the repository   
- Select the branch type (Feature)    
- Branch from `release/3` (e.g. the current release/#)    
- It will provide a branch name: e.g. `feature/IMAS-123-add-functionality-xyz` (for this issue: feature/IMAS-37-document-the-dd-development-workflow)   
- It is recommended to keep this name. If not, please provide a name that describes the action taken precisely    
- Click create branch   

### 5. Get the latest changes from upstream
- If you haven't got a local git repository: click [Clone] And copy the SSH address   
- Change to a directory where you will create a new directory that will hold the cloned repository    
- And run
  - `git clone ssh://git@git.iter.org/imas/data-dictionary.git`
- If you have already a local repo, update to retrieve the new branch:    
- Run
  - `git fetch`

### 6. Modify the source, make commits
- Be sure you are on the chosen feature branch:
  - `git checkout feature/IMAS-123-add-functionality-xyz`
- Make changes to the source
- Include changes to next commit:
  - `git add mynewfile.txt changedfile.txt`
  - (for this issue: README.md)
- Make the commit, provide a one-line message with `-m` inluding the issue key (e.g. `IMAS-123`)
  - `git commit -m "IMAS-123: introduce functionality xyz"` (for this issue: "Add README.md with developement guideline steps")
- Repeat this step if needed.

### 7. Pull the changes from upstream
- Fetch the changes:
  - `git fetch origin`
- Merge changes from upstream into your local branch:
  - `git merge origin/feature/IMAS-123-add-functionality-xyz`
- Or, use the pull command (which is equivalent to the two above):
  - `git pull`

### 8. Push your changes to upstream
- Note: Clean up your history before pushing
- Once you are happy, proceed to push the the branch back upstream (note, after this you cannot go back and change history)
- Be sure you are on the chosen feature branch:
  - `git checkout feature/IMAS-123-add-functionality-xyz`
- To see what will be done with a push, run:
  - `git push --dry-run origin`
- When you agree, run:
  - `git push origin`

### 9. Repeat until feature is developed
- Repeat steps 6-8, possibly with other authors
- Until the feature branch is ready to be tested and pulled into release branch.

### 10. Create a Pull request
- Once the feature branch is a satisfactory solution to the issue, ask for inclusion to the release branch
- Update the local release branch:
  - `git fetch origin release/#`
- Rebase the feature branch onto the release branch:
  - `git rebase release/# feature/IMAS-123-add-functionality-xyz`
- Fix any conflicts that arise, commit and 
  - `git rebase --continue`
- Push the branch:
  - `git push origin`
- Login to git.iter.org, find the DD repository and the feature branch
- Click Create Pull request:
  - Source: the feature/IMAS-123-add-functionality-xyz branch 
  - Destination: the release/# branch
  - Reviewers: add your collaborators that need to approve