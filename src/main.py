from sqlalchemy import create_engine, text
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.engine import Engine
from pymongo import MongoClient
from settings import settings
from redis import Redis

def create_connection(connection_url: str) -> Engine | None:
    """
    Establece conexión a PostgreSQL usando SQLAlchemy con una URL de conexión
    
    Formato URL: postgresql://usuario:contraseña@host:puerto/nombre_base_datos
    """
    try:
        engine = create_engine(connection_url)
        print("Conexión a PostgreSQL exitosa usando SQLAlchemy")
        return engine
    except SQLAlchemyError as e:
        print(f"Error al conectar a PostgreSQL: {e}")
        return None

def execute_query(engine: Engine, query: str) -> None:
    try:
        with engine.connect() as connection:
            result = connection.execute(text(query))
            if query.lower().strip().startswith("select"):
                for row in result:
                    print(row)
            connection.commit()
        print("Consulta ejecutada con éxito")
    except SQLAlchemyError as e:
        print(f"Error al ejecutar la consulta: {e}")

def create_mongo_connection(connection_url: str) -> MongoClient | None:
    try:
        client = MongoClient(connection_url)
        print("Conexión a MongoDB exitosa")
        return client
    except Exception as e:
        print(f"Error al conectar a MongoDB: {e}")
        return None

def create_redis_connection(connection_url: str) -> Redis | None:
    try:
        redis = Redis(connection_url)
        print("Conexión a Redis exitosa")
        return redis
    except Exception as e:
        print(f"Error al conectar a Redis: {e}")
        return None
    
if __name__ == "__main__":
    connection_url = settings.POSTGRESQL_URL
    engine = create_connection(connection_url)
    if engine:
        execute_query(engine, "SELECT version();")
        engine.dispose()

    connection_url = settings.MONGO_URL
    client = create_mongo_connection(connection_url)
    if client:
        print("Conexión a MongoDB exitosa")
        client.close()

    connection_url = settings.REDIS_URL
    redis = create_redis_connection(connection_url)
    if redis:
        print("Conexión a Redis exitosa")
        redis.close()
