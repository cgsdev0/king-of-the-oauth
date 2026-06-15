#!/usr/bin/env bash

cd "${0%/*}"

[[ -f 'config.sh' ]] && source config.sh

if [[ "${DEV:-true}" == "true" ]] && [[ ! -z "$TAILWIND" ]]; then
   npx tailwindcss@v3 -i ./static/style.css -o ./static/tailwind.css --watch=always 2>&1 \
     | sed '/^[[:space:]]*$/d;s/^/[tailwind] /' &
   PID=$!
fi

if [[ "${DEV:-true}" != "true" ]]; then
  export ROUTES_CACHE=$(mktemp)
fi

# remove any old subscriptions; they are no longer valid
rm -rf pubsub

mkdir -p sessions
mkdir -p pubsub
mkdir -p data
mkdir -p uploads

PORT=${PORT:-3000}

TCP_PROVIDER=${TCP_PROVIDER:-tcpserver}

function publish() {
  local TOPIC
  local line
  TOPIC="$1"
  if [[ -z "$TOPIC" ]]; then
    return
  fi
  if [[ ! -d "pubsub/${TOPIC}" ]]; then
    return
  fi
  TEE_ARGS=$(find pubsub/"${TOPIC}" -type p)
  if [[ -z "$TEE_ARGS" ]]; then
    return
  fi
  tee $TEE_ARGS > /dev/null
}

heartbeat() {
  while true; do
    printf ": \n\n" | publish leaderboard
    sleep 20
  done
}

heartbeat &

case "$TCP_PROVIDER" in
  tcpserver)
    echo -n "Listening on port "
    tcpserver -1 -o -l 0 -H -R -c 1000 0 $PORT ./core.sh
    ;;
  nc)
    [[ ! -p nc_tunnel ]] && mkfifo nc_tunnel
    [[ "${DEV:-true}" == true ]] && \
      echo "WARNING: performance while using netcat will be significantly degraded!"
    echo "Listening on port $PORT"
    while true; do
      < nc_tunnel nc -l $PORT | ./core.sh >nc_tunnel
    done
    ;;
  *)
    echo "ERROR: unsupported TCP_PROVIDER"
    exit 1
    ;;
esac

if [[ ! -z "$PID" ]]; then
  kill "$PID"
fi
