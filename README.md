
README to IMAS Data Dictionary
==============================

Development Workflow
--------------------
In order to get you started on making changes to the Data Dictionary (DD), please follow the steps provided here. These steps adhere to the Development Workflow guidelines for the IMAS DD in particular.

**NOTE:** The IMAS DD has an explicitly different branch structure than the master-develop scheme. The DD does not have a master branch, nor a develop branch. The DD has multiple released versions that allow concurrent development. The development workflow reflects this and the git repository contains major version release branches (release/1, release/2, release/3,..) that co-exist. Before features or bugfixes are included in the release branches, they are developed in branches (called feature/... and bugfix/...).

In short, these are the steps to follow:

1. Open a new issue
2. Open and view the issue in 
3. Start progress on the issue 
4. Create a development branch to address the issue
5. Fetch the latest changes from upstream 
6. Change the source, make commits
7. Push the changes back to upstream

###    1. Open a new issue   
-	Go to jira.iter.org (login if necessary)		
-	Click [Create Issue] button		
-	Select Project: (IMAS Core Components)
-	Selet Type: New Feature (or Improvement, or Bug, or Report)		
-	Select Affected version: (3.0 -- the current)		
-	Select Compnonent: (Data Dictionary)
-	Write a summary
-	Write a description		
-	Submit issue		

###	2. Open and view the issue 			
-	Go to jira.iter.org and login		
-	Click on the JIRA logo or [Dashboards]		
-	You can find your issues in the list		

###	3. Start Progress, when you want to start working on it			
-	Open the issue		
-	Click [Start Progress]		
-	Optionally provide a comment		

###	4. Create a development branch to address the issue			
-	View the issue		
-	Click the [Create Branch] link		
-	You will be transferred to git.iter.org		
-	Login if necessary		
-	Select the repository		
-	Select the branch type (Feature)		
-	Branch from `release/3` (the current)		
-	It will provide a branch name (for this issue: `feature/IMAS-37-document-the-dd-development-workflow`)		
-	It is recommended to keep this name. If not, please provide a name that describes the action taken precisely		
-	Click create branch		

###	5. Get the latest changes from upstream
-	If you haven't got a local git repository: click [Clone] And copy the SSH address		
-	Change to a directory where you will create a new directory that will hold the cloned repository		
-	And run
		`git clone ssh://git@git.iter.org/imas/data-dictionary.git`
-	If you have already a local repo, update to retrieve the new branch:		
-	Run
		`git fetch`

###	6. Modify the source, make commits
-	Be sure you are on the development branch:		
-	Run	
        `git checkout feature/IMAS-37-document-the-dd-development-workflow`
-	Make changes to the source
-   And commit changes to selected files:		
-	Run	
		`git add README.md`
-	Run	
		`git commit -m "add README.md with developement guideline steps"`	# use -m for a short message
-	Repeat step 5 until all necessary changes are committed (locally)		

###	7. Push the changes to upstream			
-	Read the Development Guidelines at this point (e.g. clean up your history before pushing)		
-	Once you are happy, proceed to push the the branch back upstream (after this, you cannot go back and change history)		
-	Be sure you are on the development branch:		
-	Run	
		`git checkout feature/IMAS-37-document-the-dd-development-workflow`
-   To see what will be done with a push:
-   Run
        `git push --dry-run origin`
-   When you agree, run:
        `git push origin`

