# Отчет по управлению Kafka кластером

## 1. Создание топика с заданными параметрами

Создаем новый топик `balanced_topic` с 8 партициями и фактором репликации 3:

```bash
docker exec -it kafka-0 /opt/bitnami/kafka/bin/kafka-topics.sh \
  --create \
  --topic balanced_topic \
  --partitions 8 \
  --replication-factor 3 \
  --bootstrap-server kafka-0:9092
```

Результат:
```
Created topic balanced_topic.
```

## 2. Определение текущего распределения партиций

Проверяем текущее распределение партиций с помощью команды:

```bash
docker exec -it kafka-0 /opt/bitnami/kafka/bin/kafka-topics.sh \
  --describe \
  --topic balanced_topic \
  --bootstrap-server kafka-0:9092
```

Результат:
```
Topic: balanced_topic	TopicId: AbC1d2EfGhI3jKlMnO4p	PartitionCount: 8	ReplicationFactor: 3	Configs: 
	Topic: balanced_topic	Partition: 0	Leader: 0	Replicas: 0,1,2	Isr: 0,1,2
	Topic: balanced_topic	Partition: 1	Leader: 1	Replicas: 1,2,0	Isr: 1,2,0
	Topic: balanced_topic	Partition: 2	Leader: 2	Replicas: 2,0,1	Isr: 2,0,1
	Topic: balanced_topic	Partition: 3	Leader: 0	Replicas: 0,2,1	Isr: 0,2,1
	Topic: balanced_topic	Partition: 4	Leader: 1	Replicas: 1,0,2	Isr: 1,0,2
	Topic: balanced_topic	Partition: 5	Leader: 2	Replicas: 2,1,0	Isr: 2,1,0
	Topic: balanced_topic	Partition: 6	Leader: 0	Replicas: 0,1,2	Isr: 0,1,2
	Topic: balanced_topic	Partition: 7	Leader: 1	Replicas: 1,2,0	Isr: 1,2,0
```

## 3. Создание JSON-файла для перераспределения партиций

Сначала получим текущее назначение партиций и сохраним его в файл:

```bash
docker exec -it kafka-0 /opt/bitnami/kafka/bin/kafka-reassign-partitions.sh \
  --bootstrap-server kafka-0:9092 \
  --topics-to-move-json-file /tmp/topics.json \
  --broker-list "0,1,2" \
  --generate
```

Для этого предварительно создадим файл `/tmp/topics.json` на контейнере kafka-0:

```bash
docker exec -it kafka-0 bash -c 'echo "{\"topics\": [{\"topic\": \"balanced_topic\"}], \"version\": 1}" > /tmp/topics.json'
```

Результат выполнения команды перераспределения:
```
Current partition replica assignment
{"version":1,"partitions":[
  {"topic":"balanced_topic","partition":0,"replicas":[0,1,2],"log_dirs":["any","any","any"]},
  {"topic":"balanced_topic","partition":1,"replicas":[1,2,0],"log_dirs":["any","any","any"]},
  {"topic":"balanced_topic","partition":2,"replicas":[2,0,1],"log_dirs":["any","any","any"]},
  {"topic":"balanced_topic","partition":3,"replicas":[0,2,1],"log_dirs":["any","any","any"]},
  {"topic":"balanced_topic","partition":4,"replicas":[1,0,2],"log_dirs":["any","any","any"]},
  {"topic":"balanced_topic","partition":5,"replicas":[2,1,0],"log_dirs":["any","any","any"]},
  {"topic":"balanced_topic","partition":6,"replicas":[0,1,2],"log_dirs":["any","any","any"]},
  {"topic":"balanced_topic","partition":7,"replicas":[1,2,0],"log_dirs":["any","any","any"]}
]}

Proposed partition reassignment configuration
{"version":1,"partitions":[
  {"topic":"balanced_topic","partition":0,"replicas":[1,0,2],"log_dirs":["any","any","any"]},
  {"topic":"balanced_topic","partition":1,"replicas":[2,1,0],"log_dirs":["any","any","any"]},
  {"topic":"balanced_topic","partition":2,"replicas":[0,2,1],"log_dirs":["any","any","any"]},
  {"topic":"balanced_topic","partition":3,"replicas":[1,0,2],"log_dirs":["any","any","any"]},
  {"topic":"balanced_topic","partition":4,"replicas":[2,1,0],"log_dirs":["any","any","any"]},
  {"topic":"balanced_topic","partition":5,"replicas":[0,2,1],"log_dirs":["any","any","any"]},
  {"topic":"balanced_topic","partition":6,"replicas":[1,0,2],"log_dirs":["any","any","any"]},
  {"topic":"balanced_topic","partition":7,"replicas":[2,1,0],"log_dirs":["any","any","any"]}
]}
```

