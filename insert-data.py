from time import time
import psycopg2
import psycopg2.pool
import random
import string
import time

pool = None

def get_pool():
    global pool
    if pool is None:
        pool = psycopg2.pool.SimpleConnectionPool(
            1, 4, host="postgresql-b", database="mydb", user="mydb_user", password="mydb_pwd", port=5432,
        )
    return pool


# static seed to generate the same data all the time
rng = random.Random(0)

max_n = 1_000_000


def insert_book(value):
    conn = get_pool().getconn()

    cursor = conn.cursor()
    cursor.execute("INSERT INTO books (id, category_id, author, title, year) VALUES (%s, %s, %s, %s, %s);", value)

    conn.commit()

    cursor.close()
    get_pool().putconn(conn)


def insert_book_without_sharding(value):
    conn = get_pool().getconn()

    cursor = conn.cursor()
    cursor.execute("INSERT INTO books_without_sharding (id, category_id, author, title, year) VALUES (%s, %s, %s, %s, %s);", value)

    conn.commit()

    cursor.close()
    get_pool().putconn(conn)

def generate_books(count):
    books = []
    for i in range(count):
        category_id = rng.randint(1, 2)
        short_random_string = "".join(rng.choice(string.ascii_letters) for _ in range(20))
        year = rng.randint(1900, 2020)

        books.append((i, category_id, short_random_string, short_random_string, year))

    return books


def insert_books(books):
    for book in books:
        insert_book(book)

def insert_books_without_sharding(books):
    for book in books:
        insert_book_without_sharding(book)

if __name__ == '__main__':
    print("Start generating books...")
    books = generate_books(max_n)
    print("Finished generating books")

    print("Start inserting books...")
    start_time = time.time()
    insert_books(books)
    end_time = time.time()
    print("Inserted %s books in %s seconds" % (max_n, end_time - start_time))

    print("Start inserting books without sharding...")
    start_time = time.time()
    insert_books_without_sharding(books)
    end_time = time.time()
    print("Inserted %s books in %s seconds" % (max_n, end_time - start_time))