# Roadmap

<!--
  Copyright 2018-2020 Cargill Incorporated
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->

The following is a community-driven tentative roadmap to future releases.

## Future Releases

### Grid 0.2

| Feature | Status | Primary Contact | RFC | Issues | Documentation |
| ------- | ------ | --------------- | --- | ------- | ------------- |
| Identity (Pike 2) | *Implemented* | Darian Plumb | [RFC #23](https://github.com/hyperledger/grid-rfcs/pull/23) | ["identity"](https://github.com/orgs/hyperledger/projects/1?card_filter_query=label%3A%22epic%3A+grid+identity%22) | - |
| Product w/GDSN Trade Items| *Implemented* | Darian Plumb | - | - |
| Update to Actix 3 | *Complete* | Shawn Amundson | - | - | - |

### Grid 0.3

| Feature | Status | Primary Contact | RFC | Issues | Documentation |
| ------- | ------ | --------------- | --- | ------- | ------------- |
| Batch Tracking | *Under Development* | Shawn T. Amundson | - | ["integration"](https://github.com/orgs/hyperledger/projects/1?card_filter_query=label%3A%22epic%3A+integration+component%22) | [Submitter Design]({% link community/planning/batch_submitter.md %}) |
| Integration REST API | *Under Development* | Shawn T. Amundson | - | ["integration"](https://github.com/orgs/hyperledger/projects/1?card_filter_query=label%3A%22epic%3A+integration+component%22) | - |
| Purchase Order | *Discussion* | Jessie Zamzow | [RFC #25](https://github.com/hyperledger/grid-rfcs/pull/25) | ["purchase order"](https://github.com/orgs/hyperledger/projects/1?card_filter_query=purchase+label%3A%22epic%3A+purchase+order%22) | - |
| Workflow | *RFC Submitted* | Shawn Amundson | [RFC #24](https://github.com/hyperledger/grid-rfcs/pull/24) | ["workflow RFC"](https://github.com/orgs/hyperledger/projects/1?card_filter_query=label%3A%22epic%3A+workflow+rfc%22) | - |

### Features for Future Releases

These features are not yet slated for a release, but work on them has started
in some form.

| Feature | Status | Primary Contact | RFC | Issues | Documentation |
| ------- | ------ | --------------- | --- | ------- | ------------- |
| Product Catalog | *RFC Accepted* | Adeeb Ahmed | [RFC #14](https://github.com/hyperledger/grid-rfcs/blob/master/text/0014-catalog.md) | - | - |
| Track and Trace | *Experimental* | Darian Plumb | - | ["track"](https://github.com/orgs/hyperledger/projects/1?card_filter_query=track) | [Specification]({% link docs/0.2/grid_track_and_trace_family_specification.md %}), [REST&nbsp;API](/docs/0.2/api/#tag/Track-and-Trace) |

## Past Releases

### Grid 0.1

| Feature | Status | Primary Contact | RFC | Issues | Documentation |
| ------- | ------ | --------------- | --- | ------- | ------------- |
| Component | *Complete* | Shawn T. Amundson | [PR for RFC #9](https://github.com/hyperledger/grid-rfcs/pull/9) | - | - |
| Location | *Complete* | Jessie Zamzow | [RFC #20](https://github.com/hyperledger/grid-rfcs/blob/master/text/0020-location.md) | ["location"](https://github.com/orgs/hyperledger/projects/1?card_filter_query=location) | [Specification]({% link docs/0.1/grid_location_smart_contract_specification.md %}) |
| Pike | *Complete* | Darian Plumb | - | ["pike"](https://github.com/orgs/hyperledger/projects/1?card_filter_query=pike) | [HOWTO]({% link docs/0.1/creating_organizations.md %}), [Specification]({% link docs/0.1/pike_transaction_family.md %}), [REST&nbsp;API](/docs/0.1/api/#tag/Pike), [CLI]({% link docs/0.1/references/cli/grid-agent-create.1.md %}) |
| PostgreSQL Support | *Complete* | Davey Newhall | - | ["postgres"](https://github.com/orgs/hyperledger/projects/1?card_filter_query=postgres) | [CLI]({% link docs/0.1/references/cli/grid-database-migrate.1.md %}) [Schema](https://grid.hyperledger.org/docs/0.1/database/postgres/)|
| Product | *Complete* | Adeeb Ahmed | [RFC #5](https://github.com/hyperledger/grid-rfcs/blob/master/text/0005-product.md) | ["product"](https://github.com/orgs/hyperledger/projects/1?card_filter_query=product) | [Overview]({% link docs/0.1/grid_product.md %}), [HOWTO]({% link docs/0.1/creating_products.md %}), [REST&nbsp;API](/docs/0.1/api/#tag/Product), [CLI]({% link docs/0.1/references/cli/grid-product-create.1.md %}) |
| Sawtooth Support | *Complete* | Ryan Banks | - | ["sawtooth"](https://github.com/orgs/hyperledger/projects/1?card_filter_query=sawtooth) | [HOWTO]({% link docs/0.1/grid_on_sawtooth.md %})  |
| Schema | *Complete* | Peter Schwarz | [RFC #4](https://github.com/hyperledger/grid-rfcs/blob/master/text/0000-grid-primitives.md) | ["schema"](https://github.com/orgs/hyperledger/projects/1?card_filter_query=schema) | [Specification]({% link docs/0.1/grid_schema_family_specification.md %}), [REST&nbsp;API](/docs/0.1/api/#tag/Schema), [CLI]({% link docs/0.1/references/cli/grid-schema-create.1.md %}) |
| Splinter Support | *Complete* | Ryan Banks | - | ["splinter"](https://github.com/orgs/hyperledger/projects/1?card_filter_query=splinter) | [HOWTO]({% link docs/0.1/grid_on_splinter.md %}) |
| Sqlite Support | *Complete* | Davey Newhall | - | ["sqlite"](https://github.com/orgs/hyperledger/projects/1?card_filter_query=sqlite) | [CLI]({% link docs/0.1/references/cli/grid-database-migrate.1.md %}) [Schema](https://grid.hyperledger.org/docs/0.1/database/sqlite/) |


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
one of our [community
meetings]({% link community/join_the_discussion.md %}#grid-community-meetings)!

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
