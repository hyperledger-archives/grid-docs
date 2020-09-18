# Roadmap

<!--
  Copyright 2018-2020 Cargill Incorporated
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->

The following is a community-driven tentative roadmap to future releases.


## Grid 0.1

| Feature | Status | Primary Contact | RFC | Issues | Documentation |
| ------- | ------ | --------------- | --- | ------- | ------------- |
| Component | *RFC Submitted* | Shawn T. Amundson | [PR for RFC #9](https://github.com/hyperledger/grid-rfcs/pull/9) | - | - |
| Location | *RFC Final Comment Period* | Jessie Zamzow | [PR for RFC #20](https://github.com/hyperledger/grid-rfcs/pull/20) | ["location"](https://github.com/orgs/hyperledger/projects/1?card_filter_query=location) | - |
| Pike | *Implemented* | Darian Plumb | - | ["pike"](https://github.com/orgs/hyperledger/projects/1?card_filter_query=pike) | [Specification]({% link docs/0.1/pike_transaction_family.md %}), [REST API](/docs/0.1/api/#tag/Pike), [CLI]({% link docs/0.1/cli_references.md %}#grid-agent-create) |
| PostgreSQL Support | *Implemented* | Davey Newhall | - | ["postgres"](https://github.com/orgs/hyperledger/projects/1?card_filter_query=postgres) | [CLI]({% link docs/0.1/cli_references.md %}#grid-database-migrate) |
| Product | *Implemented* | Adeeb Ahmed | [RFC #5](https://github.com/hyperledger/grid-rfcs/blob/master/text/0005-product.md) | ["product"](https://github.com/orgs/hyperledger/projects/1?card_filter_query=product) | [REST API](/docs/0.1/api/#tag/Product), [CLI]({% link docs/0.1/cli_references.md %}#grid-product-create) |
| Sawtooth Support | *Implemented* | Ryan Banks | - | ["sawtooth"](https://github.com/orgs/hyperledger/projects/1?card_filter_query=sawtooth) | - |
| Schema | *Implemented* | Peter Schwarz | [RFC #4](https://github.com/hyperledger/grid-rfcs/blob/master/text/0000-grid-primitives.md) | ["schema"](https://github.com/orgs/hyperledger/projects/1?card_filter_query=schema) | [Specification]({% link docs/0.1/grid_schema_family_specification.md %}), [REST API](/docs/0.1/api/#tag/Schema), [CLI]({% link docs/0.1/cli_references.md %}#grid-schema-create) |
| Splinter Support | *Implemented* | Ryan Banks | - | ["splinter"](https://github.com/orgs/hyperledger/projects/1?card_filter_query=splinter) | [HOWTO]({% link docs/0.1/grid_on_splinter.md %}) |
| Sqlite Support | *Under Development* | Davey Newhall | - | ["sqlite"](https://github.com/orgs/hyperledger/projects/1?card_filter_query=sqlite) | - |
| Track and Trace | *Partial* | - | - | ["track"](https://github.com/orgs/hyperledger/projects/1?card_filter_query=track) | [Specification]({% link docs/0.1/grid_track_and_trace_family_specification.md %}), [REST API](/docs/0.1/api/#tag/Track-and-Trace) |

## Grid 0.2

| Feature | Status | Primary Contact | RFC | Issues | Documentation |
| ------- | ------ | --------------- | --- | ------- | ------------- |
| Product Catalog | *RFC Accepted* | Adeeb Ahmed | [RFC #14](https://github.com/hyperledger/grid-rfcs/blob/master/text/0014-catalog.md) | - | - |
| Inventory | *Discussion* | Nate Shrader | - | - | - |

## Additional Information

### Management of the Roadmap

The roadmap is maintained by the community with oversight of the
[root team](https://github.com/hyperledger/grid-rfcs/blob/master/subteams/root.md).
Changes to the roadmap are done in the form of pull requests to the
[grid-docs](https://github.com/hyperledger/grid-docs) repository.

Major features generally go through the [RFC
process](https://github.com/hyperledger/grid-rfcs).

Considering adding a new feature to Grid? Awesome! Feel free to chat about it
on [RocketChat in
#grid]({% link community/join_the_discussion.md %}#chat)  or at
one of our [contributor
meetings]({% link community/join_the_discussion.md %}#grid-contributor-meetings)!

### Columns

#### Primary Contact

If you want to get involved with a feature, reach out to the primary contact.
This will often be the person who submitted the RFC or the person currently
sheparding the feature. The primary contacts can all be found on RocketChat:

| Primary Contact   | RocketChat |
| --- | --- |
| Adeeb Ahmed | adeebahmed |
| Darian Plumb | dplumb |
| Davey Newhall | newhall |
| David Cecchi | davececchi |
| Jessie Zamzow | JessieZamzow |
| Nate Shrader | N8Shrader |
| Peter Schwarz | pschwarz |
| Ryan Banks | RobinBanks |
| Shawn T. Amundson | amundson |

#### Status

The status column can contain these values:

| Status | Description |
| --- | --- |
| Not Started | No work has actively started on this feature. |
| Discussion | An RFC has not been submitted, but the feature is actively being discussed. |
| RFC Submitted | The RFC has been submitted and is under review. |
| RFC Final Comment Period | The RFC is in final comment period (about a week) and is expected to be approved. |
| RFC Approved | The RFC has been approved by the appropriate subteams. |
| Under Development | The feature is actively being developed. |
| Implemented | The bulk of the implementation is done and the feature is usable. |
| Complete | The feature is ready for the release. |
