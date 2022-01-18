# Workflow Specification

<!--
  Copyright (c) 2019-2021 Cargill Incorporated
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->

## Overview

Grid Workflow enables users to model business processes as state transitions
within smart contracts. Its design decouples the complex logic of business
processes from smart contract logic, simplifying the creation of each.

Workflow definitions are comprised of states, constraints, and permissions.
Workflow states represent the stages of a business process. Constraints
represent conditions that must be met to transition from one state to the next.
Permission aliases define the actions that each party can take at each state in
the workflow. Workflows contain one or more sub-workflows, which further help
to encapsulate business process complexity.

## Representation

### Workflow

`Workflow` consists of a list of `SubWorkflow`:
```rust
pub struct Workflow {
    subworkflow: Vec<SubWorkflow>,
}

impl Workflow {
    pub fn new(subworkflow: Vec<SubWorkflow>) -> Self {
        Self { subworkflow }
    }

    pub fn subworkflow(&self, name: &str) -> Option<SubWorkflow> {
        for sub_wf in &self.subworkflow {
            if sub_wf.name() == name {
                return Some(sub_wf.clone());
            }
        }

        None
    }
}
```

### SubWorkflow

`SubWorkflow` has a name, a list of `WorkflowState` and a list of starting
states:

```rust
#[derive(Clone)]
pub struct SubWorkflow {
    name: String,
    states: Vec<WorkflowState>,
    starting_states: Vec<String>,
}

impl SubWorkflow {
    pub fn name(&self) -> &str {
        &self.name
    }

    pub fn state(&self, name: &str) -> Option<WorkflowState> {
        for state in &self.states {
            if state.name() == name {
                return Some(state.clone());
            }
        }

        None
    }

    pub fn starting_states(&self) -> &[String] {
        &self.starting_states
    }
}
```

### WorkflowState

`WorkflowState` has a name, list of constraints, list of permission aliases,
and list of transitions that can be made from that state. It has four methods:
* `can_transition` returns true if an entity can execute a transition to a
  given state given its Pike permissions.
* `expand_permissions` returns a list of all permissions that are stored under
  a given `PermissionAlias`
* `get_aliases_by_permission` retrieves all aliases defined within this state
  that contain the specified workflow permission
* `has_constraint` returns true if the workflow state has the specified
  constraint

```rust
#[derive(Clone)]
pub struct WorkflowState {
    name: String,
    constraints: Vec<String>,
    permission_aliases: Vec<PermissionAlias>,
    transitions: Vec<String>,
}

impl WorkflowState {
    pub fn can_transition(&self, new_state: String, pike_permissions: &[String]) -> bool {
        if self.name == new_state {
            return true;
        }

        if !self.transitions.contains(&new_state) {
            return false;
        }

        for perm in pike_permissions {
            for alias in &self.permission_aliases {
                if alias.name() == perm && alias.transitions.contains(&new_state) {
                    return true;
                }
            }
        }

        false
    }

    pub fn expand_permissions(&self, names: &[String]) -> Vec<String> {
        let mut perms = Vec::new();

        for name in names {
            for alias in &self.permission_aliases {
                if alias.name() == name {
                    perms.append(&mut alias.permissions().to_vec());
                }
            }
        }

        perms
    }

    pub fn get_aliases_by_permission(&self, permission: &str) -> Vec<String> {
        let mut aliases = Vec::new();

        for alias in &self.permission_aliases {
            if alias.permissions().contains(&permission.to_string()) {
                aliases.push(alias.name().to_string());
            }
        }

        aliases
    }

    pub fn has_constraint(&self, constraint: &str) -> bool {
        self.constraints.contains(&constraint.to_string())
    }
}
```

### PermissionAlias

`PermissionAlias` is an alias that houses multiple permissions. It has a name, a
list of actions that live under the alias, and a list of transitions the alias
can perform:

```rust
#[derive(Clone, Default)]
pub struct PermissionAlias {
    name: String,
    permissions: Vec<String>,
    transitions: Vec<String>,
}

impl PermissionAlias {
    pub fn new(name: &str) -> Self {
        Self {
            name: name.to_string(),
            permissions: vec![],
            transitions: vec![],
        }
    }

    pub fn add_permission(&mut self, permission: &str) {
        self.permissions.push(permission.to_string());
    }

    pub fn add_transition(&mut self, transition: &str) {
        self.transitions.push(transition.to_string());
    }
}
```

Below is an example of a permission alias with the name `po::seller` that has
permission to perform two actions, create a purchase order version and
transition the purchase order to an **issued** state, and the ability to
perform one transition, moving the purchase order to its **issued** state:

```rust
let mut seller = PermissionAlias::new("po::seller");
seller.add_permission(&Permission::CanCreatePoVersion.to_string());
seller.add_permission(&Permission::CanTransitionIssued.to_string());
seller.add_transition("issued");
```
