# Using Pike

<!--
  Copyright (c) 2018-2021 Cargill Incorporated
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

   This example uses the ID `myorg`, the name `MyOrganization`, and a GS1-specific
   alternate ID to note the GS1 company prefix.

   ```
   root@gridd-alpha:/# grid organization create \
   myorg MyOrganization \
   --alternate-ids gs1_company_prefix:013600
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

### Create Product Admin Role

In order to submit transactions using other Grid features the submitting agent
must possess an active role with the appropriate permissions.

{:start="7"}

7. Verify that the agent's public key file exists in
   `~/.grid/keys/alpha-agent.pub`. If not, you must specify contents of the
   public key file in the next command.

1. Create a role that has the appropriate permissions. The following command
shows how to create a role called `product-admin` with permissions to create,
update, and delete schemas and products.

```
root@gridd-alpha:/# grid role create \
myorg product-admin \
--description "product and schema admin permissions" \
--active \
--permissions "schema::can-create-schema,schema::can-update-schema,
product::can-create-product,product::can-update-product,
product::can-delete-product"
```

### Set Agent Permissions

A newly created agent does not have any roles, which means the agent
cannot make Grid-related changes on behalf of the organization. The following
steps show how to set the appropriate roles for products, schemas, and other
Grid features.

**Note** The signer that creates an organization is automatically granted the
`admin` role for the organization. This role grants permissions to manage the
organization, its roles, and its agents.

**Note**: An agent belongs to only one organization. All agent permissions apply
only to this organization.

{:start="9"}

9. Verify that the agent's public key file exists in
   `~/.grid/keys/alpha-agent.pub`. If not, you must specify contents of the
   public key file in the next command.

1. Set the appropriate permissions (also called "Pike roles") for the agent.
   The following command requires the organization ID (such as `myorg`) and the
   agent's public key string.

   This example allows the agent to create schemas and to create, update, and
   delete products.

   ```
   root@gridd-alpha:/# grid agent update \
   myorg $(cat ~/.grid/keys/alpha-agent.pub) \
   --active \
   --role product-admin \
   --role admin
   ```

   **Note**: You must specify `--active` and `--role admin`, even though the
   previous command automatically enabled these settings. The `grid` CLI
   requires these options to ensure that these important settings are not
   accidentally changed.

   **Note** Roles belonging to other organizations can be granted to an agent
   by specifying them in the format `<org_id>.<role_name>`. This also requires
   that the agent's organization is in the list of `allowed_organizations` for
   the role being granted.

### Display Organizations, Roles, and Agents

The Grid REST API provides the `/organization`, `/role/`, and `/agent`
endpoints to query the distributed ledger for organization, role, and agent
information. You can use `curl` to submit requests to the Grid REST API from
the command line.

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
   $ curl "http://localhost:8080/organization?service_id=01234-ABCDE::gsAA"
   ```

1. Request the list of agents.

   ```
   $ curl "http://localhost:8080/agent?service_id=01234-ABCDE::gsAA"
   ```

1. Request the list of roles.

   ```
   $ curl "http://localhost:8080/role/myorg?service_id=01234-ABCDE::gsAA"
   ```

### Update an Organization

To update an organization, you must have the `admin` role for the organization
you wish to update.

Updating an organization is very similar to creating an organization and the
`org_id`, `name`, and `address` arguments must all be specified.

```
root@gridd-alpha:/# grid organization update \
myorg MyOrganization \
--locations 0123456789012 \
--alternate-ids gs1_company_prefix:013600
```

### Add additional Agents

Additional agents can be added using the `grid agent create` subcommand. This
command requires the `org_id` and `public_key` arguments to be supplied. To
activate the agent, the `--active` flag must be supplied.

```
root@gridd-alpha:/# grid agent create \
myorg \
03aa7fee978a96a7904cad705ecebae908c9752185366cccea2811d27c51783a33 \
--active
```

Similarly, agents can be updated with the `grid agent update` subcommand.

```
root@gridd-alpha:/# grid agent update \
myorg \
03aa7fee978a96a7904cad705ecebae908c9752185366cccea2811d27c51783a33 \
--inactive
```

## Delegation of Roles Between Organizations

In order to support delegation between organizations, a role has fields called
`allowed_organizations` and `inherit_from`.

