#!/bin/sh
# Copyright (c) 2018 Bitwise IO, Inc.
# Licensed under Creative Commons Attribution 4.0 International License
# https://creativecommons.org/licenses/by/4.0/

cd /srv/jekyll/

pip install pygments

MD_ISSUES="$(mdl -i -r ~MD033 ./source 2>&1)"
EXITCODE=$?

RST_ISSUES="$(find ./source -name '*.rst' | xargs rst-lint --level warning)"
EXITCODE=$(($EXITCODE + $?))

if [ $EXITCODE -ne 0 ]; then
    echo -e '\e[93m=== START LINTING ===\e[0m'
    echo -e '\e[93m=== Markdown ===\e[0m'
    echo -e "$(echo "$MD_ISSUES" | sed 's/^/\\e[31m/')\n"
    echo -e '\e[93m=== reStructuredText ===\e[0m'
    echo -e "$(echo "$RST_ISSUES" | sed 's/^/\\e[31m/')\n"
    echo -e "\e[93mRemediate these formating issues before creating a PR\e[0m\n"
    echo -e '\e[93m=== END LINTING ===\e[0m'
    echo "<pre>${MD_ISSUES}</pre>" > /srv/jekyll/_site/mdl.html
    echo "<pre>${RST_ISSUES}</pre>" > /srv/jekyll/_site/rst.html
else
    echo -e '\e[32m=== NO LINTING ERRORS FOUND ===\e[0m'
fi

touch /srv/jekyll/lint.complete

exit $EXITCODE