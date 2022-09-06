# Contribution guidelines


## For reviewers 

Procedures for reviewing modifications and extensions of the Data Dictionary can be found in IDM [ITER_D_7TD5Z3](https://user.iter.org/?uid=7TD5Z3). This document explains the Pull-Requests-based workflow and provides a quick how-to on using the web-interface to analyse changes and list the current default reviewers who are representing each of the ITER Members.


## For developers 

**NOTE:** The IMAS DD has an explicitly different branch structure than the usual master-develop scheme. The DD does not have a single `master` and `develop` branch: The DD has multiple released versions for each so-called *major version X*, and associated `master/X` and `develop/X` branches.

After cloning the Data Dictionary repository and creating your `feature` or `bugfix` branch from the main `develop/X` one, start by familiarizing yourself with these documents in IDM:

- Rules and Guidelines for Data Model [ITER_D_YST3MT](https://user.iter.org/?uid=YST3MT)
- Data Dictionary Lifecycle [ITER_D_QQYMUK](https://user.iter.org/?uid=QQYMUK)
- Developer Guide for Data Dictionary [ITER_D_YSR3LJ](https://user.iter.org/?uid=YSR3LJ)

When you have implemented your changes, *commit* them and *push* your branch to the *remote*. When ready to be merged to the main `develop/X` branch, create a *Pull-Request* (PR) after becoming familiar with the PR procedure explained above.

Once `develop/X` has sufficiently evolved, a new release can be prepared by creating a `release/X.Y.Z` branch from it and starting a new PR to `master/X`. Just **before** merging this PR, a signed tag `X.Y.Z` is added by the IO TRO including appropriate release notes.

**NOTE:** Tagging before merging to `master/X` is important to ensure the automated build and deployment of the HTML documentation is done correctly.


## For others

For users and occasional developers for which the steps and rules explained above are too heavy, you can contribute directly by creating *issues* in our [tracker](https://jira.iter.org/projects/IMAS) systems, either for raising bugs, asking questions on ambiguous definitions or for requesting extensions to the IDSs (or even for new IDSs). Make sure to specify `Data Dictionary` as the *component* when creating the issue and leave the *default assignee* so it can be duly associated with the relevant designated person.

As you will be involved later in the Pull-Request that may be associated with your issue (in case any implementation changes are required), make sure to take a look at the reviewers instructions above.

