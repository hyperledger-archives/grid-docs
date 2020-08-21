# CLI Command Reference

<!--
  Copyright (c) 2019-2020 Cargill Incorporated
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->

The Grid command-line interface (CLI) provides a set of commands to interact
with Grid services.

This chapter shows the available options and arguments for each command and
subcommand. The synopsis for each command shows its parameters and their usage.

* Optional parameters are shown in square brackets
* Choices are shown in curly braces.
* User-supplied values are shown in angle brackets.

This usage information is also available on the command line by using the `-h`
or `--help` option.

## grid

Command-line interface for Hyperledger Grid.

```
USAGE:
    grid [FLAGS] [OPTIONS] [SUBCOMMAND]

FLAGS:
    -h, --help       Prints help information
    -q, --quiet      Do not display output
    -V, --version    Prints version information
    -v               Log verbosely

OPTIONS:
    -k <key>                         base name for private key file
        --service-id <service_id>    The ID of the service the payload should be sent to; required if running on
                                     Splinter. Format <circuit-id>::<service-id>
        --url <url>                  URL for the REST API
        --wait <wait>                How long to wait for transaction to be committed

SUBCOMMANDS:
    agent           Update or create agent
    database        Manage Grid Daemon database
    help            Prints this message or the help of the given subcommand(s)
    keygen          Generates keys with which the user can sign transactions and batches.
    organization    Update or create organization
    product         Create, update, or delete products
    schema          Update or create schemas
```

### grid agent create

Create an agent via the Pike smart contract.

```
USAGE:
    grid agent create [FLAGS] [OPTIONS] <org_id> <public_key> --active --inactive

FLAGS:
        --active      Set agent as active
    -h, --help        Prints help information
        --inactive    Set agent as inactive
    -q, --quiet       Do not display output
    -V, --version     Prints version information
    -v                Log verbosely

OPTIONS:
        --metadata <metadata>...    Key-value pairs (format: <key>=<value>) in a comma-separated list
        --role <role>...            Roles assigned to agent

ARGS:
    <org_id>        organization ID
    <public_key>    public key
```

### grid agent update

Update an agent via the Pike smart contract.

```
USAGE:
    grid agent update [FLAGS] [OPTIONS] <org_id> <public_key> --active --inactive

FLAGS:
        --active      Set agent as active
    -h, --help        Prints help information
        --inactive    Set agent as inactive
    -q, --quiet       Do not display output
    -V, --version     Prints version information
    -v                Log verbosely

OPTIONS:
        --metadata <metadata>...    Key-value pairs (format: <key>=<value>) in a comma-separated list
        --role <role>...            Roles assigned to agent

ARGS:
    <org_id>        organization ID
    <public_key>    public key
```

### grid database migrate

Run database migrations to create and apply updates to the Grid database tables.

```
USAGE:
    grid database migrate [FLAGS] [OPTIONS]

FLAGS:
    -h, --help       Prints help information
    -q, --quiet      Do not display output
    -V, --version    Prints version information
    -v               Log verbosely

OPTIONS:
        --database-url <database_url>    URL for database
```

### grid keygen

Generates keys with which the user can sign transactions and batches.

```
USAGE:
    grid keygen [FLAGS] [OPTIONS] [key_name]

FLAGS:
        --force      Overwrite files if they exist
    -h, --help       Prints help information
    -q, --quiet      Do not display output
    -V, --version    Prints version information
    -v               Log verbosely

OPTIONS:
    -d, --key_dir <key_dir>    Specify the directory for the key files

ARGS:
    <key_name>    Name of the key to create
```

### grid organization create

Create a new organization using the Pike smart contract.

```
USAGE:
    grid organization create [FLAGS] [OPTIONS] <org_id> <name> [--] [address]

FLAGS:
    -h, --help       Prints help information
    -q, --quiet      Do not display output
    -V, --version    Prints version information
    -v               Log verbosely

OPTIONS:
        --metadata <metadata>...    Key-value pairs (format: <key>=<value>) in a comma-separated list

ARGS:
    <org_id>     Unique ID for organization
    <name>       Name of the organization
    <address>    Physical address for organization
```

### grid organization update

Update an existing organization using the Pike smart contract.

```
USAGE:
    grid organization update [FLAGS] [OPTIONS] <org_id> <name> [--] [address]

FLAGS:
    -h, --help       Prints help information
    -q, --quiet      Do not display output
    -V, --version    Prints version information
    -v               Log verbosely

OPTIONS:
        --metadata <metadata>...    Key-value pairs (format: <key>=<value>) in a comma-separated list

ARGS:
    <org_id>     Unique ID for organization
    <name>       Name of the organization
    <address>    Physical address for organization
```

