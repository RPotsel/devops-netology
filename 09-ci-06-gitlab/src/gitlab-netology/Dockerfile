FROM centos:7

RUN yum install python3 python3-pip -y
RUN pip3 install flask flask-restful flask-jsonpify
WORKDIR /python_api
COPY python-api.py python-api.py
CMD ["python3", "python-api.py"]
