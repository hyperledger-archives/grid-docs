# grid-website

## Preview and Review

You'll need to install
[Docker and Compose](https://docs.docker.com/compose/install/)

From a local clone of
[the repository](https://github.com/hyperledger/sawtooth-website), run

```
docker-compose up
```

Pay attention to the output for markdown syntax errors. Errors will appear on
lines beginning with `linter_1`.

The site will be available at [`http://localhost:8000`](http://localhost:8000)

To stop the site, type `[Ctrl]+C` then run

```
docker-compose down -v
```

## Adding a Post

To create a post, add a [markdown](https://kramdown.gettalong.org/quickref.html)
or [reStructuredText](http://docutils.sourceforge.net/rst.html) file
to the `generator/source/_posts` directory with the following format:

```
YEAR-MONTH-DAY-title.MARKUP
```

Where `YEAR` is a four-digit number, `MONTH` and `DAY` are both two-digit
numbers, and `MARKUP` is the file extension representing the format used in the
file. For example, the following are examples of valid post filenames:

```
2019-04-23-hyperledger-is-awesome.md
2019-09-12-how-to-write-a-how-to.rst
```

All post files must begin with front matter which is typically used to set a
layout or other meta data.

```
---
layout: post
title: Hyperledger Sawtooth, Seth and Truffle 101
categories: [certification, hyperledger]
tags: [cert, calendar]
---

Excerpt from [hyperledger.org](https://www.hyperledger.org/blog/2018/07/24
/hyperledger-sawtooth-seth-and-truffle-101)

I develop on both Hyperledger Fabric/Sawtooth and Ethereum (to be specified,
Quorum) so I am familiar with the languages available on both platform —
chaincode (Go) and smart contract (Solidity). Often I am asked this question:
“Which platform is better?” To which I will answer, this question is a false
choice as with Hyperledger Sawtooth Seth, you can build your smart contracts in
Solidity and deploy the same smart contract in Hyperledger Sawtooth — Pretty
cool isn’t it? ...
```

## Editing Site Content

Change the content of `/`, `/contact/`, `/about/`,
etc., by editing the files in `/generator/source/`.

E.g., `/generator/source/index.md`, `/generator/source/contact.md` and
`/generator/source/about.md`

## LICENSE

* This documentation and the content herein is covered by [
  Creative Commons Attribution 4.0 International License](
  http://creativecommons.org/licenses/by/4.0/ "license") unless otherwise stated.
* Jekyll (docker-compose.yaml) is used under LICENSE-MIT
* The Jekyll Type theme is used under generator/source/LICENSE (MIT)
* Markdown lint tool (docker-compose.yaml) is used under LICENSE-MIT


