#!/usr/bin/env python3
import os
import sys
import subprocess
#Проверка входых аргумантов
if not(len(sys.argv) == 2 and os.path.isdir(sys.argv[1])):
    print("Input data error.")
    exit(1)
#Запуск команды с обработкой ошибок
cmd = f"cd {sys.argv[1]} && git status -s"
results = subprocess.run(cmd, shell=True, stdout=subprocess.PIPE, \
    stderr=subprocess.PIPE, encoding='utf-8')
if results.returncode != 0:
    print(f"Git data error: {results.stderr}")
    exit(1)
#Обработка вывода
for result in results.stdout.split('\n'):
    if result and result[0] == 'A':
        print(result[3:])
