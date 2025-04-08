#!/bin/bash

# Проверяем, какой топик использовать
if [ -z "$1" ]; then
  echo "Использование: $0 <topic-name>"
  echo "Пример: $0 topic-1"
  exit 1
fi

TOPIC=$1

# Отправка сообщений в топик
echo "Отправка сообщений в $TOPIC..."
for i in {1..5}; do
  echo "Сообщение $i в топик $TOPIC" | docker exec -i broker1 kafka-console-producer.sh --topic $TOPIC --bootstrap-server broker1:9093 --producer.config /opt/bitnami/kafka/config/certs/client-ssl.properties
  sleep 1
done

echo "Сообщения отправлены в $TOPIC"