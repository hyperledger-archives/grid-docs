# CLI Command Reference

<!--
  Copyright 2018-2022 Cargill Incorporated
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->

## grid CLI
The `grid` command-line interface (CLI) provides a set of commands to interact
with Grid components.

[`grid`]({% link docs/0.3/references/cli/grid.1.md %})
Command-line interface for Grid

## gridd CLI
The `gridd` command-line interface (CLI) provides the command for running the
Grid daemon.

[`gridd`]({% link docs/0.3/references/cli/gridd.1.md %})
Starts the Grid daemon

## Database Management
[`grid database`]({% link docs/0.3/references/cli/grid-database.1.md %})
Manage Grid Daemon database

[`grid database migrate`]({%
link docs/0.3/references/cli/grid-database-migrate.1.md %})
Run migrations on the Grid Daemon database

## Administrative Management
[`grid admin`]({% link docs/0.3/references/cli/grid-admin.1.md %})
Supports Grid administrative functions

[`grid admin keygen`]({% link docs/0.3/references/cli/grid-admin-keygen.1.md %})
Generates keys for gridd to use to sign transactions and batches

[`grid keygen`]({% link docs/0.3/references/cli/grid-keygen.1.md %})
Generates keys for users to use to sign transactions and batches

## Agent Management
[`grid agent`]({% link docs/0.3/references/cli/grid-agent.1.md %})
Provides functionality for managing Pike Agents

[`grid agent create`]({% link docs/0.3/references/cli/grid-agent-create.1.md %})
Create a Pike Agent for an Organization with a set of roles

[`grid agent update`]({% link docs/0.3/references/cli/grid-agent-update.1.md %})
Update an existing Pike Agent

[`grid agent list`]({% link docs/0.3/references/cli/grid-agent-list.1.md %})
Provides functionality for listing Pike Agents

[`grid agent show`]({% link docs/0.3/references/cli/grid-agent-show.1.md %})
Provides functionality viewing Pike Agents

## Organization Management
[`grid organization`]({% link docs/0.3/references/cli/grid-organization.1.md %})
Provides functionality for managing Pike Organizations

[`grid organization create`]({%
link docs/0.3/references/cli/grid-organization-create.1.md %})
Create a Pike Organization. Automatically creates an agent with the `admin` role

[`grid organization update`]({%
link docs/0.3/references/cli/grid-organization-update.1.md %})
Update a Pike Organization

[`grid organization list`]({%
link docs/0.3/references/cli/grid-organization-list.1.md %})
List Pike Organizations

[`grid organization show`]({%
link docs/0.3/references/cli/grid-organization-show.1.md %})
Show a Pike Organization

## Role Management
[`grid role`]({%
link docs/0.3/references/cli/grid-role.1.md %})
Provides functionality for managing Pike Roles

[`grid role create`]({%
link docs/0.3/references/cli/grid-role-create.1.md %})
Create a Pike Role

[`grid role update`]({%
link docs/0.3/references/cli/grid-role-update.1.md %})
Update a Pike Role

[`grid role delete`]({%
link docs/0.3/references/cli/grid-role-delete.1.md %})
Delete a Pike Role

[`grid role list`]({%
link docs/0.3/references/cli/grid-role-list.1.md %})
List Pike Roles

[`grid role show`]({%
link docs/0.3/references/cli/grid-role-show.1.md %})
Show a Pike Role

## Location Management
[`grid location`]({% link docs/0.3/references/cli/grid-location.1.md %})
Provides functionality for managing Grid Locations

[`grid location create`]({%
  link docs/0.3/references/cli/grid-location-create.1.md %})
Create a Grid Location

[`grid location update`]({%
  link docs/0.3/references/cli/grid-location-update.1.md %})
Update a Grid Location

[`grid location delete`]({%
  link docs/0.3/references/cli/grid-location-delete.1.md %})
Delete a Grid Location

[`grid location list`]({% link docs/0.3/references/cli/grid-location-list.1.md %})
List Grid Locations

[`grid location show`]({%
  link docs/0.3/references/cli/grid-location-show.1.md %})
Show a Grid Location

## Schema Management
[`grid schema`]({% link docs/0.3/references/cli/grid-schema.1.md %})
Provides functionality for managing Grid schema

[`grid schema create`]({% link docs/0.3/references/cli/grid-schema-create.1.md %})
Create schemas from a YAML file

[`grid schema update`]({% link docs/0.3/references/cli/grid-schema-update.1.md %})
Update schemas from a YAML file

[`grid schema list`]({% link docs/0.3/references/cli/grid-schema-list.1.md %})
List currently defined schemas

[`grid schema show`]({% link docs/0.3/references/cli/grid-schema-show.1.md %})
Show schema specified by name argument

## Product Management
[`grid product`]({% link docs/0.3/references/cli/grid-product.1.md %})
Provides functionality for managing product data

[`grid product create`]({%
link docs/0.3/references/cli/grid-product-create.1.md %})
Create products from a YAML file or via command-line arguments

[`grid product update`]({%
link docs/0.3/references/cli/grid-product-update.1.md %})
Update products from a YAML file or via command-line arguments

[`grid product delete`]({%
link docs/0.3/references/cli/grid-product-delete.1.md %})
Delete a product

[`grid product list`]({% link docs/0.3/references/cli/grid-product-list.1.md %})
List all currently defined products

[`grid product show`]({% link docs/0.3/references/cli/grid-product-show.1.md %})
Show product specified by ID argument

## Purchase Order Management
[`grid po`]({% link docs/0.3/references/cli/grid-po.1.md %})
Provides functionality for managing Purchase Order data

[`grid po create`]({% link docs/0.3/references/cli/grid-po-create.1.md %})
Create a Purchase Order

[`grid po update`]({% link docs/0.3/references/cli/grid-po-update.1.md %})
Update a Purchase Order

[`grid po list`]({% link docs/0.3/references/cli/grid-po-list.1.md %})
List Grid Purchase Orders

[`grid po show`]({% link docs/0.3/references/cli/grid-po-show.1.md %})
Show a Grid Purchase Order

[`grid po version`]({% link docs/0.3/references/cli/grid-po-version.1.md %})
Provides functionality for managing Purchase Order versions

[`grid po version create`]({%
  link docs/0.3/references/cli/grid-po-version-create.1.md %})
Create a Purchase Order version

[`grid po version update`]({%
  link docs/0.3/references/cli/grid-po-version-update.1.md %})
Update a Purchase Order version

[`grid po version list`]({%
  link docs/0.3/references/cli/grid-po-version-list.1.md %})
List Purchase Order versions

[`grid po version show`]({%
  link docs/0.3/references/cli/grid-po-version-show.1.md %})
Show a Purchase Order version

[`grid po revision`]({% link docs/0.3/references/cli/grid-po-revision.1.md %})
Provides functionality for managing Purchase Order revisions

[`grid po revision list`]({%
  link docs/0.3/references/cli/grid-po-revision-list.1.md %})
List Purchase Order revisions

[`grid po revision list`]({%
  link docs/0.3/references/cli/grid-po-revision-show.1.md %})
Show a Purchase Order revision

### Resource Utilities
 
[`grid download-xsd`]({% link docs/0.3/references/cli/grid-download-xsd.1.md
%}) Download the XSD files necessary for validating
