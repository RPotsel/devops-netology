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