# Contributing to Hyperledger Grid

<!--
  Copyright (c) 2018-2019, Bitwise IO, Inc.
  Copyright (c) 2015-2017, Intel Corporation.
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->

We welcome your help with Hyperledger Grid. Contributions from the development
community help improve the design and capabilities of Hyperledger Grid. These
contributions are the best way to make a positive impact on the project.

Ways you can contribute:

* Bugs or issues: Report problems or defects found when working with Grid

* Core features and enhancements for
  [hyperledger/grid](https://github.com/hyperledger/grid):
  Provide expanded capabilities or optimizations

* Features and enhancements for
  [hyperledger/grid-contrib](https://github.com/hyperledger/grid-contrib):
  Contribute new example apps, demos, and smart contracts, or help with
  existing ones

* Documentation: Improve existing documentation or create new information

* Tests for events and results: Add functional, performance, or scalability
  tests

Hyperledger Grid issues are tracked in Github Projects (see
[Using Github Projects]({% link community/issue_tracking.md %})).
Any unassigned items are probably still open. When in doubt, ask on
the [#grid](https://chat.hyperledger.org/channel/grid) chat channel about
a specific issue (see
[Joining the Discussion]({% link community/join_the_discussion.md %})).

## The Commit Process

Hyperledger Grid is Apache 2.0 licensed and accepts contributions via
[GitHub](https://github.com/hyperledger/grid) pull requests. When contributing
code, please follow these guidelines:

* Fork the repository and make your changes in a feature branch

* Include unit and integration tests for any new features and updates to
  existing tests

* Ensure that the unit and integration tests run successfully.

* Check that the lint tests pass.

### Pull Request Guidelines

A pull request can contain a single commit or multiple commits. The most
important guideline is that a single commit should map to a single fix or
enhancement. Here are some example scenarios:

* If a pull request adds a feature but also fixes two bugs, the pull
  request should have three commits: one commit for the feature change and
  two commits for the bug fixes.

* If a PR is opened with five commits that contain changes to fix a single
  issue, the PR should be rebased to a single commit.

* If a PR is opened with several commits, where the first commit fixes one issue
  and the rest fix a separate issue, the PR should be rebased to two
  commits (one for each issue).

**Important:** Your pull request should be rebased against the current master
branch. Do not merge the current master branch in with your topic branch. Do not
use the Update Branch button provided by GitHub on the pull request page.

### Commit Messages

Commit messages should follow common Git conventions, such as using the
imperative mood, separate subject lines, and a line length of 72 characters.
These rules are well documented in [Chris Beam's blog
post](https://chris.beams.io/posts/git-commit/#seven-rules).

**Signed-off-by**

Each commit must include a "Signed-off-by" line in the commit message (``git
commit -s``). This sign-off indicates that you agree the commit satisfies the
[Developer Certificate of Origin (DCO)](http://developercertificate.org/).

**Commit Email Address**

Your commit email address must match your GitHub email address. For more
information, see
<https://help.github.com/articles/setting-your-commit-email-address-in-git/>

### Important GitHub Requirements

A pull request cannot merged until it has passed these status checks:

* The build must pass on Jenkins

* The PR must be approved by at least two reviewers without any outstanding
  requests for changes
