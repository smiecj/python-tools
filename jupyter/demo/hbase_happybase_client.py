# -*- coding: UTF-8 -*-
## happybase refer: https://happybase.readthedocs.io/en/latest/api.html
import happybase

# conn = happybase.Connection(host="172.17.0.1", port=38609, protocol='compact', transport='framed')
# conn = happybase.Connection(host="172.17.0.1", port=38609, autoconnect=False)
conn = happybase.Connection(host="172.17.0.1", port=38609)
print(conn.tables())

# table = conn.table('TEST:SCHOOL')
# print(table.families())