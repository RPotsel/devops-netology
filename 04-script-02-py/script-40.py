#!/usr/bin/env python3
import socket as s
import time as t
import datetime as dt
#Объявление словаря
hosts = {'drive.google.com':'', 'mail.google.com':'', 'google.com':''}
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
  t.sleep(3)