The `allowed_organizations` field is a list of organizations other than the
defining organization who can use the permissions granted in the role. This
allows organizations to delegate roles to each other.

The `inherit_from` field is a list containing references to other roles. If a
role has `inherit_from` defined, the permissions of the role must be a subset
of the union of all permissions defined by its `inherit_from`. An organization
may delegate a role to another organization containing a list of many
permissions. The delegatee organization may have separate functions that need
only a subset of the permissions in the delegated role. The `inherit_from`
field allows the delegatee organization to define roles that inherit from the
delegated role in order to be more granular about agent permissions.

### Delegation Example

The following scenario provides an example of a Grid network in which
the organizations involved are using Pike to solve their permission delegation
use-case. For this example, there are four organizations participating on the
network: Alpha, Beta, Gamma, and Delta. Alpha Company manages a set of tanks
armed with ballistic conference t-shirts. They have hired Beta Company and
Gamma Company to drive the tanks. Later on, we will see what happens when Delta
Company, another t-shirt tank management firm, joins the network.

The data model for the t-shirt tank may look something like this:

```yaml
- tank_id: 0001
  tank_owner: alpha
  turret_angle_degrees: 90
  t-shirts_remaining: 15
  is_driving: false
  decommissioned: false
```

The smart contract for operating tanks (named "tankops") would also define
several permissions:

- `tankops::can-drive` allows agents to submit a transaction to update the
  `is_driving` boolean.
- `tankops::can-turn-turret` allows agents to update the angle of the turret.
- `tankops::can-fire` allows agents to fire the t-shirt cannon, decrementing the
  count of remaining t-shirts.
- `tankops::can-decommission` allows agents to decommission the tank.

#### Alpha Company

Alpha Company doesn't have any drivers, but they do have inspectors that are in
charge of decommissioning tanks which are no longer fit for service. To do this,
an admin of Alpha Company submits a Grid Pike v2 transaction to create the
Inspector role.

```yaml
- name: alpha.Inspector
  permissions:
    - tankops::can-decommission
  allowed_organizations: []
  inherit_from: []
  active: true
```

Alpha Company admins can then assign this role to agents to give them permission
to decommission t-shirt tanks. With the `allowed_organizations` field blank, the
smart contract will assume that only Alpha agents can decommission Alpha tanks.

![]({% link docs/0.2/images/pike_diagrams/alpha-insp.svg %})

Alpha Company also needs to define a role for drivers:

```yaml
- name: alpha.Drivers
  permissions:
    - tankops::can-drive
    - tankops::can-turn-turret
    - tankops::can-fire
  allowed_organizations:
    - beta
    - gamma
  inherit_from: []
  active: true
```

![]({% link docs/0.2/images/pike_diagrams/alpha-full.svg %})

This role gives Beta Company and Gamma Company access to the permissions listed
in the alpha.Drivers role. For their agents to actually use these permissions,
they must redefine a role specific to their company which inherits permissions
from the alpha.Drivers role.

#### Beta Company

Beta Company is a rather small organization, and they expect their drivers to be
proficient in the full operation of a t-shirt tank. Therefore, it will define
a role with all of the necessary permissions:

```yaml
- name: beta.Drivers
  permissions:
    - tankops::can-drive
    - tankops::can-turn-turret
    - tankops::can-fire
  allowed_organizations: []
  inherit_from:
    - alpha.Drivers
  active: true
```

![]({% link docs/0.2/images/pike_diagrams/alpha-beta.svg %})

#### Gamma Company

The Gamma Company is a large organization with highly specialized agents. They
don't want to give all of their agents permission to do everything on a tank as
they are typically trained in only one of the three functions. To enforce this,
they define three different roles:

```yaml
- name: gamma.Navigator
  permissions:
    - tankops::can-drive
  allowed_organizations: []
  inherit_from:
    - alpha.Drivers
  active: true
```

```yaml
- name: gamma.Aimer
  permissions:
    - tankops::can-turn-turret
  allowed_organizations: []
  inherit_from:
    - alpha.Drivers
  active: true
```

```yaml
- name: gamma.Blaster
  permissions:
    - tankops::can-fire
  allowed_organizations: []
  inherit_from:
    - alpha.Drivers
  active: true
```

![]({% link docs/0.2/images/pike_diagrams/alpha-beta-gamma.svg %})

#### Delta Company

