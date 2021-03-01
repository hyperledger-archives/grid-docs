% GRID-AGENT-CREATE(1) Cargill, Incorporated | Grid Commands
<!--
  Copyright 2018-2020 Cargill Incorporated
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->

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
