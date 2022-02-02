# Grid Purchase Order

<!--
  Copyright 2022 Cargill Incorporated
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->

Grid Purchase Order is a smart contract that enables buyers and sellers to
automate and synchronize their purchase order processes and data. It aims
to reduce administrative overhead, improve transaction accuracy and speed, and
reduce the number of disputes, ultimately improving business relationships.

## Problem overview

Today’s supply chains are complex, which makes managing them difficult and
expensive. Some of this complexity comes from the volume and intrinsic
complexity of the transactions and relationships between buyers and sellers.
This is often compounded by buyers and sellers maintaining their own set of
purchase order records.

Separate record keeping creates two primary problems: it creates disputes when
the parties do not agree, and it imposes a cost on both parties to maintain
their systems in an agreeing state.

## Grid Purchase Order Overview

Purchase Order leverages distributed ledger technology (DLT) to solve the
problem of separate record keeping, thereby reducing costly disputes between
parties and eliminating multi-system maintenance activities. It enables buyers
and sellers to work on the same purchase order contract in a controlled and
secure way and to see updates in real time.

Purchase Order is a complete solution for the purchase order process: a Grid
Purchase Order contract represents a negotiated purchase order between a buyer
and seller throughout its lifecycle and contains all its data, including its
history. Purchase Order uses the Grid Workflow feature to mirror real-world
business processes, defining the possible business states through which
contracts can flow, the criteria that must be met to move to the next state,
and the actions each party can take in each state. It also leverages Grid Pike
to configure role-based access control.

### Key benefits

- A complete solution for the purchase order process
- Trade partners always see the same data and get updates in real time,
  reducing disputes
- Trade partners have equal footing, with neither party having more information
  or control than the other
- Data is more automated and integrated, reducing overhead
- Smart contracts enforce the purchase order workflows and access control
- Format and content is standardized across all purchase orders, across all
  partners, according to GS1 XML Order standards

Organizations can use Purchase Order either as a system of record or as a
bridge between their and their business partners’ existing systems of record.

## Problem background and detail

A purchase order is a contract that specifies the details of goods or services
a buyer orders from a seller under agreed-upon conditions. It contains
information about the trade items ordered (with associated quantity and price),
shipping details, payment terms, quality constraints, tracking information, and
other relevant data.

In the simplest scenario, a purchase order is issued by a buyer, confirmed in
full by a seller, and fulfilled with no further collaboration necessary. In
more involved business scenarios, such as where product is out of stock or
requested delivery dates must be adjusted, trade partners interact to reach
agreement and modify purchase order records.

Today, the communication of order information occurs in various ways: by phone,
email, SMS, eCommerce marketplaces, Electronic Data Interchange (EDI), etc.
Both the manual coordination and automated, point-to-point sharing of
purchasing information between trade partners present challenges within
day-to-day supply chain operations including but not limited to:

- poor data accuracy stemming from manual data entry errors,
- discrepancies between systems which impact receiving or result in financial
  claims,
- costs related to administrative/clerical time, and
- management of custom integrations. 

In addition, communicating Purchase Order details via email, EDI, or other
traditional methods creates uncertainty for buyers and sellers because they
lack a shared view of the order’s status and contents. Siloed views of order
data can lead to misalignment between partners and result in undesirable
outcomes, such as customer disputes. Purchase orders often require updates to
dates and quantities, which involve substantial communication between trading
partners. This can lead to delays and an inability to see the most updated
status with which to formulate supply and demand plans.

## Purchase Order detail

Purchase Order addresses the challenges outlined above by enabling trade
partners to directly  collaborate on the creation and modification of a single
purchase order contract, with all partners enjoying a real-time view of the
state of the order.

### Expected outcomes of using Purchase Order

The primary outcomes we expect organizations using Grid Purchase Order to see
are:

- **Improved cost efficiency**: An organization’s financial results can benefit
  from a less time being spent manually inputting data, reconciling
  transactional differences with trade partners, performing credit/debit
  adjustments, addressing receiving problems, and handling product returns. 
- **Improved transaction accuracy**: Automated sharing of purchasing data can
  reduce errors that stem from manual data entry. 
- **Increased transaction speed**: Large volumes of data can be quickly
  communicated between organizations, leading to faster response times,
  improved buying decisions and production planning, greater customer
  satisfaction, and visibility into order status. 
- **Improved team productivity**: Less time spent comparing documents and
  resolving discrepancies means team members can focus on move value-additive
  business activities.
- **Improved business relationships**: Faster transactions, less overhead, and
  fewer disputes lead to less friction in business relationships.

### How we expect Purchase Order to be used

As mentioned above, organizations may adopt Grid Purchase Order as the system
of record between them and their partner organizations. In this case, their
technology integration teams will likely enable users to interact with Grid
through some integration application.

Organizations that choose to use their existing systems of record can use Grid
Purchase Order to synchronize the purchase order records of them and their
partners. In this case, their technology teams will integrate Grid directly
with their systems of record.

### How Purchase Order works

Purchase Order uses distributed ledger technology (DLT) to mirror the
underlying order data between the connected nodes (organizations). It enables
all parties in a private Splinter circuit or Sawtooth blockchain to have a
current and complete view of purchase orders at all times. Unlike centralized
databases, which can achieve a similar result, Grid gives equal standing to all
parties in the circuit by using DLT to ensure data integrity in a decentralized
way. It also increases reliability by providing each party with their own copy
of the data.

### Purchase Order structure

Purchase Order enforces GS1 XML Order standards for purchase order content,
ensuring clarity and consistency across purchase orders, even across
organizations.

Each purchase order contains one or more versions. Organizations can propose
or consider multiple versions of a purchase order before finalizing one.

Each purchase order version is comprised of one or more revisions. Each change
to a version’s content creates a new revision, providing users with a revision
history for every version.

### Purchase Order workflows

Purchase Order offers solutions for both simple and complex collaboration needs
by defining two built-in Purchase Order designs. These designs leverage Grid
Workflow, which requires the use of a state transition model, to define the
states through which a purchase order may flow. The first was inspired by
vendor-managed purchasing relationships, and the second by a more traditional
procurement relationship between a buyer and a seller.

Purchase Order workflows use three core components to facilitate transactions:

- workflow states - these represent the steps of the business process
- constraints - these represent business rules that determine when the purchase
  order can move between workflow states
- permissions - these define the actions that each organization can take at
  each step of the purchase order process, i.e. at each workflow state

For more information on the built-in workflows, see the
[Purchase Order RFC](https://github.com/Cargill/grid-rfcs/blob/ryanlassigbanks-purchase-order-rfc/text/0025-purchase-order.md).

Organizations can use the built-in workflows or create their own to fit their
needs. For more information about the Grid Workflow feature, see the
[Workflow RFC](https://github.com/hyperledger/grid-rfcs/blob/main/text/0024-workflows.md).

### Future development

In the near-term, the Purchase Order feature is focused on delivering better
communication and collaboration on purchasing information. Looking to the
future, it sets the stage for further integration, both upstream and
downstream, with order fulfillment and settlement business processes. 