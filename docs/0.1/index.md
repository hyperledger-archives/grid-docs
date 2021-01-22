# Introduction

<!--
  Copyright (c) 2019-2020 Cargill Incorporated
  Copyright (c) 2015-2017 Intel Corporation
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->

Hyperledger Grid is a platform for building supply chain solutions that include
distributed ledger components. This project provides a set of modular
components for developing smart contracts and client interfaces, including
domain-specific data models (such as GS1 product definitions), smart-contract
business logic, libraries, and SDKs.

This ecosystem of technologies, frameworks, and libraries is designed to
work with existing distributed ledger platform software and business-specific
applications, so that application developers can choose which components are
the most appropriate for their industry or market model.

![]({% link docs/0.1/images/grid-diagram.png %}
"Hyperledger Grid in the supply change solution stack")

Hyperledger Grid components include:

* Reference implementations of supply-chain-centric data types, including
  domain-specific data models based on existing open standards such as
  [GS1](https://www.gs1.org/standards).

* Smart-contract business logic based on industry best practices.

* [Pike]({% link docs/0.1/pike_smart_contract_specification.md %}),
  a smart contract that handles organization and identity permissions
  with [Sawtooth Sabre](https://github.com/hyperledger/sawtooth-sabre).

* SDKs that simplify development for smart contracts, such as the Rust SDK for
  Pike.
