<!--
  Copyright 2021 Cargill Incorporated
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->

# Grid Release Checklist

This document outlines at high level the procedure that should be followed when
preparing a new release of Hyperledger Grid.

## Grid Tests

* Rest API integration tests must pass
* Smart contract unit tests must pass
* UI tests must pass
* `just lint` must pass

The above list of tests are run by
[this Jenkins Job](https://build.sawtooth.me/job/Grid-Hyperledger/job/grid/job/main/).
If the Grid build is failing in Jenkins a release cannot be cut.

## Tag Repository

If the release is a major version, tag the repository with the version number
replacing dots with dashes. For example 0.2 would be tagged 0-2.

## Release Notes

If the release is a new major version, add a RELASE_NOTES.md file to the
tagged branch. If the release is a minor version, update the existing
RELASE_NOTES.md file in the tagged branch.

## Update Grid Website

Add release notes and announcement to the grid [website](https://grid.hyperledger.org/).

## Update Version Across Repo

Update the `version` field in the following files to the next version number.

### Files

* VERSION
* cli/Cargo.toml
* contracts/\*/Cargo.toml
* daemon/Cargo.toml
* griddle/Cargo.toml
* sdk/Cargo.toml
* ui/grid-ui/package.json
* ui/saplings/product/package.json


