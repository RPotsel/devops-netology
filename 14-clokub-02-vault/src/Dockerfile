FROM fedora
WORKDIR /app

RUN dnf install -y pip \
    && pip install hvac \
    && dnf clean all \
    && rm -rf /var/cache/yum

COPY get_secret_v2.py ./

ENTRYPOINT ["tail", "-f", "/dev/null"]
