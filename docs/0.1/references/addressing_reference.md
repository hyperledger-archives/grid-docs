# Addressing Reference

<!--
  Copyright (c) 2018-2020 Cargill Incorporated
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->

Each Grid object is stored in the merkle tree at a specific 70 character
address. These addresses normally include one or more address prefixes
concatenated together, as well as a unique identifier for the object itself.
These address prefixes may denote which smart contract defines the object (this
is referred to as the "namespace" prefix), and what type of is stored there.

This document provides a reference for address prefixes across all of the Grid
smart contracts. For more specific information, please see the "Addressing"
section in the smart contract specification for any Grid smart contract.

<table>
  <thead>
    <tr>
      <th>Smart Contract</th>
      <th>Namespace Prefix</th>
      <th> Object prefixes</th>
    </tr>
  </thead>
  <tr>
    <td>Pike</td>
    <td><code>cad11d</code></td>
    <td>
      Agents: <code>00</code><br>
      Organizations: <code>01</code>
    </td>
  </tr>
  <tr>
    <td>Schema</td>
    <td><code>621dee01</code></td>
    <td>-</td>
  </tr>
  <tr>
    <td>Product</td>
    <td><code>621dee02</code></td>
    <td>GS1 Products: <code>01</code></td>
  </tr>
  <tr>
    <td>Product Catalog</td>
    <td><code>621dee03</code></td>
    <td>
      Catalog: <code>00</code><br>
      Catalog Product: <code>01</code>
    </td>
  </tr>
  <tr>
    <td>Location</td>
    <td><code>621dee04</code></td>
    <td>GS1 Locations: <code>01</code></td>
  </tr>
    <tr>
    <td>Track and Trace</td>
    <td><code>a43b46</code></td>
    <td>
      Property / PropertyPage: <code>ea</code><br>
      Proposal: <code>aa</code><br>
      Record: <code>ec</code>
    </td>
  </tr>
</table>
