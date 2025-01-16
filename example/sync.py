import mysql.connector
from sqlalchemy import create_engine
import pandas as pd

from io import StringIO  # python3; python2: BytesIO
import boto3
import datetime
import time


# Read DB 연결 정보
def read_connection():
    return mysql.connector.connect(
        host='host',
        user='vircle',
        password='password',
        database='valu_db',
        port=3306)

# dw DB 연결 정보
def dw_connection():
    return mysql.connector.connect(
        host='host',
        user='root',
        password='password',
        database='dw')

def dw_engine():
    # SQLAlchemy 엔진 생성
    host = 'host'
    user = 'root'
    password = 'password'
    return create_engine(f'mysql+pymysql://{user}:{password}@{host}:3306/dw?charset=utf8')

# DB -> Jupyter notebook
def get_table_data(connect, query):
    # 쿼리 실행 및 데이터 가져오기
    conn = read_connection() if connect =="read" else dw_connection()
    cursor = conn.cursor()
    cursor.execute(query)

    # pandas DataFrame으로 변환
    columns = [col[0] for col in cursor.description]
    rows = cursor.fetchall()
    data = pd.DataFrame(rows, columns=columns)

    # 커서와 연결 종료
    cursor.close()
    conn.close()
    return data

def put_s3(message_type, database, subject, dataFrame):
    bucket = 'vircle-data-snowflake'  # already created on S3

    prefix = f"{message_type}/{database}/{subject}"

    csv_buffer = StringIO()
    dataFrame.to_csv(csv_buffer, header=True, columns=dataFrame.columns)
    s3_resource = boto3.resource('s3', aws_access_key_id="aws_access_key_id",
                                 aws_secret_access_key="aws_secret_access_key")

    # backup
    s3_resource.Object(bucket,
        f'{prefix}/backup/{subject}_{datetime.datetime.now().year}y{datetime.datetime.now().month}m{datetime.datetime.now().day}d.csv'
    ).put(Body=csv_buffer.getvalue())

    # snowflake와 sync
    s3_resource.Object(bucket, f'{prefix}/{subject}.csv').put(Body=csv_buffer.getvalue())


if __name__ == '__main__':
    # 시작 시간 기록
    start_time = time.time()

    print('start sync product')
    df = get_table_data('read', 'SELECT * FROM TB_PRODUCT LIMIT 1000')
    put_s3('sync', 'mysql', 'product', df)
    del df
    print('start sync customer')
    data = get_table_data('read', 'SELECT * FROM TB_CUSTOMER LIMIT 1000')
    put_s3('sync', 'mysql', 'customer', data)
    del data
    # 종료 시간 기록
    end_time = time.time()
    execution_time = end_time - start_time
    print(f"실행 시간: {execution_time:.6f}초")


