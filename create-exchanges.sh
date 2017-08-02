#!/usr/bin/env bash

RMQ_ADDR="rmq:15672"

function await_ready_rmq {
  until curl -q $RMQ_ADDR/api/exchanges 2>/dev/null >&2
  do
    echo "Waiting for RMQ to come-up at $RMQ_ADDR"
    sleep 2
  done
}

function create_exchange {
  EXCHANGE_NAME="$1"
  curl -is -u guest:guest -H "content-type:application/json" \
    -XPUT -d'{"type":"direct","auto_delete":false,"durable":true,"arguments":[]}' \
    http://$RMQ_ADDR/api/exchanges/%2f/$EXCHANGE_NAME >/dev/null
  echo "Exchange $EXCHANGE_NAME created"
}

function create_queue_and_binding {
  EXCHANGE_NAME=$1
  QUEUE_NAME=$2
  ROUTING_KEY=$3
  curl -is -u guest:guest -H "content-type:application/json" \
    -XPUT -d'{"auto_delete":false,"durable":true,"exclusive":false,"arguments":[]}' \
    http://$RMQ_ADDR/api/queues/%2f/$QUEUE_NAME >/dev/null
  echo "Queue $QUEUE_NAME created"
  curl -is -u guest:guest -H "content-type:application/json" \
    -XPOST -d'{"routing_key":"'"$ROUTING_KEY"'","arguments":[]}' \
    "http://$RMQ_ADDR/api/bindings/%2f/e/$EXCHANGE_NAME/q/$QUEUE_NAME/" >/dev/null
  echo "Queue $QUEUE_NAME bound to exchange $EXCHANGE_NAME through routing key $ROUTING_KEY"
}

await_ready_rmq
create_exchange "sessions"
create_exchange "ocpp"
create_queue_and_binding "sessions" "sessions.raw.cb-service" "sessions.raw"
create_queue_and_binding "sessions" "sessions.with-evse.pricing-service" "sessions.with-evse"
create_queue_and_binding "sessions" "transactions.tx-service" "transactions"
create_queue_and_binding "ocpp" "ocpp.msgs.log-service" "ocpp.msgs"
create_queue_and_binding "ocpp" "ocpp.connection-events.cb-service" "ocpp.connection-events"
