# Development of this module

    1. checkout a new feature branch which matches the following RegEx `^feature\/\d+\-[\-a-zA-Z]*$`, see more under [naming conventions](#conventions)

    2. Immediately open a Draft merge request.

    3. Open the branch (not the MR) in gitpod and start developing.


## Starting the Odoo Server

This module contains a `launch.json` which starts the VSCode debugger when pressing `F5`.

## Conventions

### Names of Feature-Branches

Feature-branches @ 42 N.E.R.D.S. should satisfy the following RegEx `^feature\/\d+\-[\-a-zA-Z]*$`. That is to be able to have certain automations like pipelines, branch-protection rules and to make sure that everyone is one the same track.

In human words:

A feature-branch should begin with the word `feature` followed by a `/`. Thereafter we need to put the ticket ID in digits, (eg. #1234 -> feature/1234-...). Words following the ticket ID should be separated by a dash (`-`).

This convention makes sure, that every feature-branch is designated to one ticket only. This also makes sure, that feature-branches live short which reduces the occurance of merge conflicts.
