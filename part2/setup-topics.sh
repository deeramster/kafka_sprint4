#!/bin/bash

# Сначала настраиваем ACL для доступа к серверу
echo "Настройка базовых прав доступа..."
docker exec broker1 kafka-acls.sh --add --allow-principal "User:CN=client.kafka.ssl,OU=Test,O=Company,L=City,ST=State,C=RU" \
  --operation ALL --cluster \
  --bootstrap-server broker1:9093 --command-config /opt/bitnami/kafka/config/certs/client-ssl.properties

# После этого создаем топики
echo "Создание топика topic-1..."
docker exec broker1 kafka-topics.sh --create --topic topic-1 --partitions 3 --replication-factor 3 \
  --bootstrap-server broker1:9093 --command-config /opt/bitnami/kafka/config/certs/client-ssl.properties

echo "Создание топика topic-2..."
docker exec broker1 kafka-topics.sh --create --topic topic-2 --partitions 3 --replication-factor 3 \
  --bootstrap-server broker1:9093 --command-config /opt/bitnami/kafka/config/certs/client-ssl.properties

# Затем настраиваем ACL для конкретных топиков
echo "Настройка ACL для topic-1..."
docker exec broker1 kafka-acls.sh --add --allow-principal "User:CN=client.kafka.ssl,OU=Test,O=Company,L=City,ST=State,C=RU" \
  --operation READ --operation WRITE \
  --topic topic-1 \
  --bootstrap-server broker1:9093 --command-config /opt/bitnami/kafka/config/certs/client-ssl.properties

echo "Настройка ACL для topic-2..."
docker exec broker1 kafka-acls.sh --add --allow-principal "User:CN=client.kafka.ssl,OU=Test,O=Company,L=City,ST=State,C=RU" \
  --operation WRITE \
  --topic topic-2 \
  --bootstrap-server broker1:9093 --command-config /opt/bitnami/kafka/config/certs/client-ssl.properties

echo "Права доступа настроены."

echo "Список топиков:"
docker exec broker1 kafka-topics.sh --list --bootstrap-server broker1:9093 --command-config /opt/bitnami/kafka/config/certs/client-ssl.properties