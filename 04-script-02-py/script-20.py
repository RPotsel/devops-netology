#!/usr/bin/env python3
import os

bash_command = ["cd ~/Projects/tst-prj/", "git status -s"]
result_os = os.popen(' && '.join(bash_command)).read()

for result in result_os.split('\n'):
    if result and result[0] == 'A':
        print(result[3:])