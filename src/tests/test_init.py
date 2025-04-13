from unittest import TestCase
from main import create_connection, execute_query, create_mongo_connection, create_redis_connection
from settings import settings

class TestBooksAPI(TestCase):

    def test_assert_true(self):
        self.assertTrue(True)

    def test_posgresql_connection(self):
        connection = create_connection(settings.POSTGRESQL_URL)
        if connection:
            execute_query(connection, "SELECT version();")
            connection.dispose()

    def test_equal_strings(self):
        self.assertEqual("Hello", "Hello")
    
    def test_mongodb_connection(self):
        connection = create_mongo_connection(settings.MONGO_URL)
        if connection:
            connection.close()

    def test_redis_connection(self):
        connection = create_redis_connection(settings.REDIS_URL)
        if connection:
            connection.close()
