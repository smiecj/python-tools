from sqlalchemy import select, func, create_engine, Column, MetaData, Integer, String
from clickhouse_sqlalchemy import make_session, get_declarative_base, types, engines

uri = 'clickhouse://default:clickhouse_pwd@clickhouse_address/default'

engine = create_engine(uri, connect_args={'http_session': Session()})
session = make_session(engine)
metadata = MetaData(bind=engine)

print("success")

Base = get_declarative_base(metadata=metadata)

class Order(Base):
    __tablename__ = "test_order"
    date = Column(types.Date, primary_key=True)
    name = Column(types.String)

    __table_args__ = (
        engines.Memory(),
    )

session.query(func.count(Order.date)) \
    .scalar()