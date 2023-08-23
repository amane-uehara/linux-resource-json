#!/bin/sh

# find . -type f -iname '*.json*' |xargs -I{} sh debug-disk-usage.sh {}

if echo $1 |grep 'json.gz$' > /dev/null ;then
  echo "debug $1" 1>&2
  zcat $1 \
    | jq '.[][5].value |= map(.value.full = .value.full + .value.used) |
          .[][5].value |= map(.value.used = .value.full - .value.used) |
          .[][5].value |= map(.value.ratio = (.value.used / .value.full * 100000 | floor) / 100000)
          ' \
    | gzip -c > ${1}_new
  mv ${1}_new $1
fi

if echo $1 |grep 'json$' > /dev/null ;then
  echo "debug $1" 1>&2
  cat $1 \
    | jq '.[5].value |= map(.value.full = .value.full + .value.used) |
          .[5].value |= map(.value.used = .value.full - .value.used) |
          .[5].value |= map(.value.ratio = (.value.used / .value.full * 100000 | floor) / 100000)
          ' \
    > ${1}_new
  mv ${1}_new $1
fi

