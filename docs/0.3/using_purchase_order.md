# Using Purchase Order

<!--
  Copyright (c) 2021 Cargill Incorporated
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->

This procedure describes how to create and manage purchase orders using Grid's
command-line interface.

This scenario describes how to create and manage a purchase order in a
vendor-managed instance.

## Prerequisites

* For Grid on Sawtooth
    - A working Grid node
    <br><br>

* For Grid on Splinter
    - Two or more working Grid nodes. (See [Running Grid on
      Splinter](grid_on_splinter.md) for the procedure to set up and run Grid
      in Docker containers.) The examples in this procedure show two nodes,
      `alpha-node-000` and `beta-node-000`, that are running in a Docker
      environment.

    - An organization `MyOrg` created in the [Using Pike](/docs/0.3/using_pike.md)
      walkthrough.

    - An approved Splinter circuit with two or more member nodes.
      (See [Creating Splinter Circuits]({% link
      docs/0.3/creating_splinter_circuits.md %}) for more information.)
      This procedure assumes that there is a circuit with `alpha-node-000` and
      `beta-node-000` as members.

    - A fully qualified service ID for the scabbard service on this circuit, in
      the format <code><i>CircuitID</i>::<i>ServiceString</i></code>.
      (See [Determine the Service
      ID]({% link docs/0.3/creating_splinter_circuits.md
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
`gridd-alpha`). You will use this container to run Grid commands on the node
(for example, `alpha-node-000`)

    ```
    $ docker exec -it gridd-alpha bash
    ```

### Generate Agent Keys

{:start="2"}

2.  Generate a secp256k1 key pair for the organization's agent on the alpha node.
    This key will be used to sign the Grid transactions that create purchase
    orders and set agent permissions.

    This example uses the base name `alpha-agent` to indicate that you will be
    acting as your organization's agent to add POs and other Grid items
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

3.  Set `GRID_DAEMON_KEY` to the base name of the agent's public/private key
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

1.  Set `GRID_DAEMON_ENDPOINT` to the endpoint for the node's `gridd` container
    (such as `http://localhost:8080`). This environment variable replaces the
    `--url` option on the `grid` command line.

    Tip: If you're using this example docker-compose environment, this variable
    is already defined for the `gridd-alpha` and `gridd-beta` containers.

    ```
    root@gridd-alpha:/# export GRID_DAEMON_ENDPOINT="http://localhost:8080"
    ```

1.  For Grid on Splinter: Set `GRID_SERVICE_ID` to the fully qualified service ID
    for the scabbard service on this circuit (such as `01234-ABCDE::gsAA`).
    This environment variable replaces the `--service_id` option on the `grid`
    command line.

    ```
    root@gridd-alpha:/# export GRID_SERVICE_ID=01234-ABCDE::gsAA
    ```

1.  Follow this same procedure in a separate command line for the `gridd-beta`
    container.

    ```
    $ docker exec -it gridd-beta bash
    ```

### Create a "Buyer" Organization

{:start="6"}

6.  The `MyOrganization` organization created using the procedure outlined in the
[Using Pike](/docs/0.3/using_pike.md) section will operate as the "buyer" for
this scenario.

#### Create a Purchase Order Admin Role

In order to submit transactions using other Grid features the submitting
agent
must possess an active role with the appropriate permissions.

{:start="7"}

7. Verify that the agent's public key file exists in
`~/.grid/keys/alpha-agent.pub`. If not, you must specify contents of the
public key file in the next command.

1. Create a role that has the appropriate permissions. The following command
shows how to create a role called `po-admin` with permissions to create and
update orders and versions. These permissions are included in the
workflow alias `po::partner`.

    ```
    root@gridd-alpha:/# grid role create \
    myorg po-admin \
    --description "purchase order admin permissions" \
    --active \
    --allowed-orgs gnrl \
    --permissions "po::partner"
    ```

1. Assign this role to the admin agent for this organization

    ```
    root@gridd-alpha:/# grid agent update \
    myorg $(cat ~/.grid/keys/alpha-agent.pub) \
    --active \
    --role admin \
    --role po-admin
    ```

### Create a "Vendor" Organization

{:start="10"}

10. In the `gridd-beta` command line, create an organization to act as a
    vendor.

    ```
    root@gridd-beta:/# grid organization create \
    gnrl "General Store"
    ```

#### Create a Purchase Order Manager Role

Create a role that inherits the purchase order permissions from the `po-admin`
permission belonging to MyOrg

{:start="11"}

11. Verify that the agent's public key file exists in
`~/.grid/keys/beta-agent.pub`. If not, you must specify contents of the
public key file in the next command.

1. Create a role that inherits the purchase order permissions from the `po-admin`
    permission belonging to `MyOrganization`

    ```
    root@gridd-beta:/# grid role create gnrl po-manager \
    --active \
    --permissions "po::partner" \
    --inherit-from "myorg.po-admin"
    ```

1.  Add the new role to the admin agent for General Store

    ```
    root@gridd-beta:/# grid agent update \
    gnrl $(cat ~/.grid/keys/beta-agent.pub) \
    --active \
    --role admin \
    --role po-manager
    ```

### Download the Schemas


15. Download the purchase order schemas so that the purchase order XML data
    can be validated

    ```
    root@gridd-alpha:/# grid download-xsd
    ```

    Follow this same procedure in a separate command line for the `gridd-beta`
    container.

    For in-depth information on this utility, read [`grid download-xsd`]({%
    link docs/0.3/references/cli/grid-download-xsd.1.md %})

### Create Purchase Orders

{:start=1}

1.  Using the `gridd-beta` command line, propose a draft purchase order on behalf
    of MyOrg. An example purchase order XML file can be downloaded with this link:
    <a href="/docs/0.3/purchase_order/test_po.xml" download="purchase_order.xml">
Example PO XML</a>.

    ```
    root@gridd-beta:/# grid po create \
    --buyer-org gnrl \
    --seller-org myorg \
    --alternate-id po_number:0123456 \
    --workflow-state issued \
    --workflow-id built-in::collaborative::v1 \
    --wait 100

    root@gridd-beta:/# grid po version create \
    po_number:0123456 \
    1 \
    --order-xml <path to order> \
    --draft \
    --workflow-state proposed \
    --wait 100
    ```

1.  At the same time, MyOrganization is creating a version of their own. Using
    the `gridd-alpha` command line, create a version for the purchase order

    ```
    root@gridd-alpha:/# grid po version create \
    po_number:0123456 \
    2 \
    --order-xml <path to order> \
    --draft \
    --workflow-state proposed \
    --wait 100
    ```

1.  After some deliberation, MyOrganization decides that the version created by
    General Store is more accurate. Using the `gridd-alpha` command line,
    accept the proposed purchase order

    ```
    root@gridd-alpha:/# grid po update \
    po_number:0123456 \
    --version-id 1 \
    --version-not-draft \
    --version-workflow-state accepted \
    --set-accepted-version \
    --workflow-state confirmed \
    --wait 100
    ```
