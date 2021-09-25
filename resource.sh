#!/bin/sh
echo '['

echo '{"item":"dt","value":"'$(date "+%Y%m%d%H%M%S")'"}'

echo ','
cat /proc/uptime \
  | sed \
    -e 's/ .*$//' \
    -e 's/^/{"item":"uptime","value":/' \
    -e 's/$/}/'

echo ','
uptime \
  | sed \
    -e 's/ *users,.*$//' \
    -e 's/.*, *//' \
    -e 's/^/{"item":"users","value":/' \
    -e 's/$/}/'

echo ','
cat /proc/loadavg \
  | awk '{printf "{\"item\":\"loadavg\",\"value\":[%s,%s,%s]}\n",$1,$2,$3}'

echo ','
echo '{"item":"mem","value":['
cat /proc/meminfo \
  | egrep '^(MemTotal|MemFree|MemAvailable|Buffers|Cached)' \
  | sed -e 's/: */ /' \
  | awk '{printf "{\"name\":\"%s\",\"value\":%d}", $1, $2}' \
  | sed -e 's/}{/},{/g'
echo ''
echo ']}'

echo ','
echo '{"item":"disk","value":['
df \
  | egrep -v '^Filesystem' \
  | awk '{printf "{\"name\":\"%s\",\"value\":[%d,%d,%5.5f]}", $6,$3,$4,$3/$4}' \
  | sed -e 's/}{/},{/g'
echo ''
echo ']}'

if [ -f /sys/class/hwmon/hwmon0/temp1_input ]; then
  echo ','
  cat /sys/class/hwmon/hwmon0/temp1_input \
    | sed \
      -e 's/^temp *= *//' \
      -e 's/[^0-9.]*$//' \
      -e 's/^/{"item":"temperature","value":/' \
      -e 's/$/}/'
fi

echo ']'
