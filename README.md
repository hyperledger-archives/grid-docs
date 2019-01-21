# grid-website

## Preview and Review

You'll need to install
[Docker and Compose](https://docs.docker.com/compose/install/)

From a local clone of
[the repository](https://github.com/hyperledger/grid-website), run

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

## Editing Site Content

Change the content of `/`, `/community/`, `/about/`,
etc., by editing the files in `/generator/source/`.

E.g., `/generator/source/index.md`, `/generator/source/community/community.rst`
and `/generator/source/about.md`

## LICENSE

* This documentation and the content herein is covered by [
  Creative Commons Attribution 4.0 International License](
  http://creativecommons.org/licenses/by/4.0/ "license") unless otherwise stated.
* Jekyll (docker-compose.yaml) is used under LICENSE-MIT
* The Jekyll Type theme is used under generator/source/LICENSE (MIT)
* Markdown lint tool (docker-compose.yaml) is used under LICENSE-MIT
