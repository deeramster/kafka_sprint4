#!/bin/bash

# Проверяем, какой топик использовать
if [ -z "$1" ]; then
  echo "Использование: $0 <topic-name>"
  echo "Пример: $0 topic-1"
  exit 1
fi

TOPIC=$1

# Получение сообщений из топика
echo "Чтение сообщений из $TOPIC..."
docker exec broker1 kafka-console-consumer.sh --topic $TOPIC --from-beginning --bootstrap-server broker1:9093 --consumer.config /opt/bitnami/kafka/config/certs/client-ssl.properties --timeout-ms 10000