# Creating Organizations

<!--
  Copyright (c) 2018-2020 Cargill Incorporated
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->

This procedure describes how to create and manage Pike organizations and agents
using Grid's command-line interface.

Each Grid item such as a schema or product requires an owning organization and
at least one active agent with permissions to create and update those Grid
items.

## Prerequisites

* For Grid on Sawtooth:

    - A working Grid node. This procedure includes verification steps on a
      second Grid node, but all steps can be performed on a single node.
      <br><br>

* For Grid on Splinter:

    - Two or more working Grid nodes. (See [Running Grid on
      Splinter](grid_on_splinter.md) for the procedure to set up and run Grid
      in Docker containers.) The examples in this procedure show two nodes,
      `alpha-node-000` and `beta-node-000`, that are running in a Docker
      environment.

    - An approved Splinter circuit with two or more member nodes.
      (See [Creating Splinter Circuits]({% link
      docs/0.2/creating_splinter_circuits.md %}) for more information.)
      This procedure assumes that there is a circuit with `alpha-node-000` and
      `beta-node-000` as members.

    - A fully qualified service ID for the scabbard service on this circuit, in
      the format <code><i>CircuitID</i>::<i>ServiceString</i></code>.
      (See [Determine the Service
      ID]({% link docs/0.2/creating_splinter_circuits.md
      %}#determine-the-service-id) for the commands to display this
      information.) This procedure uses the example ID `01234-ABCDE::gsAA`.

* The Grid daemon's endpoint (URL and port) on one or both nodes.
  This procedure uses `http://localhost:8080`.

## Important Notes

The examples in this procedure use the node hostnames, container names, node
IDs, and URLs that are defined in the example docker-compose file,
`examples/splinter/docker-compose.yaml`. If you are not using this example
environment, replace these items with the actual values for your nodes.

## Procedure

### Connect to a Grid Node

1. Start a bash session in your node's `gridd` Docker container (such as
   `gridd-alpha`). You will use this container to run Grid commands on the
   node (for example, `alpha-node-000`).

   ```
   $ docker exec -it gridd-alpha bash
   root@gridd-alpha:/#
   ```

### Generate Agent Keys

{:start="2"}

2. Generate a secp256k1 key pair for the organization's agent on the alpha node.
   This key will be used to sign the Grid transactions that create organizations
   and set agent permissions.

   This example uses the base name `alpha-agent` to indicate that you will be
   acting as your organization's agent to add products and other Grid items
   from the alpha node.

   ```
   root@gridd-alpha:/# grid keygen alpha-agent
   Writing /root/.grid/keys/alpha-agent.priv
   Writing /root/.grid/keys/alpha-agent.pub
   ```

### Set Environment Variables

Set the following Grid environment variables to simplify entering the
`grid` commands in this procedure.

{:start="3"}

3. Set `GRID_DAEMON_KEY` to the base name of the agent's public/private key
   files (such as `alpha-agent`). This environment variable replaces the
   `-k` option on the `grid` command line.

   Tip: If you're using this example docker-compose environment, this
   variable is already defined for the `gridd-alpha` and `gridd-beta` containers.

   ```
   root@gridd-alpha:/# export GRID_DAEMON_KEY="alpha-agent"
   ```

   **Note**: Although this variable has "daemon" in the name, it should
   reference the user key files in `$HOME/.grid/keys`, not the Grid daemon's key
   files in `/etc/grid/keys`.

1. Set `GRID_DAEMON_ENDPOINT` to the endpoint for the node's `gridd` container
   (such as `http://localhost:8080`). This environment variable replaces the
   `--url` option on the `grid` command line.

   Tip: If you're using this example docker-compose environment, this variable
   is already defined for the `gridd-alpha` and `gridd-beta` containers.

   ```
   root@gridd-alpha:/# export GRID_DAEMON_ENDPOINT="http://localhost:8080"
   ```

1. For Grid on Splinter: Set `GRID_SERVICE_ID` to the fully qualified service ID
   for the scabbard service on this circuit (such as `01234-ABCDE::gsAA`).
   This environment variable replaces the `--service_id` option on the `grid`
   command line.

   ```
   root@gridd-alpha:/# export GRID_SERVICE_ID=01234-ABCDE::gsAA
   ```

### Create an Organization

{:start="6"}

