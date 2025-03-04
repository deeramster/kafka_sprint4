#!/bin/bash

# Запуск скрипта генерации сертификатов
echo "Генерация сертификатов..."
chmod +x generate-certs.sh
./generate-certs.sh

# Запуск Docker Compose
echo "Запуск кластера Kafka..."
docker-compose up -d

# Создание директорий для сертификатов в контейнерах
docker exec broker1 mkdir -p /opt/bitnami/kafka/config/certs
docker exec broker2 mkdir -p /opt/bitnami/kafka/config/certs
docker exec broker3 mkdir -p /opt/bitnami/kafka/config/certs

# Ожидание запуска брокеров
echo "Ожидание запуска брокеров..."
sleep 30

# Настройка топиков и ACL
echo "Настройка топиков и прав доступа..."
chmod +x setup-topics.sh
./setup-topics.sh

echo "Кластер Kafka успешно запущен с SSL и ACL."
echo "Теперь вы можете использовать скрипты producer.sh и consumer.sh для тестирования:"
echo "  ./producer.sh topic-1  - для отправки сообщений в топик-1"
echo "  ./consumer.sh topic-1  - для чтения сообщений из топика-1"
echo "  ./producer.sh topic-2  - для отправки сообщений в топик-2"
echo "  ./consumer.sh topic-2  - для чтения сообщений из топика-2 (должно завершиться ошибкой доступа)"