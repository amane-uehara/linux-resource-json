#!/bin/sh

dt=$1
JSON_FILE=$2
UPTIME_FILE=$3
USERS_FILE=$4
LOADAVG_FILE=$5
MEM_FILE=$6
DISK_FILE=$7
TEMPERATURE_FILE=$8

cat ${JSON_FILE} \
  | jq -r '.[] | select(.item == "uptime") | .value' \
  | sed -e "s/^/\"${dt}\",/" \
  > ${UPTIME_FILE}

cat ${JSON_FILE} \
  | jq -r '.[] | select(.item == "users") | .value' \
  | sed -e "s/^/\"${dt}\",/" \
  > ${USERS_FILE}

cat ${JSON_FILE} \
  | jq -r '.[] | select(.item == "loadavg") | .value | [.minute1, .minute5, .minute15] | @csv' \
  | sed -e "s/^/\"${dt}\",/" \
  > ${LOADAVG_FILE}

cat ${JSON_FILE} \
  | jq -r '.[] | select(.item == "mem") | .value | .[] | [.name, .size, .ratio] | @csv' \
  | sed -e "s/^/\"${dt}\",/" \
  > ${MEM_FILE}

cat ${JSON_FILE} \
  | jq -r '.[] | select(.item == "disk") | .value | .[] | [.name, (.value | .full), (.value | .used), (.value | .ratio)] | @csv' \
  | sed -e "s/^/\"${dt}\",/" \
  > ${DISK_FILE}

cat ${JSON_FILE} \
  | jq -r '.[] | select(.item == "temperature") | .value' \
  | sed -e "s/^/\"${dt}\",/" \
  > ${TEMPERATURE_FILE}