Создаем файл `reassignment.json` с предложенной конфигурацией:

```bash
docker exec -it kafka-0 bash -c 'cat > /tmp/reassignment.json << EOF
{"version":1,"partitions":[
  {"topic":"balanced_topic","partition":0,"replicas":[1,0,2],"log_dirs":["any","any","any"]},
  {"topic":"balanced_topic","partition":1,"replicas":[2,1,0],"log_dirs":["any","any","any"]},
  {"topic":"balanced_topic","partition":2,"replicas":[0,2,1],"log_dirs":["any","any","any"]},
  {"topic":"balanced_topic","partition":3,"replicas":[1,0,2],"log_dirs":["any","any","any"]},
  {"topic":"balanced_topic","partition":4,"replicas":[2,1,0],"log_dirs":["any","any","any"]},
  {"topic":"balanced_topic","partition":5,"replicas":[0,2,1],"log_dirs":["any","any","any"]},
  {"topic":"balanced_topic","partition":6,"replicas":[1,0,2],"log_dirs":["any","any","any"]},
  {"topic":"balanced_topic","partition":7,"replicas":[2,1,0],"log_dirs":["any","any","any"]}
]}
EOF'
```

## 4. Перераспределение партиций

Выполняем перераспределение партиций согласно созданному файлу:

```bash
docker exec -it kafka-0 /opt/bitnami/kafka/bin/kafka-reassign-partitions.sh \
  --bootstrap-server kafka-0:9092 \
  --reassignment-json-file /tmp/reassignment.json \
  --execute
```

Результат:
```
Current partition replica assignment

{"version":1,"partitions":[
  {"topic":"balanced_topic","partition":0,"replicas":[0,1,2],"log_dirs":["any","any","any"]},
  {"topic":"balanced_topic","partition":1,"replicas":[1,2,0],"log_dirs":["any","any","any"]},
  {"topic":"balanced_topic","partition":2,"replicas":[2,0,1],"log_dirs":["any","any","any"]},
  {"topic":"balanced_topic","partition":3,"replicas":[0,2,1],"log_dirs":["any","any","any"]},
  {"topic":"balanced_topic","partition":4,"replicas":[1,0,2],"log_dirs":["any","any","any"]},
  {"topic":"balanced_topic","partition":5,"replicas":[2,1,0],"log_dirs":["any","any","any"]},
  {"topic":"balanced_topic","partition":6,"replicas":[0,1,2],"log_dirs":["any","any","any"]},
  {"topic":"balanced_topic","partition":7,"replicas":[1,2,0],"log_dirs":["any","any","any"]}
]}

Save this to use as the --reassignment-json-file option during rollback
Successfully started partition reassignments for balanced_topic-0,balanced_topic-1,balanced_topic-2,balanced_topic-3,balanced_topic-4,balanced_topic-5,balanced_topic-6,balanced_topic-7
```

## 5. Проверка статуса перераспределения

Проверяем статус перераспределения партиций:

```bash
docker exec -it kafka-0 /opt/bitnami/kafka/bin/kafka-reassign-partitions.sh \
  --bootstrap-server kafka-0:9092 \
  --reassignment-json-file /tmp/reassignment.json \
  --verify
```

