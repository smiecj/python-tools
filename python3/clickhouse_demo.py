# -*- coding: UTF-8 -*-

# refer: https://clickhouse-driver.readthedocs.io/en/latest/quickstart.html 
# pip install clickhouse-driver

## search
from clickhouse_driver import Client

client = Client(host='clickhouse_host', port='clickhouse_port', user='clickhouse_user', password='clickhouse_password', database='clickhouse_password')

client.execute('SHOW DATABASES')

client.execute('SELECT * FROM system.query_log LIMIT 5')

## DDL
client.execute('DROP TABLE IF EXISTS test')

client.execute('CREATE TABLE test (x Int32) ENGINE = Memory')

## insert
client.execute(
    'INSERT INTO test (x) VALUES',
    [{'x': 1}, {'x': 2}, {'x': 3}, {'x': 100}]
)

client.execute(
    'INSERT INTO test (x) VALUES',
    [[200]]
)

client.execute(
    'INSERT INTO test (x) VALUES',
    ((x, ) for x in range(5))
)

client.execute('SELECT * FROM test LIMIT 100')