After hearing of the great prowess of Beta Company tank drivers, Delta Company
(a competitor of Alpha Company) makes an offer to Beta Company, hiring them to
drive Delta tanks. The Beta Company has also been training their drivers to
inspect tanks and now offers a decommissioning service as well, which Delta
Company wishes to purchase. Delta Company defines the following role:

```yaml
- name: delta.TankOperator
  permissions:
    - tankops::can-drive
    - tankops::can-turn-turret
    - tankops::can-fire
    - tankops::can-decommission
  allowed_organizations:
    - beta
  inherit_from: []
  active: true
```

![]({% link docs/0.2/images/pike_diagrams/delta.svg %})

To allow its agents to start operating and inspecting the Delta tanks, the Beta
Company admin updates the `beta.Drivers` role to also include the
`tankops::can-decommission` permission and add `delta.TankOperator` to it's
`inherit_from` list.

```yaml
- name: beta.Drivers
  permissions:
    - tankops::can-drive
    - tankops::can-turn-turret
    - tankops::can-fire
    - tankops::can-decommission
  allowed_organizations: []
  inherit_from:
    - alpha.Drivers
    - delta.TankOperator
  active: true
```

![]({% link docs/0.2/images/pike_diagrams/delta-beta.svg %})

This updated role allows Beta agents to drive, fire, and turn the turret on both
Alpha and Delta tanks. However, it only allows agents to decommission Delta
tanks, as the `alpha.Drivers` role does not include the
`tankops::can-decommission` permission.

Several weeks later, the Beta Company receives a phone call from Alpha Company
lawyers. They heard about the deal with Delta Company and cite a clause in their
contract which disallows drivers of Alpha tanks to also drive tanks from another
t-shirt tank management company. After the appropriate reprimands are dealt,
the Beta Company deactivates their previous `beta.Drivers` role and creates
two new roles, one for each tank company.

```yaml
- name: beta.Drivers
  permissions:
    - tankops::can-drive
    - tankops::can-turn-turret
    - tankops::can-fire
    - tankops::can-decommission
  allowed_organizations: []
  inherit_from:
    - alpha.Drivers
    - delta.TankOperator
  active: false
```

```yaml
- name: beta.AlphaDrivers
  permissions:
    - tankops::can-drive
    - tankops::can-turn-turret
    - tankops::can-fire
  allowed_organizations: []
  inherit_from:
    - alpha.Drivers
  active: true
```

```yaml
- name: beta.DeltaDrivers
  permissions:
    - tankops::can-drive
    - tankops::can-turn-turret
    - tankops::can-fire
    - tankops::can-decommission
  allowed_organizations: []
  inherit_from:
    - delta.TankOperator
  active: true
```

![]({% link docs/0.2/images/pike_diagrams/full.svg %})

## Alternate IDs

In several Grid smart contracts, it is necessary to record an additional ID to
identify an organization in a certain context. For example, in Grid Product,
the organization must have the proper GS1 company prefix in order to interact
with products with correlating GTINs. In Grid Pike, this is handled through the
use of the `metadata` field.

In Grid Pike 2.0, we further define this functionality through a new concept
called "Alternate IDs". This is implemented through a field called
`alternate_ids` on the `Organization` message and a new message called
`AlternateIDIndexEntry`. The `alternate_ids` field allows users and smart
contracts to easily fetch a list of all of the alternate IDs associated with an
organization. The `AlternateIDIndexEntry` message serves as an index to fetch a
Grid Pike organization from an externally known ID, and also ensures that no
organization can have an alternate ID that is already assigned.

When an organization is created, we check the list of alternate IDs supplied in
the transaction to ensure that none of the alternate IDs are already associated
with an existing organization. If not, we create a new `AlternateIDIndexEntry`
in state for each alternate ID. If that organization is updated, we check the
list of alternate IDs supplied with the transaction against the present record.
Any missing alternate IDs will be deleted from the index (the
`AlternateIDIndexEntry` for that alternate ID is deleted) and any new IDs will
be checked and added.

Similar functionality can be implemented for other smart contracts in the event
that organizations need to be identified and checked with identifiers other
than its Pike organization ID.

## Next Steps

Once you have an organization and one or more agents with schema and product
permissions, you can define a product schema and create products. For more
information, see [Using Grid
Features]({% link docs/0.2/using_grid_features.md %}).