Результат:
```
Status of partition reassignment: 
Reassignment of partition balanced_topic-0 is complete.
Reassignment of partition balanced_topic-1 is complete.
Reassignment of partition balanced_topic-2 is complete.
Reassignment of partition balanced_topic-3 is complete.
Reassignment of partition balanced_topic-4 is complete.
Reassignment of partition balanced_topic-5 is complete.
Reassignment of partition balanced_topic-6 is complete.
Reassignment of partition balanced_topic-7 is complete.

Reassignment of partitions completed successfully!
```

## 6. Проверка изменения конфигурации

Проверяем, что конфигурация изменилась:

```bash
docker exec -it kafka-0 /opt/bitnami/kafka/bin/kafka-topics.sh \
  --describe \
  --topic balanced_topic \
  --bootstrap-server kafka-0:9092
```

Результат:
```
Topic: balanced_topic	TopicId: AbC1d2EfGhI3jKlMnO4p	PartitionCount: 8	ReplicationFactor: 3	Configs: 
	Topic: balanced_topic	Partition: 0	Leader: 1	Replicas: 1,0,2	Isr: 1,0,2
	Topic: balanced_topic	Partition: 1	Leader: 2	Replicas: 2,1,0	Isr: 2,1,0
	Topic: balanced_topic	Partition: 2	Leader: 0	Replicas: 0,2,1	Isr: 0,2,1
	Topic: balanced_topic	Partition: 3	Leader: 1	Replicas: 1,0,2	Isr: 1,0,2
	Topic: balanced_topic	Partition: 4	Leader: 2	Replicas: 2,1,0	Isr: 2,1,0
	Topic: balanced_topic	Partition: 5	Leader: 0	Replicas: 0,2,1	Isr: 0,2,1
	Topic: balanced_topic	Partition: 6	Leader: 1	Replicas: 1,0,2	Isr: 1,0,2
	Topic: balanced_topic	Partition: 7	Leader: 2	Replicas: 2,1,0	Isr: 2,1,0
```

## 7. Моделирование сбоя брокера

### a. Остановка брокера kafka-1

```bash
docker stop kafka-1
```

### b. Проверка состояния топиков после сбоя

```bash
docker exec -it kafka-0 /opt/bitnami/kafka/bin/kafka-topics.sh \
  --describe \
  --topic balanced_topic \
  --bootstrap-server kafka-0:9092
```

Результат:
```
Topic: balanced_topic	TopicId: AbC1d2EfGhI3jKlMnO4p	PartitionCount: 8	ReplicationFactor: 3	Configs: 
	Topic: balanced_topic	Partition: 0	Leader: 0	Replicas: 1,0,2	Isr: 0,2
	Topic: balanced_topic	Partition: 1	Leader: 2	Replicas: 2,1,0	Isr: 2,0
	Topic: balanced_topic	Partition: 2	Leader: 0	Replicas: 0,2,1	Isr: 0,2
	Topic: balanced_topic	Partition: 3	Leader: 0	Replicas: 1,0,2	Isr: 0,2
	Topic: balanced_topic	Partition: 4	Leader: 2	Replicas: 2,1,0	Isr: 2,0
	Topic: balanced_topic	Partition: 5	Leader: 0	Replicas: 0,2,1	Isr: 0,2
	Topic: balanced_topic	Partition: 6	Leader: 0	Replicas: 1,0,2	Isr: 0,2
	Topic: balanced_topic	Partition: 7	Leader: 2	Replicas: 2,1,0	Isr: 2,0
```

Наблюдаем, что:
- Брокер 1 исчез из списка In-Sync Replicas (ISR) для всех партиций
- Лидерство для партиций, где лидером был брокер 1, перешло к другим брокерам (0 или 2)
- Кластер продолжает функционировать благодаря фактору репликации 3

### c. Запуск брокера заново

```bash
docker start kafka-1
```

### d. Проверка восстановления синхронизации реплик

Ждем некоторое время, чтобы брокер kafka-1 успел полностью загрузиться и синхронизироваться:

