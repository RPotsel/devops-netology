#!/usr/bin/env python3

import time as t
import datetime as dt
import json 

def get_cpu_data():
    '''
    return CPU information
    '''
    
    cpu_data = {
        "running_processes": 0,
        "total_processes": 0
    }

    with open('/proc/loadavg', 'r') as f:
        for string in f:
            la_1m, la_5m, la_15m, proc_info, newest_pid = string.split(' ')
            running_processes, total_processes = proc_info.split('/')

    cpu_data['running_processes'] = int(running_processes)
    cpu_data['total_processes'] = int(total_processes)
 
    return cpu_data


def get_mem_data():
    '''
    return memory information
    '''

    mem_data = {
        "mem_available": 0,
        "mem_active": 0,
        "swap_free": 0
    }

    with open('/proc/meminfo', 'r') as f:
        for string in f:
            if string.startswith("MemAvailable:"):
                mem_data['mem_available'] = string.split(':')[1].lstrip().split(' ')[0]
            elif string.startswith("Active:"):
                mem_data['mem_active'] = string.split(':')[1].lstrip().split(' ')[0]
            elif string.startswith("SwapFree:"):
                mem_data['swap_free'] = string.split(':')[1].lstrip().split(' ')[0]
    return mem_data


def get_uptime_data():
    '''
    return uptime hms format
    '''

    with open('/proc/uptime', 'r') as f:
        uptime_seconds = int(float(f.read().split(' ')[0].strip()))
    return str(uptime_seconds // 3600) + "h" \
        + str((uptime_seconds % 3600) // 60) + "m" \
        + str(uptime_seconds % 3600 % 60) + "s" 


def main():

    # Init log file location sting
    logs = f"/var/log/{dt.datetime.now().strftime('%Y-%m-%d')}-awesome-monitoring.log"

    # Gather data
    data_slice = {
        "timestamp": t.time_ns(),
        **get_cpu_data(),
        **get_mem_data(),
        "uptime": get_uptime_data()
    }

    # White log
    with open(logs, 'a') as f:
        f.write(json.dumps(data_slice) + '\n')

    #print(json.dumps(data_slice) + '\n')

# Call a function from the main thread
if __name__ == "__main__":
    main()