### grid product create

Create a new product via the Schema smart contract. This command requires a
YAML file that describes the product, as shown in the note below.

```
USAGE:
    grid product create [FLAGS] <path>

FLAGS:
    -h, --help       Prints help information
    -q, --quiet      Do not display output
    -V, --version    Prints version information
    -v               Log verbosely

ARGS:
    <path>    Path to yaml file containing a list of products
```

* **NOTE:** This example shows the format of the YAML file for a product.

  ```
    - product_type: "GS1"
      product_id: "762111177704"
      owner: "314156"
      properties:
        - name: "length"
          data_type: "NUMBER"
          number_value: 8
        - name: "width"
          data_type: "NUMBER"
          number_value: 11
        - name: "depth"
          data_type: "NUMBER"
          number_value: 1
    - product_type: "GS1"
      product_id: "881334009880"
      owner: "314156"
      properties:
        - name: "price"
          data_type: "NUMBER"
          number_value: 8
        - name: "height"
          data_type: "NUMBER"
          number_value: 11
  ```

### grid product delete

Delete an existing product.

```
USAGE:
    grid product delete [FLAGS] <product_id> <product_type>

FLAGS:
    -h, --help       Prints help information
    -q, --quiet      Do not display output
    -V, --version    Prints version information
    -v               Log verbosely

ARGS:
    <product_id>      Unique ID for a product
    <product_type>    Type of product (e.g. GS1

```

### grid product list

List all products available.

```
USAGE:
    grid product list [FLAGS]

FLAGS:
    -h, --help       Prints help information
    -q, --quiet      Do not display output
    -V, --version    Prints version information
    -v               Log verbosely
```

### grid product show

Show details for a given product.

```
USAGE:
    grid product show [FLAGS] <product_id>

FLAGS:
    -h, --help       Prints help information
    -q, --quiet      Do not display output
    -V, --version    Prints version information
    -v               Log verbosely

ARGS:
    <product_id>    ID of product
```

### grid product update

Update an existing product. This command requires a YAML file that describes the
product, as shown in the note below.

```
USAGE:
    grid product update [FLAGS] <path>

FLAGS:
    -h, --help       Prints help information
    -q, --quiet      Do not display output
    -V, --version    Prints version information
    -v               Log verbosely

ARGS:
    <path>    Path to yaml file containing a list of products

USAGE:
    grid product update [FLAGS] <path>

FLAGS:
    -h, --help       Prints help information
    -q, --quiet      Do not display output
    -V, --version    Prints version information
    -v               Log verbosely

ARGS:
    <path>    Path to yaml file containing a list of products
```

* **NOTE:**
  This example shows the format of the YAML file that specifies the
  fields to be updated.

  ```
    - product_type: "GS1"
      product_id: "762111177704"
      properties:
        - name: "length"
          data_type: "NUMBER"
          number_value: 88
        - name: "width"
          data_type: "NUMBER"
          number_value: 111
        - name: "depth"
          data_type: "NUMBER"
          number_value: 11
    - product_type: "GS1"
      product_id: "881334009880"
      properties:
        - name: "price"
          data_type: "NUMBER"
          number_value: 88
        - name: "height"
          data_type: "NUMBER"
          number_value: 111
  ```

### grid schema create

Create a schema definition via the Schema smart contract.
This command requires a YAML file that defines the schema.


```
USAGE:
    grid schema create [FLAGS] <path>

FLAGS:
    -h, --help       Prints help information
    -q, --quiet      Do not display output
    -V, --version    Prints version information
    -v               Log verbosely

ARGS:
    <path>    Path to yaml file containing a list of schema definitions
```

### grid schema list

List all available schemas.

```

USAGE:
    grid schema list [FLAGS]

FLAGS:
    -h, --help       Prints help information
    -q, --quiet      Do not display output
    -V, --version    Prints version information
    -v               Log verbosely
```

### grid schema show

Show details for a specific schema.

```
USAGE:
    grid schema show [FLAGS] <name>

FLAGS:
    -h, --help       Prints help information
    -q, --quiet      Do not display output
    -V, --version    Prints version information
    -v               Log verbosely

ARGS:
    <name>    Name of schema
```

### grid schema update

Update an existing schema definition via the Schema smart contract.
This command requires a YAML file that specifies the schema fields to be
updated.

```
USAGE:
    grid schema update [FLAGS] <path>

FLAGS:
    -h, --help       Prints help information
    -q, --quiet      Do not display output
    -V, --version    Prints version information
    -v               Log verbosely

ARGS:
    <path>    Path to yaml file containing a list of schema definitions
```
