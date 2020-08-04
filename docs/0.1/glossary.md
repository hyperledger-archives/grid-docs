# Grid Glossary

<!--
  Copyright (c) 2019-2020 Cargill Incorporated
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->

This glossary defines Hyperledger Grid terms and concepts.
<br><br>


<h3 class="glossary-header" id="distributed_ledger">
Distributed ledger
</h3>

<p class="glossary-definition">
Distributed database that records transactions, in chronological order,
shared by all participants in a network. (Also called a "blockchain".)
Each block is linked by a cryptographic hash to the previous block.
</p>

<h3 class="glossary-header" id="grid_track_and_trace">
Grid Track and Trace
</h3>

<p class="glossary-definition">
Smart contract for tracking goods as they move through a supply chain.
</p>

<h3 class="glossary-header" id="pike">
Pike
</h3>

<p class="glossary-definition">
Smart contract that handles organization and identity permissions with
Sawtooth Sabre.
</p>

<h3 class="glossary-header" id="sawtooth_sabre">
Sawtooth Sabre
</h3>

<p class="glossary-definition">
Smart-contract engine that executes smart contracts with WebAssembly (WASM).
The rules for a smart contract are defined by a "transaction family". For
more information, see the
<a href="https://sawtooth.hyperledger.org/docs/sabre/nightly/master/">
Sabre documentation</a>.
</p>

<h3 class="glossary-header" id="transaction_family">
Transaction family
</h3>

<p class="glossary-definition">
Another term for a "smart contract": Application-specific business logic
that defines a set of operations or transaction types that are allowed on
the distributed ledger. A transaction family implements a data model and
transaction language for an application.
</p>
