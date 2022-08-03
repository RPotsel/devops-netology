
# 11.02 Микросервисы: принципы - Роман Поцелуев

Вы работаете в крупной компанию, которая строит систему на основе микросервисной архитектуры.
Вам как DevOps специалисту необходимо выдвинуть предложение по организации инфраструктуры, для разработки и эксплуатации.

## Задача 1: API Gateway 

Предложите решение для обеспечения реализации API Gateway. Составьте сравнительную таблицу возможностей различных программных решений. На основе таблицы сделайте выбор решения.

Решение должно соответствовать следующим требованиям:
- Маршрутизация запросов к нужному сервису на основе конфигурации
- Возможность проверки аутентификационной информации в запросах
- Обеспечение терминации HTTPS

Обоснуйте свой выбор.

__Ответ:__

API Gateway представляет собой шлюз между клиентом и набором внутренних сервисов (API), выполняющий функцию обратного прокси. Но роутинг - это не единственная его задача, есть еще сотни инфраструктурных задач, которые может выполнять в API Gateway: Application firewall/Rate limits, Authentication, Metrics/monitoring/logging, SSL termination, Secure breaker, Retry, Caching и т.д. Список реализаций API Gateway можно посмотреть  фонде [Cloud Native Computing Foundation](https://landscape.cncf.io/card-mode?category=api-gateway&grouping=category&sort=stars), возьмем несколько самых популярных и составим сравнительную таблицу.

| Продукт | Маршрутизация | Аутентификация | Терминация HTTPS |
|---|---|---|---|
| Kong | Да | Да | Да |
| Sentinel | Да | Да | Да |
| APISIX | Да | Да | Да |
| Tyk | Да | Да | Да |
| KrakenD | Да | Да | Да |

Кам мы видим, все продукты подходят для использования в нашем проекте. Можно остановить свой выбор на Kong. Перечислим основные его плюсы:  
- полностью бесплатный;
- платформо-независимый; 
- есть готовые сборки для Kubernetes, Docker Swarm, Mesos и его можно запускать на bare metal серверах; 
- есть динамический алгоритм балансировки трафика, встроенные secure breaker, healthcheck, активный и пассивный мониторинг upstream, интеграции с разными 3rd party DNS-резолверами (Consul), встроенный auth2.0);
- есть механизмы авторизации пользователя (от jwt-токенов до обычной сессионной куки);
- на GitHub можно найти много плагинов, которые расширят его возможности.

При использовании облачной архитектуры, лучшим выбором будет предлагаемое провайдером решение: Amazon API Gateway, Google API Gateway, SberCloud API Gateway, Yandex API Gateway и т.д.

## Задача 2: Брокер сообщений

Составьте таблицу возможностей различных брокеров сообщений. На основе таблицы сделайте обоснованный выбор решения.

Решение должно соответствовать следующим требованиям:
- Поддержка кластеризации для обеспечения надежности
- Хранение сообщений на диске в процессе доставки
- Высокая скорость работы
- Поддержка различных форматов сообщений
- Разделение прав доступа к различным потокам сообщений
- Простота эксплуатации

Обоснуйте свой выбор.

__Ответ:__

