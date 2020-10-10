# Grid Glossary

<!--
  Copyright (c) 2019-2020 Cargill Incorporated
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->

This glossary defines Hyperledger Grid terms and concepts.
<br><br>

<h3 class="glossary-header" id="agent">
agent
</h3>
<p class="glossary-definition">
Person or entity that acts on behalf of a Pike organization to create and manage
items such as Product or Location records. Pike roles (also called
"permissions") control what an agent is allowed to do, such as creating schemas
or product records.
</p>

<h3 class="glossary-header" id="batch">
batch
</h3>
<p class="glossary-definition">
Collection of related transactions that are handled as a group by the backend
distributed ledger.
(For more information, see the <a
href="https://sawtooth.hyperledger.org/docs/core/releases/latest/glossary.html">
Sawtooth glossary</a>.)
The Grid REST API provides the <code>batches</code> endpoint to submit batches
of transactions and the <code>batch_statuses</code> endpoint to query the commit
status of submitted batches. In addition, the <code>grid</code> CLI includes
subcommands that can submit batches of transactions from the command line.
</p>

<h3 class="glossary-header" id="circuit">
circuit
</h3>
<p class="glossary-definition">
(Grid on Splinter) Virtual network that safely and securely enforces privacy
scope boundaries. A circuit defines the scope and visibility domains for two
or more connected nodes.
</p>

<h3 class="glossary-header" id="distributed_ledger">
distributed ledger
</h3>
<p class="glossary-definition">
Distributed database that records transactions, in chronological order,
shared by all participants in a network. (Also called a "blockchain".)
Each block is linked by a cryptographic hash to the previous block.
</p>

<h3 class="glossary-header" id="grid_daemon_gridd">
Grid daemon (gridd)
</h3>
<p class="glossary-definition">
Daemon process that provides services such as the Grid REST API and state delta
export functionality, which integrates with the backend distributed ledger to
materialize state data to a local database.
</p>

<h3 class="glossary-header" id="grid_product">
Grid Product
</h3>
<p class="glossary-definition">
Smart contract for defining and sharing product data (trade item data).
</p>

<h3 class="glossary-header" id="grid_track_and_trace">
Grid Track and Trace
</h3>
<p class="glossary-definition">
Smart contract for tracking goods as they move through a supply chain.
</p>

<h3 class="glossary-header" id="gs1">
GS1
</h3>
<p class="glossary-definition">
Organization that manages standards for business communication, such as
GTIN (Global Trade Item Number) and GLN (Global Location Number).
Grid includes support for
<a href="https://www.gs1.org/standards">GS1 standards</a>
in Grid Product, Grid Location, and other features.
</p>

<h3 class="glossary-header" id="hyperledger_sawtooth">
Hyperledger Sawtooth
</h3>
<p class="glossary-definition">
Backend distributed ledger system for executing transactions that provides a
permissioned (private) network with dynamic consensus. For more information,
see the <a href="https://sawtooth.hyperledger.org/docs/core/releases/latest/">
Sawtooth documentation</a>.
</p>

<h3 class="glossary-header" id="namespace">
namespace
</h3>
<p class="glossary-definition">
Set of addresses in shared state that specifies the storage location used by
a specific smart contract for transaction information.
For example, the first 6 hex characters of a state address identify Grid itself
(<code>612dee</code>); the next two characters specify the Grid smart contract
(such as <code>01</code> for Schema or <code>02</code> for Grid Product).
</p>

<h3 class="glossary-header" id="node">
node
</h3>
<p class="glossary-definition">
Device or process running Grid software, with a backend distributed ledger
system, in order to participate in a network or Splinter circuit.
Each node stores a complete replica of the distributed ledger.
</p>

<h3 class="glossary-header" id="organization">
organization
</h3>
<p class="glossary-definition">
Company or other entity that owns trade items being managed with Grid smart
contracts. As defined by the Pike smart contract, an organization has one or
more agents with permission to manage items on behalf of that organization.
</p>

<h3 class="glossary-header" id="pike">
Pike
</h3>
<p class="glossary-definition">
Smart contract that handles identity permissions with organizations and agents.
</p>

<h3 class="glossary-header" id="organization">
product
</h3>
<p class="glossary-definition">
Trade item that is managed by the Grid Product smart contract. Each product has
a namespace type (such as GS1), ID (such as a GTIN), an owning organization, and
a set of properties that conforms to the product schema.
</p>

<h3 class="glossary-header" id="sawtooth_sabre">
Sawtooth Sabre
</h3>
<p class="glossary-definition">
Smart-contract engine that executes smart contracts with WebAssembly (WASM).
The rules for a smart contract are defined by a smart contract specification
(formerly called a "transaction family"). For more information, see the
<a href="https://sawtooth.hyperledger.org/docs/sabre/nightly/master/">
Sabre documentation</a>.
</p>

<h3 class="glossary-header" id="schema">
Schema
</h3>
<p class="glossary-definition">
Smart contract that defines and manages sets of properties, called "schemas",
for Grid features such as Product and Location.
</p>

<h3 class="glossary-header" id="smart_contract">
smart contract
</h3>
<p class="glossary-definition">
Application-specific business logic that defines a set of operations or
transaction types that are allowed on the distributed ledger. A smart contract
implements a data model and transaction language for an application.
</p>

<h3 class="glossary-header" id="splinter">
Splinter
</h3>
<p class="glossary-definition">
Backend distributed ledger system for executing transactions that provides
private circuits between participating nodes, where state data is shared only
with circuit participants (called "member nodes"). For more information, see the
<a href="https://www.splinter.dev/docs/">Splinter documentation</a>.
</p>

<h3 class="glossary-header" id="state_delta_export">
state delta export
</h3>
<p class="glossary-definition">
Mechanism in the backend distributed ledger system that provides changes to
shared state as "state deltas" (state-change updates as a result of processed
transactions). The Grid daemon, <code>gridd</code>, provides an interface
service for state delta export functionality, which allows Grid applications to
subscribe to these changes for current information that can be stored in a local
database.
</p>

<h3 class="glossary-header" id="transaction_family">
transaction family
</h3>
<p class="glossary-definition">
Earlier term for a smart contract.
</p>
