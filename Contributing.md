# Contributing to DGH Debugging Tools

Please try and follows the things that are layed out below as it will make it easier to accept a pull
request however not following the below does not necessarily exclude a pull request from being accepted.

## Git Flow

For [DGH Debugging Tools](https://github.com/DGH2112/Debugging-Tools) I use Git as the version control
but I also use [Git Flow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow)
for the development cycles. The main development is undertaken in the **Development** branch with stable
releases being in the **master**. All pull requests should be made from the **Development** branch,
prefereably using **Feature** branches or **BugFix** branches. I've defined prefixes for these already in
the `.gitconfig` file. You should submit onyl one change per pull request at a time to make it easiler to
review and accept the pull request.

Tools wise, I generally use [Fork](https://fork.dev/) but that does not support Git Flow's **BugFix**
functionality so I drop down to the command prompt to create **BugFix** branches as SourceTree can
_Finish_ any type of open branch in Git Flow.

## Creating Pull Requests

Having not done this before as I've always been the sole contributor to my repositories so I borrowed the
essense of the following from the [DUnitX](https://github.com/VSoftTechnologies/DUnitX) project:

1. Create a [GitHub Account](https://github.com/join);
2. Fork the [DGH Debugging Tools](https://github.com/DGH2112/Debugging-Tools)
   Repository and setup your local repository as follows:
     * [Fork the repository](https://help.github.com/articles/fork-a-repo);
     * Clone your Fork to your local machine;
     * Configure upstream remote to the **Development**
       [DGH Debugging Tools](https://github.com/DGH2112/Debugging-Tools)
       [repository](https://github.com/DGH2112/Debugging-Tools);
3. For each change you want to make:
     * Create a new **Feature** or **BugFix** branch for your change;
     * Make your change in your new branch;
     * **Verify code compiles for ALL supported RAD Studio version (see below) and unit tests still pass**;
     * Commit change to your local repository;
     * Push change to your remote repository;
     * Submit a [Pull Request](https://help.github.com/articles/using-pull-requests);
     * Note: local and remote branches can be deleted after pull request has been accepted.

**Note:** Getting changes from others requires
[Syncing your Local repository](https://help.github.com/articles/syncing-a-fork) with the **Development**
[DGH Debugging Tools](https://github.com/DGH2112/Debugging-Tools) repository. This can happen at any
time.

## Dependencies

[DGH Debugging Tools](https://github.com/DGH2112/Debugging-Tools) has no dependencies.

## Project Configuration

The [DGH Debugging Tools](https://github.com/DGH2112/Debugging-Tools) Open Tools API project uses a
single projects file (`.DPR`) to compile to mutliple versions of RAD Studio by use 2 include files: one
for compiler specific coding and the second to implement the correct suffix for the DLL.

The current code base only supports RAD Studio XE2 and above.

## Rationale

The following is a brief description of the rationale behind
[DGH Debugging Tools](https://github.com/DGH2112/Debugging-Tools). I will hopefully write more later.

This plug-in hooks the IDEs code editor context menu through interception and adds menu items for adding
breakpoints with CodeSite evaluation messages.

regards

David Hoyle Nov 2023.

