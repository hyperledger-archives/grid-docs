# Best Practices for Grid Feature Documentation

<!--
  Copyright (c) 2019-2020, Cargill Incorporated
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->

A new Grid feature (such as Product, Location, or Identity) should have the
following documentation before the feature is considered complete.

&#9634; &nbsp; [Feature overview](#overview) <br>
&#9634; &nbsp; [How-to procedure](#how-to-procedure) <br>
&#9634; &nbsp; [Smart contract specification](#smart-contract-specification) <br>
&#9634; &nbsp; [Database tables reference](#database-tables-reference) <br>
&#9634; &nbsp; [GS1 schema reference](#gs1-schema-reference) <br>
&#9634; &nbsp; [REST API Reference](#rest-api-reference) <br>
&#9634; &nbsp; [Rust SDK documentation](#rust-sdk-documentation) <br>
&#9634; &nbsp; [CLI Command Reference](#cli-command-reference) <br>
&#9634; &nbsp; [Man pages for grid subcommands](#man-pages)

Grid documentation is written in [GitHub Flavored
Markdown](https://docs.github.com/en/github/writing-on-github/about-writing-and-formatting-on-github).

Read on to learn what's needed for each item.

### Feature Overview

Provide a high-level description that is focused on business-level concepts and
benefits. Some technical information is appropriate, but details belong in the
procedure and reference material. Include links to the detailed information as
appropriate.

*Example*: [Splinter: Canopy Application
Framework](https://www.splinter.dev/docs/0.4/concepts/canopy_application_framework.html)

### How-to Procedure

Write a procedure for each task associated with the feature, such as creating a
new product or setting up Pike organizations, agents, and permissions.

* Start with a introduction that explains the end goal for the procedure, where
  it fits in the Grid ecosystem, and the intended audience for the procedure
  (who usually does this task).

* Include any assumptions (like requiring an existing circuit) and prerequisites
  such as user keys, service IDs, or example YAML files that will be used in the
  procedure.

* Then list the steps for the task (such as creating and managing products with
  command-line options and YAML schema files). Include example commands and
  output for each step. For extra credit, add troubleshooting tips for common
  problems.

*Example*: <a href="/docs/{{ site.data.general.latest_version
}}/creating_splinter_circuits.html">Creating Splinter Circuits</a>

### Smart Contract Specification

Provide a topic that describes the smart contract's objects, namespace, address
format, and transaction types.

*Examples*: <a href="/docs/{{ site.data.general.latest_version
}}/grid_product_smart_contract_specification.html">
Grid Product Smart Contract Specification</a>,
[Sawtooth Supply Chain Transaction Family
Specification](https://sawtooth.hyperledger.org/docs/supply-chain/nightly/master/family_specification.html)

### Database Tables Reference

Provide a reference topic that describes the Grid daemon's database schema,
as defined in
[grid/daemon/src/database/schema.rs](https://github.com/hyperledger/grid/blob/master/daemon/src/database/schema.rs).

*Examples*: [Splinter: Biome Database
Tables](https://www.splinter.dev/docs/0.4/concepts/biome_user_management.html#biome-database-tables),
[Splinter: Gameroom Walkthrough](https://www.splinter.dev/docs/0.4/examples/gameroom/walkthrough/)
(see Section I-2.8, "Gameroom daemons write notification to Gameroom database")

### GS1 Schema Reference

Provide a reference topic that describes the Grid GS1 schema. This topic should
list the supported GS1 fields and associated GS1 attributes.

### REST API Reference

Update the Grid Daemon's
[openapi.yaml](https://github.com/hyperledger/grid/blob/master/daemon/openapi.yaml)
file to describe the feature's REST API endpoints. The [Grid REST API
Reference](https://grid.hyperledger.org/docs/0.1/api/) is automatically
generated from the contents of this file.

*Example*: [splinterd REST API Reference: Splinter
Registry](https://www.splinter.dev/docs/0.4/api/#tag/Splinter-Registry)

### Rust SDK documentation

Include [rustdoc]( https://doc.rust-lang.org/rustdoc/what-is-rustdoc.html)
comments for any SDK items associated with the feature.
The [Grid Rust SDK Reference](https://docs.rs/grid-sdk/) is automatically
generated from these comments.

Provide a description and overview for each new module, plus a description for
each struct, function, feature-specific enum, and so on.

*Example*: [track_and_trace protocol
module](https://docs.rs/grid-sdk/0.1.0/grid_sdk/protocol/track_and_trace/index.html)
in the [grid_sdk crate
documentation](https://docs.rs/grid-sdk/0.1.0/grid_sdk/)

### CLI Usage Statements

Each `grid` subcommand should have clear, helpful usage information for
the output of <code>grid <i>{SUBCOMMAND}</i> --help</code>.

### Man Pages

Write a man page for each ``grid`` subcommand associated with this feature.
The man page should expand on the CLI usage (which is minimal by design).

* DESCRIPTION section: Summarize what the command does, explain why someone
  would use it and where it fits in the Grid ecosystem (such as in multi-step
  task), and provide general guidance and prerequisites.

* OPTIONS section: Include details about the syntax, default values and
  any related environment variables, usage tips, and other helpful information.

* EXAMPLES section: Unless the command syntax is extremely basic, provide at
  least one example of a common use with default values.
  If appropriate, also provide more complex examples, such as using
  inter-related options, specifying a non-default file path, or
  overriding settings in a YAML file.

If this feature adds a top-level subcommand (such as `grid product` or `grid
location`), update the `grid.1.md` man page to include the new subcommand in
the "SUBCOMMANDS" section.

*Examples*: [Splinter man page
template](https://github.com/Cargill/splinter/blob/master/cli/man/TEMPLATE.1.md.example),
[splinter(1)](https://github.com/Cargill/splinter/blob/master/cli/man/splinter.1.md),
[splinter-circuit(1)](https://github.com/Cargill/splinter/blob/master/cli/man/splinter-circuit.1.md),
[splinter-circuit-propose(1)](https://github.com/Cargill/splinter/blob/master/cli/man/splinter-circuit-propose.1.md)

### CLI Command Reference

The `grid` man pages are automatically included in the
<a href="/docs/{{ site.data.general.latest_version }}/cli_references.html">
Grid CLI Command Reference</a>.

When adding a new Grid command or subcommand, update the Grid CLI Command
Reference with a link to the new man page.
