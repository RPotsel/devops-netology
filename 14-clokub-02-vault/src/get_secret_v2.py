import hvac
import sys

client = hvac.Client(
    url='http://vault:8200',
    token=sys.argv[1]
)

client.is_authenticated()

# Читаем секрет
secret = client.adapter.request("GET", "v1/secret/test/hello")

print(secret['data'])