6. Create a new organization by specifying a unique organization ID, the
   organization's name and street address, and optional metadata (as key-value
   strings).

   This example uses the ID `013600`, the name `myorg`, an imaginary street
   address, and GS1-specific metadata to note that the ID is a GS1 company
   prefix.

   ```
   root@gridd-alpha:/# grid organization create \
   013600 myorg '123 main street' \
   --metadata gs1_company_prefixes=013600
   ```

   This command creates and submits a transaction to create a new Pike
   organization with the data you supplied, as well as a new Pike agent
   with the `admin` role and `active` status.

   The transaction is signed with the agent's private key, as derived from the
   base name specified by `GRID_DAEMON_KEY` (or with the `-k` option on the
   command line). The agent's public key is used as the agent ID.

   **Note**: This command doesn't display any output. Instead, check the log
   messages (in the terminal window where you started the Grid Docker
   environment) for the success or failure of this operation.

### Set Agent Permissions

A newly created agent does not have any permissions, which means the agent
cannot make Grid-related changes on behalf of the organization. The following
steps show how to set the appropriate permissions (also called "Pike roles")
for products, schemas, and other Grid features.

**Note**: An agent belongs to only one organization. All agent permissions apply
only to this organization.

{:start="7"}

7. Verify that the agent's public key file exists in
   `~/.grid/keys/alpha-agent.pub`. If not, you must specify contents of the
   public key file in the next command.

1. Set the appropriate permissions (also called "Pike roles") for the agent.
   The following command requires the organization ID (such as `013600`) and the
   agent's public key string.

   This example allows the agent to create schemas and to create, update, and
   delete products.

   ```
   root@gridd-alpha:/# grid agent update \
   013600 $(cat ~/.grid/keys/alpha-agent.pub) \
   --active \
   --role can_create_schema \
   --role can_create_product \
   --role can_update_product \
   --role can_delete_product \
   --role can_create_location \
   --role can_update_location \
   --role can_delete_location \
   --role admin
   ```

   **Note**: You must specify `--active` and `--role admin`, even though the
   previous command automatically enabled these settings. The `grid` CLI
   requires these options to ensure that these important settings are not
   accidentally changed.

### Display Organizations and Agents

The Grid REST API provides the `/organization` and `/agent` endpoints to query
the distributed ledger for organization and agent information.
You can use `curl` to submit requests to the Grid REST API from the command
line.

The following examples show how to run these commands on your host system,
because the `curl` command is not available by default in the `gridd` container
in the example environment.

1. In the Grid node's `gridd` container, display the fully qualified service ID
   and copy it to use in the following `curl` commands.

   ```
   root@gridd-alpha:/# echo $GRID_SERVICE_ID
   01234-ABCDE::gsAA
   ```

   **Note**: Because requests to the Grid REST API are handled by the scabbard
   service on an existing circuit, a fully qualified service ID is required.

1. Request the list of organizations (from a system with `curl` installed).

   ```
   $ curl http://localhost:8080/organization?service_id=01234-ABCDE::gsAA
   ```

1. Request the list of agents.

   ```
   $ curl http://localhost:8080/agent?service_id=01234-ABCDE::gsAA
   ```

### Update an Organization

To update an organization, you must have the `admin` role for the organization
you wish to update.

Updating an organization is very similar to creating an organization and the
`org_id`, `name`, and `address` arguments must all be specified.

```
root@gridd-alpha:/# grid organization update \
013600 myorg '456 New Address Ln.' \
--metadata gs1_company_prefixes=013600
```

### Add additional Agents

Additional agents can be added using the `grid agent create` subcommand. This
command requires the `org_id` and `public_key` arguments to be supplied. To
activate the agent, the `--active` flag must be supplied.

```
root@gridd-alpha:/# grid agent create \
013600 \
03aa7fee978a96a7904cad705ecebae908c9752185366cccea2811d27c51783a33 \
--active
```

Similarly, agents can be updated with the `grid agent update` subcommand.

```
root@gridd-alpha:/# grid agent update \
013600 \
03aa7fee978a96a7904cad705ecebae908c9752185366cccea2811d27c51783a33 \
--inactive
```

## Next Steps

Once you have an organization and one or more agents with schema and product
permissions, you can define a product schema and create products. For more
information, see [Using Grid
Features]({% link docs/0.2/using_grid_features.md %}).
