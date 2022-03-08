<!--
  Copyright 2022 Cargill Incorporated
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->

# REST API Backwards Compatibility Plan

## Problem Statement

Endpoints can have a wide range of compatibility support. For example,
consider the following endpoints and how they update:

| Protocol Version | 1 | 2 | 3 | 4 | 5 |
|------------------|---|---|---|---|---|
| /endpoint1       | 1 | 1 | 1 | 1 | 5 |
| /endpoint2       | 1 | 2 | 3 | 3 | 3 |
| /endpoint3       | 1 | 1 | 1 | 4 | 5 |
| /endpoint4       | - | - | 3 | 4 | 5 |

The table lists protocol versions at the top. This is the version passed to an
endpoint, representing the protocol version supported by the client. Endpoints
(on the left) return identical results from version to version until they are
updated, so:

 - ***endpoint1/*** - Remains unchanged until protocol version 5
 - ***endpoint2/*** - Changes at protocol versions 2 and 3
 - ***endpoint3/*** - Changes at protocol versions 4 and 5
 - ***endpoint4/*** - Created at protocol version 3.
   Changes at versions 4 and 5

With just 4 endpoints and 5 versions in this rather simple use case, we already
have a complex set of versions, all supported by one actively developed
application.

 - How do developers know when compatibility is broken and when to fork?
 - How do we maintain backwards compatibility, in the face of components that
   are shared between old and new endpoint versions?

These challenges are solved by the **Plan of Action**.

## Plan of Action

At a high level, the **Plan of Action** is to pull in the literal implementations
of the REST API for which we are attempting to maintain compatibility. We then
run various scenarios against both the old implementation and the actively
developed implementation. A "scenario" simply stands up the webserver with
prepopulated data, hits an endpoint, and then tests the response against a
known good response.

If a scenario test breaks in our new server implementation, we can be
reasonably certain that a backwards-incompatible change was made. We can either
attempt to fix the change to retain compatibility, or create a new protocol
version.

The plan of action is split into two phases:

 - **Phase I** - Write the initial abstracted tests
 - **Phase II** - Add testing across server versions

## Phase I

First, we write out tests for the current version, mirroring the
abstraction we plan to use, to determine whether this is maintainable.

Components of tests need to be abstracted in the following three steps:

 - **Setup** - Sets up any prerequisites required to hit an endpoint. This will
   differ by server version, and we will switch between testing various
   versions by using feature flags. We may mock out stores or populate an
   actual in-memory SQLite DB.
 - **Query against REST API** - This will not differ by server version. The
   rest API needs to be abstracted away in a manner that allows us to hit it
   with a different store setup.
 - **Validate response** - This will not differ by server version.

Tests should be in the main branch, and old versions of the web server
(starting with ones that support abstracted standup) are pulled into the
tests to run against.

The example files below demonstrate how Phase I could be set up for Splinter.
They assume the current version of Splinter (in the main branch) is 0.7.

### `Cargo.toml`

```toml
[features]
experimental = ["...", "splinter_0_7"]
splinter_0_7 = []
```

### `tests/rest_api/endpoints/batch_statuses.rs`

```rust
use crate::rest_api;

pub fn scenario_a(endpoint_url: String, protocol_version: usize) {
    match protocol_version {
        0..=3 => {
            let response = rest_api::fetch(&endpoint_url, protocol_version)
                .expect("unexpected error");
            assert_eq!(response, /* expected json */);
        },
        4 => {
            let response = rest_api::fetch(&endpoint_url, protocol_version)
                .expect("unexpected error");
            assert_eq!(response, /* different expected json */);
        },
        _ => panic!("unsupported version {}", protocol_version),
    }
}
```

### `tests/rest_api/servers/0_7.rs`

```rust
// Alias this so that, even though we’re currently testing splinter latest,
// we know we are testing a specific version of splinter
use splinter as splinter_0_7;
use crate::rest_api::{self, endpoints::batch_statuses};

#[test]
fn batch_statuses_scenario_a() {
    rest_api::run_it(batch_statuses::scenario_a, 1..3, || {
        // Oversimplified splinter server setup
        splinter_0_7::start_rest_server();

        // Return what is necessary to run the scenario
        // In this case an endpoint, but we could also return
        // authorization or other information.
        "http://localhost:8080/".to_string()
    });

    rest_api::run_it(batch_statuses::scenario_a, 4, || {
        // Oversimplified splinter server setup
        splinter_0_7::start_rest_server();

        // Return what is necessary to run the scenario
        "http://localhost:8080/".to_string()
    });
}
```

### `tests/rest_api/servers/mod.rs`

```rust
#[cfg(feature = "splinter_0_7")]
mod 0_7;
```

### `tests/rest_api/mod.rs`

```rust
use std::ops::Range;
use reqwest::{Error, blocking::{Response, Client} };

mod servers;

pub type ProtocolVersion = usize;

fn fetch(endpoint_url: &str, protocol_version: usize) -> Result<Response, Error> {
    Client::new()
        .get(endpoint_url)
        .header("ProtocolVersion", protocol_version)
        .send()
}

// Utility function to run the protocol version tests
pub fn run_it<ScenarioData>(scenario: impl Fn(ScenarioData, ProtocolVersion),
    protocol_versions: Range<ProtocolVersion>, setup_fn: impl Fn() -> ScenarioData) {
    for protocol_version in protocol_versions {
        scenario(setup_fn(), protocol_version);
    }
}
```

Tests could be run in the following manner

`cargo test –features=experimental rest_api::`

## Phase II

Phase II can only begin once we have a released version with tests in
place.

Immediately after that, we should:
 - Add a dev-dependency for the released version’s web-server, hidden
   behind a feature as described above.
 - Create a copy of the **Setup** step of the appropriate test. (In the
   example below, we copy `servers/0_7.rs` to `servers/0_8.rs`)
 - Update the justfile to run appropriate tests for that feature

Compilation times will jump up due to pulling in an old version of
Splinter / Actix / etc. This can be solved for CI by preloading the docker
image with these libraries.

The example files below demonstrate how we can setup Phase II for Splinter.
They assume Phase I was completed for Splinter 0.7, and the current version of
Splinter (in main branch) is 0.8.

### `Cargo.toml`

```diff
+[dev-dependencies]
+splinter_0_7 = { package = "splinter", version = "0.7" }
+
 [features]
-experimental = ["...", "splinter_0_7"]
-splinter_0_7 = []
+experimental = ["...", "splinter_0_8"]
+splinter_0_7 = ["splinter_0_7"]
+splinter_0_8 = []
```

### `tests/rest_api/servers/0_7.rs`

```diff
-use splinter as splinter_0_7;
+use splinter_0_7;
 use crate::rest_api;

 #[test]
 fn batch_statuses_scenario_a() {
     /* snip */
 }
```

### `tests/rest_api/servers/0_8.rs`

Quite literally we just `cp 0_7.rs 0_8.rs`, and make a small adjustment to
`use` in the header for `0_8.rs`.

```diff
-use splinter_0_7;
+use splinter_0_8;
 use crate::rest_api;

 #[test]
 fn batch_statuses_scenario_a() {
     /* snip */
 }
```

### `tests/rest_api/servers/mod.rs`

```diff
 #[cfg(feature = "splinter_0_7")]
 mod 0_7;
+
+#[cfg(feature = "splinter_0_8")]
+mod 0_8;
```

Tests could be run in the following manner

`cargo test --features=splinter_0_7 --features=experimental rest_api::`
