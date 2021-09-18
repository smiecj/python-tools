# -*- coding: UTF-8 -*-
## need install thrift-hbase first, refer: https://gitee.com/atamagaii/thrift-hbase

from thrift import Thrift
from thrift.transport import TSocket
from thrift.transport import TTransport
from thrift.transport.TTransport import TFramedTransport
from thrift.protocol import TCompactProtocol

from hbase import Hbase
from hbase.ttypes import *

# transport = TSocket.TSocket('172.17.0.1', 38609)
# protocol = TCompactProtocol.TCompactProtocol(transport)

socket = TSocket.TSocket('172.17.0.1', 38609)
socket.setTimeout(5000)
 
transport = TFramedTransport(socket)
protocol = TCompactProtocol.TCompactProtocol(transport)

client = Hbase.Client(protocol)
transport.open()
a = client.getTableNames()
print(a)