# 6.5. Elasticsearch

## Задача 1

В этом задании вы потренируетесь в:
- установке elasticsearch
- первоначальном конфигурировании elastcisearch
- запуске elasticsearch в docker

Используя докер образ [centos:7](https://hub.docker.com/_/centos) как базовый и 
[документацию по установке и запуску Elastcisearch](https://www.elastic.co/guide/en/elasticsearch/reference/current/targz.html):

- составьте Dockerfile-манифест для elasticsearch
- соберите docker-образ и сделайте `push` в ваш docker.io репозиторий
- запустите контейнер из получившегося образа и выполните запрос пути `/` c хост-машины

Требования к `elasticsearch.yml`:
- данные `path` должны сохраняться в `/var/lib`
- имя ноды должно быть `netology_test`

В ответе приведите:
- текст Dockerfile манифеста
- ссылку на образ в репозитории dockerhub
- ответ `elasticsearch` на запрос пути `/` в json виде

Подсказки:
- возможно вам понадобится установка пакета perl-Digest-SHA для корректной работы пакета shasum
- при сетевых проблемах внимательно изучите кластерные и сетевые настройки в elasticsearch.yml
- при некоторых проблемах вам поможет docker директива ulimit
- elasticsearch в логах обычно описывает проблему и пути ее решения

Далее мы будем работать с данным экземпляром elasticsearch.

__Ответ:__

Текст Dockerfile манифеста:

```BASH
FROM centos:7

EXPOSE 9200 9300

USER 0

RUN export ES_HOME="/var/lib/elasticsearch" && \
    yum -y install wget && \
    wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.16.0-linux-x86_64.tar.gz && \
    wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.16.0-linux-x86_64.tar.gz.sha512 && \
    sha512sum -c elasticsearch-7.16.0-linux-x86_64.tar.gz.sha512 && \
    tar -xzf elasticsearch-7.16.0-linux-x86_64.tar.gz && \
    rm -f elasticsearch-7.16.0-linux-x86_64.tar.gz* && \
    mv elasticsearch-7.16.0 ${ES_HOME} && \
    useradd -m -u 1000 elasticsearch && \
    chown elasticsearch:elasticsearch -R ${ES_HOME} && \
    yum -y remove wget && \
    yum clean all
COPY --chown=elasticsearch:elasticsearch config/* /var/lib/elasticsearch/config/

USER 1000

ENV ES_HOME="/var/lib/elasticsearch" \
    ES_PATH_CONF="/var/lib/elasticsearch/config"
WORKDIR ${ES_HOME}

CMD ["sh", "-c", "${ES_HOME}/bin/elasticsearch"]
```

Вывод команд:

```BASH
$ docker build -t rpot/my-elasticsearch:0.2 .
...

$ sysctl -w vm.max_map_count=262144
vm.max_map_count = 262144
$ docker run --rm -d --name elastic -p 9200:9200 -p 9300:9300 rpot/my-elasticsearch:0.2
489008205c2af8874f1ab76835e6f96e7f0da72ae5670532a967d2374b0e7a32
$ curl localhost:9200
{
  "name" : "netology_test",
  "cluster_name" : "elasticsearch",
  "cluster_uuid" : "yHvNurZ3SWyTyKugT5t1Kg",
  "version" : {
    "number" : "7.16.0",
    "build_flavor" : "default",
    "build_type" : "tar",
    "build_hash" : "6fc81662312141fe7691d7c1c91b8658ac17aa0d",
    "build_date" : "2021-12-02T15:46:35.697268109Z",
    "build_snapshot" : false,
    "lucene_version" : "8.10.1",
    "minimum_wire_compatibility_version" : "6.8.0",
    "minimum_index_compatibility_version" : "6.0.0-beta1"
  },
  "tagline" : "You Know, for Search"
}

$ docker push rpot/my-elasticsearch:0.2
The push refers to repository [docker.io/rpot/my-elasticsearch]
a8b12f34bdd3: Pushed 
539b51e62851: Pushed 
174f56854903: Mounted from library/centos 
0.2: digest: sha256:85e5e79e5e6acf0d437472355e48728ec3f46e6c419ed0d5298e3554b38a1988 size: 950
```

Ссылки:

- Файл конфигурации [elasticsearch.yml](./src/config/elasticsearch.yml);
- [docker-образ](https://hub.docker.com/r/rpot/my-elasticsearch).

## Задача 2

В этом задании вы научитесь:
- создавать и удалять индексы
- изучать состояние кластера
- обосновывать причину деградации доступности данных

Ознакомьтесь с [документацией](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-create-index.html) 
и добавьте в `elasticsearch` 3 индекса, в соответствии со таблицей:

| Имя | Количество реплик | Количество шард |
|-----|-------------------|-----------------|
| ind-1| 0 | 1 |
| ind-2 | 1 | 2 |
| ind-3 | 2 | 4 |

Получите список индексов и их статусов, используя API и **приведите в ответе** на задание.

Получите состояние кластера `elasticsearch`, используя API.

Как вы думаете, почему часть индексов и кластер находится в состоянии yellow?

Удалите все индексы.

__Ответ:__

Создание индексов:

```BASH
$ curl -X PUT localhost:9200/ind-1 -H 'Content-Type: application/json' -d'{ "settings": { "number_of_shards": 1,  "number_of_replicas": 0 }}'
{"acknowledged":true,"shards_acknowledged":true,"index":"ind-1"}
$ curl -X PUT localhost:9200/ind-2 -H 'Content-Type: application/json' -d'{ "settings": { "number_of_shards": 2,  "number_of_replicas": 1 }}'
{"acknowledged":true,"shards_acknowledged":true,"index":"ind-2"}
$ curl -X PUT localhost:9200/ind-3 -H 'Content-Type: application/json' -d'{ "settings": { "number_of_shards": 4,  "number_of_replicas": 2 }}'
{"acknowledged":true,"shards_acknowledged":true,"index":"ind-3"}
```

Список индексов:

```BASH
$ curl localhost:9200/_cat/indices?v=true
health status index            uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   .geoip_databases 5G-2nBIQQb2HlElRzf4I6w   1   0         45            0     42.5mb         42.5mb
green  open   ind-1            N7CRbaZnT5CB1fBfYwmBkQ   1   0          0            0       226b           226b
yellow open   ind-3            gBDC36ELS7GirH81elHI-Q   4   2          0            0       904b           904b
yellow open   ind-2            s6GmLr9uTECpVHF8uNBfrg   2   1          0            0       452b           452b
```

Статус индексов:

```BASH
$ curl -X GET 'localhost:9200/_cluster/health/ind-1?pretty'
{
  "cluster_name" : "elasticsearch",
  "status" : "green",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 1,
  "active_shards" : 1,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 0,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 100.0
}
$ curl -X GET 'localhost:9200/_cluster/health/ind-2?pretty'
{
  "cluster_name" : "elasticsearch",
  "status" : "yellow",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 2,
  "active_shards" : 2,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 2,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 50.0
}
```

Состояние кластера:

```BASH
$ curl localhost:9200/_cluster/health?pretty
{
  "cluster_name" : "elasticsearch",
  "status" : "yellow",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 10,
  "active_shards" : 10,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 10,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 50.0
}
```

У кластера и некоторых индексов статус желтый, т.к. в кластере один узел и некуда размещать реплики.

Удаление индексов:

```BASH
$ curl -X DELETE localhost:9200/ind-1?pretty
{
  "acknowledged" : true
}
$ curl -X DELETE localhost:9200/ind-2?pretty
{
  "acknowledged" : true
}
$ curl -X DELETE localhost:9200/ind-3?pretty
{
  "acknowledged" : true
}
```

**Важно**

При проектировании кластера elasticsearch нужно корректно рассчитывать количество реплик и шард,
иначе возможна потеря данных индексов, вплоть до полной, при деградации системы.

## Задача 3

В данном задании вы научитесь:
- создавать бэкапы данных
- восстанавливать индексы из бэкапов

Создайте директорию `{путь до корневой директории с elasticsearch в образе}/snapshots`.

Используя API [зарегистрируйте](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-register-repository.html#snapshots-register-repository)
данную директорию как `snapshot repository` c именем `netology_backup`.

**Приведите в ответе** запрос API и результат вызова API для создания репозитория.

Создайте индекс `test` с 0 реплик и 1 шардом и **приведите в ответе** список индексов.

[Создайте `snapshot`](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-take-snapshot.html) 
состояния кластера `elasticsearch`.

**Приведите в ответе** список файлов в директории со `snapshot`ами.

Удалите индекс `test` и создайте индекс `test-2`. **Приведите в ответе** список индексов.

[Восстановите](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-restore-snapshot.html) состояние
кластера `elasticsearch` из `snapshot`, созданного ранее. 

**Приведите в ответе** запрос к API восстановления и итоговый список индексов.

Подсказки:
- возможно вам понадобится доработать `elasticsearch.yml` в части директивы `path.repo` и перезапустить `elasticsearch`

__Ответ:__

Создание репозитория `netology_backup`:

```BASH
$ curl -X PUT "localhost:9200/_snapshot/netology_backup?pretty" -H 'Content-Type: application/json' -d '{"type": "fs","settings": {"location": "/var/lib/elasticsearch/snapshots","compress": true}}'
{
  "acknowledged" : true
}
$ curl localhost:9200/_snapshot/netology_backup?pretty
{
  "netology_backup" : {
    "type" : "fs",
    "settings" : {
      "compress" : "true",
      "location" : "/var/lib/elasticsearch/snapshots"
    }
  }
}
```

Создание индекса `test`:

```BASH
$ curl localhost:9200/_snapshot/netology_backup?pretty
{
  "netology_backup" : {
    "type" : "fs",
    "settings" : {
      "compress" : "true",
      "location" : "/var/lib/elasticsearch/snapshots"
    }
  }
}
$ curl -X PUT localhost:9200/test -H 'Content-Type: application/json' -d '{"settings": {"number_of_shards": 1, "number_of_replicas": 0}}'
{"acknowledged":true,"shards_acknowledged":true,"index":"test"}

$ curl localhost:9200/_cat/indices?v=true
health status index            uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   .geoip_databases 5G-2nBIQQb2HlElRzf4I6w   1   0         45            0     42.5mb         42.5mb
green  open   test             GCs8B70WQFKL0dNcPYY0fw   1   0          0
```

Создание снимка:

```BASH
$ curl -X PUT localhost:9200/_snapshot/netology_backup/elasticsearch?wait_for_completion=true
{"snapshot":{"snapshot":"elasticsearch","uuid":"40lDN6kBR0m2Kqv7VpLa-Q","repository":"netology_backup","version_id":7160099,"version":"7.16.0","indices":[".geoip_databases","test",".ds-ilm-history-5-2022.03.09-000001",".ds-.logs-deprecation.elasticsearch-default-2022.03.09-000001"],"data_streams":["ilm-history-5",".logs-deprecation.elasticsearch-default"],"include_global_state":true,"state":"SUCCESS","start_time":"2022-03-09T18:12:24.815Z","start_time_in_millis":1646849544815,"end_time":"2022-03-09T18:12:26.618Z","end_time_in_millis":1646849546618,"duration_in_millis":1803,"failures":[],"shards":{"total":4,"failed":0,"successful":4},"feature_states":[{"feature_name":"geoip","indices":[".geoip_databases"]}]}}

$ docker exec elastic ls -l /var/lib/elasticsearch/snapshots/
total 28
-rw-r--r-- 1 elasticsearch elasticsearch 1425 Mar  9 18:12 index-0
-rw-r--r-- 1 elasticsearch elasticsearch    8 Mar  9 18:12 index.latest
drwxr-xr-x 6 elasticsearch elasticsearch 4096 Mar  9 18:12 indices
-rw-r--r-- 1 elasticsearch elasticsearch 9777 Mar  9 18:12 meta-40lDN6kBR0m2Kqv7VpLa-Q.dat
-rw-r--r-- 1 elasticsearch elasticsearch  457 Mar  9 18:12 snap-40lDN6kBR0m2Kqv7VpLa-Q.dat
```

Удаление индекса `test` и создание `test-2`:

```BASH
$ curl -X DELETE localhost:9200/test?pretty
{
  "acknowledged" : true
}
$ curl -X PUT localhost:9200/test-2?pretty -H 'Content-Type: application/json' -d'{ "settings": { "number_of_shards": 1,  "number_of_replicas": 0 }}'
{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "test-2"
}
$ curl localhost:9200/_cat/indices?v=true
health status index            uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   .geoip_databases 5G-2nBIQQb2HlElRzf4I6w   1   0         45            0     42.5mb         42.5mb
green  open   test-2           HvBORXBjRSiEvYMc1KoGWw   1   0          0 
```

Восстановление из снимка:

```BASH
$ curl -X POST localhost:9200/_snapshot/netology_backup/elasticsearch/_restore?pretty -H 'Content-Type: application/json' -d'{"indices": "test", "include_global_state":true}'
{
  "accepted" : true
}
$ curl localhost:9200/_cat/indices?v=true
health status index            uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   .geoip_databases 5_H-sd3pTRqTQqcbs7ejsA   1   0         45            0     42.5mb         42.5mb
green  open   test-2           HvBORXBjRSiEvYMc1KoGWw   1   0          0            0       226b           226b
green  open   test             C99WfEpGRQWI8d05octH8g   1   0          0
```