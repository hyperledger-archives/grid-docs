---
layout: page
title: About
permalink: /about/
feature-img: "images/hero-bg.jpg"
feat_img_size: small
# Copyright (c) 2018-2019 Bitwise IO, Inc.
# Licensed under Creative Commons Attribution 4.0 International License
# https://creativecommons.org/licenses/by/4.0/
---

Hyperledger Grid is a project to provide a set of shared, reusable tools for
building cross-industry supply chain solutions based on distributed ledger
platforms. Its goal is to simplify the development of distributed-ledger-based
solutions for all types of supply chain scenarios.

This ecosystem of technologies, frameworks, and libraries is designed to
work with existing distributed ledger platform software and business-specific
applications, so that application developers can choose which components are
the most appropriate for their industry or market model.

{: .center-img}

![Hyperledger Grid in the supply change solution stack](/img/grid-diagram.png)

Hyperledger Grid components include:

* Reference implementations of supply-chain-centric data types, including
  domain-specific data models based on existing open standards such as
  [GS1](https://www.gs1.org/standards).

* Smart-contract business logic based on industry best practices.

* Pike, a smart contract that handles organization and identity permissions
  with [Sawtooth Sabre](https://github.com/hyperledger/sawtooth-sabre).

* SDKs that simplify development for smart contracts, such as the Rust SDK for
  Pike.

* Example smart contracts and applications that show how to combine components
  from the Hyperledger stack into a single, effective business solution. For
  instance, Grid Track and Trace is a smart contract for tracking goods as they
  move through a supply chain.

## Project status

Hyperledger Grid is currently in the
[incubation](https://wiki.hyperledger.org/display/HYP/Project+Lifecycle#ProjectLifecycle-incubation)
stage of the Hyperledger product lifecycle.
The [Hyperledger Grid
proposal](https://docs.google.com/document/d/1b6ES0bKUK30E2iZizy3vjVEhPn7IvsW5buDo7nFXBE0/)
was accepted in December, 2018. Please see the [Hyperledger Grid project
overview](https://www.hyperledger.org/projects/grid) for more information.

## How to participate

Hyperledger Grid is an open source project on [GitHub](http://github.com).
We welcome contributors, both organizations and individuals, to help shape
project direction, contribute ideas, provide use cases, and work on specific
tools and examples. Please see the [Grid FAQ: How can I contribute to this
project?](/faq/grid/#how-can-i-contribute-to-this-project) for more information.

### Source code

This project includes several repositories on [GitHub](http://github.com):

- The [hyperledger/grid](https://github.com/hyperledger/grid) repository
  contains core components such as supply-chain-centric data types and
  reference implementations of smart contracts

- The [hyperledger/grid-contrib](https://github.com/hyperledger/grid-contrib)
  repository contains example domain models and reference implementations for
  smart contracts (also called "transaction families")

- The [hyperledger/grid-rfcs](https://github.com/hyperledger/grid-rfcs)
  repository contains RFCs (requests for comments) for proposed and approved
  changes to Hyperledger Grid

## License

Hyperledger Grid software is licensed under the [Apache License Version
2.0](https://github.com/hyperledger/grid/blob/master/LICENSE) software license.

The Hyperledger Grid documentation in the
[docs](https://github.com/hyperledger/grid/blob/master/docs)
subdirectory is licensed under a Creative Commons Attribution 4.0 International
License.  You may obtain a copy of the license at
[http://creativecommons.org/licenses/by/4.0/](http://creativecommons.org/licenses/by/4.0/).

Portions of this site were generated with [Jekyll](http://jekyllrb.com) using
the [Type Theme](https://github.com/rohanchandra/type-theme). Both are used
under the [MIT
Licence](https://github.com/hyperledger/grid-website/blob/master/generator/source/LICENSE).
