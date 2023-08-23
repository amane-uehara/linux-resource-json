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
  | awk '{printf "{\"item\":\"loadavg\",\"value\":{\"minute1\":%s,\"minute5\":%s,\"minute15\":%s}}\n",$1,$2,$3}'

echo ','
MEMTOTAL=$(cat /proc/meminfo |egrep 'MemTotal' |awk '{print $2}')
echo '{"item":"mem","value":['
cat /proc/meminfo \
  | egrep '^(MemTotal|MemFree|MemAvailable|Buffers|Cached)' \
  | sed -e 's/: */ /' \
  | awk "{printf \"{\\\"name\\\":\\\"%s\\\",\\\"size\\\":%d,\\\"ratio\\\":%5.5f}\", \$1, \$2, \$2/$MEMTOTAL}" \
  | sed -e 's/}{/},{/g'
echo ''
echo ']}'

echo ','
echo '{"item":"disk","value":['
df \
  | egrep -v '^Filesystem' \
  | awk '{printf "{\"name\":\"%s\",\"value\":{\"full\":%d,\"used\":%d,\"ratio\":%5.5f}}", $6,$2,$3,$3/$2}' \
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
