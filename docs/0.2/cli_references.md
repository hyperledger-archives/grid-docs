# CLI Command Reference

<!--
  Copyright 2018-2020 Cargill Incorporated
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->

## grid CLI
The `grid` command-line interface (CLI) provides a set of commands to interact
with Grid components.

[`grid`]({% link docs/0.2/references/cli/grid.1.md %})
Command-line interface for Grid

### Agent Management
[`grid agent`]({% link docs/0.2/references/cli/grid-agent.1.md %})
Provides functionality for managing Pike Agents

[`grid agent create`]({% link docs/0.2/references/cli/grid-agent-create.1.md %})
Create a Pike Agent for an Organization with a set of roles

[`grid agent update`]({% link docs/0.2/references/cli/grid-agent-update.1.md %})
Update an existing Pike Agent

### Organization Management
[`grid organization`]({% link docs/0.2/references/cli/grid-organization.1.md %})
Provides functionality for managing Pike Organizations

[`grid organization create`]({%
link docs/0.2/references/cli/grid-organization-create.1.md %})
Create a Pike Organization. Automatically creates an agent with the `admin` role

[`grid organization update`]({%
link docs/0.2/references/cli/grid-organization-update.1.md %})
Update a Pike Organization

### Schema Management
[`grid schema`]({% link docs/0.2/references/cli/grid-schema.1.md %})
Provides functionality for managing Grid schema

[`grid schema create`]({% link docs/0.2/references/cli/grid-schema-create.1.md %})
Create schemas from a YAML file

[`grid schema update`]({% link docs/0.2/references/cli/grid-schema-update.1.md %})
Update schemas from a YAML file

[`grid schema list`]({% link docs/0.2/references/cli/grid-schema-list.1.md %})
List currently defined schemas

[`grid schema show`]({% link docs/0.2/references/cli/grid-schema-show.1.md %})
Show schema specified by name argument

### Database Management
[`grid database`]({% link docs/0.2/references/cli/grid-database.1.md %})
Manage Grid Daemon database

[`grid database migrate`]({%
link docs/0.2/references/cli/grid-database-migrate.1.md %})
Run migrations on the Grid Daemon database

### Generate Key Pairs
[`grid keygen`]({% link docs/0.2/references/cli/grid-keygen.1.md %})
Generates keys with which the user can sign transactions and batches

### Product Management
[`grid product`]({% link docs/0.2/references/cli/grid-product.1.md %})
Provides functionality for managing product data

[`grid product create`]({%
link docs/0.2/references/cli/grid-product-create.1.md %})
Create products from a YAML file or via command-line arguments

[`grid product update`]({%
link docs/0.2/references/cli/grid-product-update.1.md %})
Update products from a YAML file or via command-line arguments

[`grid product delete`]({%
link docs/0.2/references/cli/grid-product-delete.1.md %})
Delete a product

[`grid product list`]({% link docs/0.2/references/cli/grid-product-list.1.md %})
List all currently defined products

[`grid product show`]({% link docs/0.2/references/cli/grid-product-show.1.md %})
Show product specified by ID argument

## gridd CLI
The `gridd` command-line interface (CLI) provides the command for running the
Grid daemon.

[`gridd`]({% link docs/0.2/references/cli/gridd.1.md %})
Starts the Grid daemon
