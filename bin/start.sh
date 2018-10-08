#!/usr/bin/env  sh

set -e

# npm run js &
# P1=$!
npm run build:watch &
P2=$!
npm run start:dev &
P3=$!

# npm run reload &
# http-server -c1 &
wait -n $P2 $P3