Чтобы обеспечить асинхронную связь между микросервисами, нужен брокер сообщений. Брокер обеспечивает надежную и стабильную передачу данных, управление и мониторинг, а также предотвращает потерю сообщений. Список реализаций Message Broker также можно посмотреть  фонде [Cloud Native Computing Foundation](https://landscape.cncf.io/card-mode?category=streaming-messaging&grouping=category&sort=stars), возьмем несколько самых популярных и составим сравнительную таблицу.

| Продукт | Кластеризация | Хранение сообщений на диске | Скорость работы [1] | Форматы сообщений | Разделение прав доступа на потоки | Простота эксплуатации [2] |
|---|---|---|---|---|---|---|
| Apache Kafka | Да | Да | ~605 MB/s | Binary через TCP Socket | Да | Сложно |
| NATS | Да | Да | ? | NATS Streaming Protocol | Да | Просто |
| Apache PULSAR | Да | Да | ~305 MB/s | Binary через TCP Socket | Да | Сложно |
| RabbitMQ | Да | Да | ~40 MB/s | AMQP, MQTT, STOMP | Да | Просто |

[1]: https://www.confluent.io/blog/kafka-fastest-messaging-system/
[2]: https://www.confluent.io/kafka-vs-pulsar/

Для Enterprise решения лучше использовать решения Apache, т.к. они позволяют реализовать распределенную очередь с высокой пропускной способностью и длительного хранения больших объемов данных, идеально подходят в тех случаях, где требуется персистентность. Если брокер нужен только для связи между микросервисами, тогда лучший выбор NATS - он написан специально для этого. Как универсальное решение можно использовать RabbitMQ - давно известный, популярный брокер со множеством функций и возможностей, поддерживающих сложную маршрутизацию при незначительном трафике, очень распространён, прост в настройке, большое комьюнити.

## Задача 3: API Gateway * (необязательная)

<details><summary>Детали</summary>

### Есть три сервиса:

**minio**
- Хранит загруженные файлы в бакете images
- S3 протокол

**uploader**
- Принимает файл, если он картинка сжимает и загружает его в minio
- POST /v1/upload

**security**
- Регистрация пользователя POST /v1/user
- Получение информации о пользователе GET /v1/user
- Логин пользователя POST /v1/token
- Проверка токена GET /v1/token/validation

### Необходимо воспользоваться любым балансировщиком и сделать API Gateway:

**POST /v1/register**
- Анонимный доступ.
- Запрос направляется в сервис security POST /v1/user

**POST /v1/token**
- Анонимный доступ.
- Запрос направляется в сервис security POST /v1/token

**GET /v1/user**
- Проверка токена. Токен ожидается в заголовке Authorization. Токен проверяется через вызов сервиса security GET /v1/token/validation/
- Запрос направляется в сервис security GET /v1/user

**POST /v1/upload**
- Проверка токена. Токен ожидается в заголовке Authorization. Токен проверяется через вызов сервиса security GET /v1/token/validation/
- Запрос направляется в сервис uploader POST /v1/upload

**GET /v1/user/{image}**
- Проверка токена. Токен ожидается в заголовке Authorization. Токен проверяется через вызов сервиса security GET /v1/token/validation/
- Запрос направляется в сервис minio  GET /images/{image}

### Ожидаемый результат

Результатом выполнения задачи должен быть docker compose файл запустив который можно локально выполнить следующие команды с успешным результатом.
Предполагается что для реализации API Gateway будет написан конфиг для NGinx или другого балансировщика нагрузки который будет запущен как сервис через docker-compose и будет обеспечивать балансировку и проверку аутентификации входящих запросов.

**Авторизация**
curl -X POST -H 'Content-Type: application/json' -d '{"login":"bob", "password":"qwe123"}' http://localhost/token

**Загрузка файла**

curl -X POST -H 'Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJib2IifQ.hiMVLmssoTsy1MqbmIoviDeFPvo-nCd92d4UFiN2O2I' -H 'Content-Type: octet/stream' --data-binary @yourfilename.jpg http://localhost/upload

**Получение файла**
curl -X GET http://localhost/images/4e6df220-295e-4231-82bc-45e4b1484430.jpg

</details>

__Ответ:__

- [Конфиг для NGinx](./src/gateway/nginx.conf), дополнительно добавлена функция `register()` в сервис [security](./src/security/src/server.py) и [недостающие библиотеки](./src/security/requirements.txt).

- Авторизация

```BASH
$ curl -X POST -H 'Content-Type: application/json' -d '{"login":"test", "password":"secret"}' http://localhost/register
{"success":"New user is created: test"}

$ curl -X POST -H 'Content-Type: application/json' -d '{"login":"test", "password":"secret"}' http://localhost/token
eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ0ZXN0In0.NOl4y0jo0PyN-k2PpIVkb-X7ESDSpgolPDUpEGC1dxk
```

- Загрузка файла

```BASH
$ curl -X POST -H 'Content-Type: octet/stream' --data-binary @devops.png http://localhost/upload
<html>
<head><title>401 Authorization Required</title></head>
<body>
<center><h1>401 Authorization Required</h1></center>
<hr><center>nginx/1.23.1</center>
</body>
</html>

$ curl -X POST -H 'Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ0ZXN0In0.NOl4y0jo0PyN-k2PpIVkb-X7ESDSpgolPDUpEGC1dxk' -H 'Content-Type: octet/stream' --data-binary @devops.png http://localhost/upload
{"filename":"87a42feb-fc28-4fd6-aec8-e854417d1719.png"}
```

- Получение файла

```BASH
$ curl -X GET http://localhost/images/87a42feb-fc28-4fd6-aec8-e854417d1719.png > test.png
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 16062  100 16062    0     0  1206k      0 --:--:-- --:--:-- --:--:-- 1206k

$ ll *.png
-rw-rw-r-- 1 rpot rpot 16062 Aug  3 18:19 devops.png
-rw-rw-r-- 1 rpot rpot 16062 Aug  3 20:14 test.png
```