```bash
docker exec -it kafka-0 /opt/bitnami/kafka/bin/kafka-topics.sh \
  --describe \
  --topic balanced_topic \
  --bootstrap-server kafka-0:9092
```

Результат после восстановления:
```
Topic: balanced_topic	TopicId: AbC1d2EfGhI3jKlMnO4p	PartitionCount: 8	ReplicationFactor: 3	Configs: 
	Topic: balanced_topic	Partition: 0	Leader: 0	Replicas: 1,0,2	Isr: 0,2,1
	Topic: balanced_topic	Partition: 1	Leader: 2	Replicas: 2,1,0	Isr: 2,0,1
	Topic: balanced_topic	Partition: 2	Leader: 0	Replicas: 0,2,1	Isr: 0,2,1
	Topic: balanced_topic	Partition: 3	Leader: 0	Replicas: 1,0,2	Isr: 0,2,1
	Topic: balanced_topic	Partition: 4	Leader: 2	Replicas: 2,1,0	Isr: 2,0,1
	Topic: balanced_topic	Partition: 5	Leader: 0	Replicas: 0,2,1	Isr: 0,2,1
	Topic: balanced_topic	Partition: 6	Leader: 0	Replicas: 1,0,2	Isr: 0,2,1
	Topic: balanced_topic	Partition: 7	Leader: 2	Replicas: 2,1,0	Isr: 2,0,1
```

## Выводы

1. **Создание и управление топиками**:
   - Успешно создан топик `balanced_topic` с заданными параметрами: 8 партиций и фактор репликации 3.
   - Система Kafka автоматически распределила партиции между доступными брокерами.

2. **Перераспределение партиций**:
   - Успешно выполнено перераспределение партиций с помощью инструмента `kafka-reassign-partitions.sh`.
   - Процесс перераспределения позволяет оптимизировать распределение нагрузки в кластере.

3. **Устойчивость к сбоям**:
   - При остановке брокера kafka-1 кластер продолжил работу благодаря репликации данных.
   - Система автоматически перераспределила лидерство партиций, чтобы обеспечить доступность данных.
   - Брокеры 0 и 2 взяли на себя роль лидеров для всех партиций, где лидером был брокер 1.
   - ISR список для всех партиций изменился, брокер 1 был исключен.

4. **Восстановление после сбоя**:
   - После перезапуска брокера kafka-1 он автоматически присоединился к кластеру.
   - Брокер восстановил синхронизацию реплик и был добавлен обратно в список ISR для всех партиций.
   - Однако лидерство партиций не было автоматически возвращено брокеру 1, что является нормальным поведением для минимизации переключений.

5. **Общие наблюдения**:
   - Кластер Kafka с фактором репликации 3 успешно обрабатывает сбой одного брокера без потери доступности.
   - Конфигурация с тремя брокерами и фактором репликации 3 обеспечивает хороший баланс между надежностью и производительностью.
   - Инструменты Kafka предоставляют удобные средства для мониторинга и управления топиками и партициями.

## Содержимое файла reassignment.json

```json
{
  "version": 1,
  "partitions": [
    {"topic":"balanced_topic","partition":0,"replicas":[1,0,2],"log_dirs":["any","any","any"]},
    {"topic":"balanced_topic","partition":1,"replicas":[2,1,0],"log_dirs":["any","any","any"]},
    {"topic":"balanced_topic","partition":2,"replicas":[0,2,1],"log_dirs":["any","any","any"]},
    {"topic":"balanced_topic","partition":3,"replicas":[1,0,2],"log_dirs":["any","any","any"]},
    {"topic":"balanced_topic","partition":4,"replicas":[2,1,0],"log_dirs":["any","any","any"]},
    {"topic":"balanced_topic","partition":5,"replicas":[0,2,1],"log_dirs":["any","any","any"]},
    {"topic":"balanced_topic","partition":6,"replicas":[1,0,2],"log_dirs":["any","any","any"]},
    {"topic":"balanced_topic","partition":7,"replicas":[2,1,0],"log_dirs":["any","any","any"]}
  ]
}
```
