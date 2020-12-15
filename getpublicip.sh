#!/bin/bash
gistid=526918503e22431f4e04434efeb3b7f7
curl https://api.github.com/gists/$gistid |jq '.files.nuc1.content'

