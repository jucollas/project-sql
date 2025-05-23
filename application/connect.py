import oracledb
from dotenv import load_dotenv
import os

load_dotenv()

USER = os.getenv('USER_SQL')
PASSWORD = os.getenv('PASSWORD_SQL')
DSN = os.getenv('DSN')
def connect():
    try:
        connection = oracledb.connect(user=USER, password=PASSWORD, dsn=DSN)
        print("✅ Successfully connected to Oracle.")
        return connection
    except Exception as e:
        print("❌ Error connecting to Oracle:", e)
        return None