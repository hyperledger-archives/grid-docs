# Grid Location

Hyperledger Grid Location is a framework for sharing location master data
between trade partners. The framework is built in a generic and extensible way
to allow for flexibility in serving various use cases and specialized
industries. The first extension of this framework – a GS1 compliant Location
 – is built and allows organizations to harness the power of a widely adopted
 industry standard. Location is a universal concept within the supply chain
 and is naturally one of the highest areas of re-use across Grid applications.


## What’s the benefit to using Grid Location?

Grid Location allows an organization to uniquely identify a location and share
that location with trade partners. This foundational capability serves as the
WHERE dimension within Grid, enabling a wide host of distributed supply chain
and commerce solutions. The framework can stand alone or pair with other Grid
capabilities to support use cases such as:

- **Track and Trace.** Visibility into where was a product sourced from, what
locations the product has passed through, where the product is now, where
the product is destined, and more.
- **Inventory & Warehouse Management.** Visibility into what inventory stock
levels look like across my network.
- **Order Management.** Visibility into what Sold To, Ship To, and Bill To
locations are relevant for a purchase order and related documents such as Bill
of Lading, Receipt of Goods, Invoice, etc.

Location information can also enrich user experiences through the display of
location attribution. Imagine a front-end interface where you can view
location names, addresses, and contacts alongside your business transactions.


## What do we consider a Location?

A location can represent more than a physical space. Check out the four
different types of locations our GS1 compliant Location supports below or by
visiting the
[GS1 General Specifications](https://www.gs1.org/standards/barcodes-epcrfid-id-keys/gs1-general-specifications).

- **Legal entities.** Any business, government body, department, charity,
individual or institution that has standing in the eyes of the law and has
the capacity to enter into contracts. Examples: Whole companies, subsidiaries
or divisions. Suppliers, distributors, banks, freight carriers, etc.
- **Functional entities.** A specific department within a legal entity.
Examples: accounting accounts payable, returns.
- **Physical locations.** A site (an area, a structure or group of structures)
 or an area within the site where something was, is, or will be located.
 Examples: Retail store, manufacturing facility, warehouse, distribution
 center, dock door, floor number, section of floor, room, shelf, section on
 shelf.
- **Digital locations.** An electronic (non-physical) address that is used for
communication between computer systems. Example: ERP system.

## Features

- Create a Location and share it with one or more trade partners
- Update (replace) the properties of a Location
- Remove a Location
- View a location and its related attributes


## Grid Location Sapling

The Grid Location Sapling is a user interface (UI) plug-in that allows a user
to interact with the features described above. This front-end interface is
under development. Once built, the sapling will allow business users to refine,
consume and transact with the underlying smart contracts in a user-friendly
way. Stay tuned for the Grid Location visual design and implementation.


## Want to Learn More?

Explore Grid Location implementation details by reviewing the Hyperledger Grid
Location Request for Comment (RFC) found in the [Hyperledger Grid RFC Repo](https://github.com/hyperledger/grid-rfcs).
