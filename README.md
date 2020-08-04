# grid-website

The grid-website repository contains source code and assets for the
[Hyperledger Grid website](https://grid.hyperledger.org).

## Building the Website Locally

This repository includes a docker-compose file that builds and runs the website
in a Docker container.

Prerequisites:
[Docker Engine and Docker Compose](https://docs.docker.com/compose/install/)
must be installed and running.

1. Create a local clone of the
   [grid-website repository](https://github.com/hyperledger/grid-website).


2. Change to the root directory of your local clone, then run the following
   command:

    ```
    docker-compose up
    ```

3. When this command finishes, the site will be available at
   <http://localhost:4000>.

To stop the Docker container, enter `[Ctrl]+C` in the same terminal window
where you ran `docker-compose up`, then run this command:

```
docker-compose down -v
```

## Website Content

The content for the website's pages (Home, About, Community, etc.) is written in
[Markdown](https://www.markdownguide.org).

## License

The Grid website and the content in this repository are covered by the
[Creative Commons Attribution 4.0 International license](http://creativecommons.org/licenses/by/4.0/)
(CC BY 4.0) unless otherwise noted.

Portions of the Grid website are generated with
[Jekyll](https://github.com/jekyll/jekyll), which is used under the
[MIT license](https://github.com/jekyll/jekyll/blob/master/LICENSE).

Website generation includes the
[Markdown lint tool](https://github.com/markdownlint/markdownlint),
which is used under the
[MIT license](https://github.com/markdownlint/markdownlint/blob/master/LICENSE.txt).
