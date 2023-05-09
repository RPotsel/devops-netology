# 4.3. Языки разметки JSON и YAML

## Обязательные задания

1. Мы выгрузили JSON, который получили через API запрос к нашему сервису:
 ```json
    { "info" : "Sample JSON output from our service\t",
        "elements" :[
            { "name" : "first",
            "type" : "server",
            "ip" : 7175 
            },
            { "name" : "second",
            "type" : "proxy",
            "ip : 71.78.22.43
            }
        ]
    }
 ```

  Нужно найти и исправить все ошибки, которые допускает наш сервис

[__Ответ__](./script-10.json)

```json
{ "info" : "Sample JSON output from our service\\t",
    "elements" :[
        { "name" : "first",
        "type" : "server",
        "ip" : 7175 
        },
        { "name" : "second",
        "type" : "proxy",
        "ip" : "71.78.22.43"
        }
    ]
}
```

2. В прошлый рабочий день мы создавали скрипт, позволяющий опрашивать веб-сервисы и получать их IP. К уже реализованному функционалу нам нужно добавить возможность записи JSON и YAML файлов, описывающих наши сервисы. Формат записи JSON по одному сервису: { "имя сервиса" : "его IP"}. Формат записи YAML по одному сервису: - имя сервиса: его IP. Если в момент исполнения скрипта меняется IP у сервиса - он должен так же поменяться в yml и json файле.

__Ответ__

```python
#!/usr/bin/env python3
import os
import socket as s
import time
import datetime as dt
import sys
import json
import yaml

#Чтение словаря из файла в формате JSON с обработкой ошибок
def readJSON(file):
    try:
        with open(file, 'r', encoding='utf-8') as f:
            text = json.load(f)
    except ValueError as e:
        print(f"JSON file format error: {e}")
        exit(1)
    except Exception as e:
        print(f"Something gone wrong: {e}")
        exit(1)
    return text

#Чтение словаря из файла в формате YAML с обработкой ошибок
def readYAML(file):
    try:
        with open(file, 'r', encoding='utf-8') as f:
            text = yaml.safe_load(f)
    except ValueError as e:
        print(f"YAML file format error: {e}")
        exit(1)
    except Exception as e:
        print(f"Something gone wrong: {e}")
        exit(1)
    return text

#Запись словаря в файл в формате JSON
def writeJSON(file, data):
    try:
        with open(file, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=4)
    except Exception as e:
        print(f"Something gone wrong: {e}")
        return False
    return True

#Запись словаря в файл в формате YAML
def writeYAML(file, data):
    try:
        with open(file, 'w', encoding='utf-8') as f:
            yaml.dump(data, f, indent=4)
    except Exception as e:
        print(f"Something gone wrong: {e}")
        return False
    return True

def readParams(file):
    file_ext = os.path.splitext(file)[1]
    if file_ext[1:].lower() == "json":
        return readJSON(file)
    elif file_ext[1:].lower() == "yaml":
        return readYAML(file)

def writeParams(file, data):
    file_ext = os.path.splitext(file)[1]
    if file_ext[1:] == "json":
        return writeJSON(file, data)
    elif file_ext[1:] == "yaml":
        return writeYAML(file, data)

#Проверка входящих аргументов и объявление словаря из файла
if not(len(sys.argv) == 2 and os.path.isdir(sys.argv[1])):
    hosts = {'drive.google.com':'', 'mail.google.com':'', 'google.com':''}
    file = 'script-20.json'
elif os.path.isfile(sys.argv[1]):
    hosts = readParams(sys.argv[1])
    file = sys.argv[1]

#Заполнение словаря
for host in hosts:
    hosts[host] = s.gethostbyname(host)

#Проверка текущих значений IP со знечениями в словаре 
while 1==1: 
  for host, ip in hosts.items():
    cur_ip = s.gethostbyname(host)
    if cur_ip != ip:
        print(dt.datetime.now().strftime("%m/%d/%y %H:%M:%S") + \
            f" [ERROR] {host} IP mismatch: {ip} -> {cur_ip}")
        hosts[host]=cur_ip
        writeParams(file, hosts)
  time.sleep(3)
```

## Дополнительное задание (со звездочкой*) - необязательно к выполнению

Так как команды в нашей компании никак не могут прийти к единому мнению о том, какой формат разметки данных использовать: JSON или YAML, нам нужно реализовать парсер из одного формата в другой. Он должен уметь:

* Принимать на вход имя файла
* Проверять формат исходного файла. Если файл не json или yml - скрипт должен остановить свою работу
* Распознавать какой формат данных в файле. Считается, что файлы *.json и*.yml могут быть перепутаны
* Перекодировать данные из исходного формата во второй доступный (из JSON в YAML, из YAML в JSON)
* При обнаружении ошибки в исходном файле - указать в стандартном выводе строку с ошибкой синтаксиса и её номер
* Полученный файл должен иметь имя исходного файла, разница в наименовании обеспечивается разницей расширения файлов

__Ответ__

Результат работы скрипта представлен в файлах [script-10.json](./script-10.json), [script-30.yaml](./script-30.yaml), [script-30.json](./script-30.json)

```python
#!/usr/bin/env python3
import os
import json
import yaml

#Чтение словаря из файла в формате JSON с обработкой ошибок
def readJSON(file):
    try:
        with open(file, 'r', encoding='utf-8') as f:
            text = json.load(f)
    except ValueError as e:
        print(f"JSON file format error: {e}")
        exit(1)
    except Exception as e:
        print(f"Something gone wrong: {e}")
        exit(1)
    return text

#Чтение словаря из файла в формате YAML с обработкой ошибок
def readYAML(file):
    try:
        with open(file, 'r', encoding='utf-8') as f:
            text = yaml.safe_load(f)
    except ValueError as e:
        print(f"YAML file format error: {e}")
        exit(1)
    except Exception as e:
        print(f"Something gone wrong: {e}")
        exit(1)
    return text

#Запись словаря в файл в формате JSON
def writeJSON(file, data):
    try:
        with open(file, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=4)
    except Exception as e:
        print(f"Something gone wrong: {e}")
        return False
    return True

#Запись словаря в файл в формате YAML
def writeYAML(file, data):
    try:
        with open(file, 'w', encoding='utf-8') as f:
            yaml.dump(data, f, indent=4)
    except Exception as e:
        print(f"Something gone wrong: {e}")
        return False
    return True

def readParams(file):
    file_ext = os.path.splitext(file)[1]
    if file_ext[1:].lower() == "json":
        return readJSON(file)
    elif file_ext[1:].lower() == "yaml":
        return readYAML(file)

def writeParams(file, data):
    file_ext = os.path.splitext(file)[1]
    if file_ext[1:] == "json":
        return writeJSON(file, data)
    elif file_ext[1:] == "yaml":
        return writeYAML(file, data)

params = readParams('script-10.json')
writeParams('script-30.yaml', params)
params = readParams('script-30.yaml')
writeParams('script-30.json', params)
```