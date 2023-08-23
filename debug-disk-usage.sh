#!/bin/sh

if echo $1 |grep 'json.gz$' > /dev/null ;then
  zcat $1 \
    | jq '.[][5].value |= map(.value.full = .value.full + .value.used) |
          .[][5].value |= map(.value.used = .value.full - .value.used) |
          .[][5].value |= map(.value.ratio = (.value.used / .value.full * 100000 | floor) / 100000)
          ' \
    | gzip -c > new_$1
  mv new_$1 $1
fi

if echo $1 |grep 'json$' > /dev/null ;then
  cat $1 \
    | jq '.[][5].value |= map(.value.full = .value.full + .value.used) |
          .[][5].value |= map(.value.used = .value.full - .value.used) |
          .[][5].value |= map(.value.ratio = (.value.used / .value.full * 100000 | floor) / 100000)
          ' \
    > new_$1
  mv new_$1 $1
fi

