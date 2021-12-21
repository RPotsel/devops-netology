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