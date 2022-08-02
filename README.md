# Horizontal Sharding

* Create 3 docker containers: postgresql-b, postgresql-b1, postgresql-b2
* Setup horizontal sharding as it’s described in this lesson
* Insert 1 000 000 rows into books
* Measure performance
* Do the same without sharding
* Compare performance

### Insert data into master instance
```
docker exec -it postgresql-b psql -U mydb_user -d mydb -c "INSERT INTO books (id, category_id, author, title, year) VALUES (1,1,'Lina Kostenko','Marusya Churay',1979);"
docker exec -it postgresql-b psql -U mydb_user -d mydb -c "INSERT INTO books (id, category_id, author, title, year) VALUES (2,1,'Vasyl Stus','Zimovi Dereva',1970);"
docker exec -it postgresql-b psql -U mydb_user -d mydb -c "INSERT INTO books (id, category_id, author, title, year) VALUES (3,2,'Lina Kostenko','Vitryla',1958);"
docker exec -it postgresql-b psql -U mydb_user -d mydb -c "INSERT INTO books (id, category_id, author, title, year) VALUES (4,3,'Lina Kostenko','Nepovtornist',1980);"
```

### Read changes from master instance

```
docker exec -it postgresql-b psql -U mydb_user -d mydb -c "select * from books"
```

### Result

```
 id | category_id |    author     |     title      | year 
----+-------------+---------------+----------------+------
  1 |           1 | Lina Kostenko | Marusya Churay | 1979
  2 |           1 | Vasyl Stus    | Zimovi Dereva  | 1970
  3 |           2 | Lina Kostenko | Vitryla        | 1958
(3 rows)
```

### Read changes from shard 1 to ensure the data is replicated

```
docker exec -it postgresql-b1 psql -U mydb_shard_1_user -d mydb -c "select * from books"
```

### Result

```
 id | category_id |    author     |     title      | year 
----+-------------+---------------+----------------+------
  1 |           1 | Lina Kostenko | Marusya Churay | 1979
  2 |           1 | Vasyl Stus    | Zimovi Dereva  | 1970
(2 rows)
```


### Read changes from slave 2 to ensure the data is replicated

```
docker exec -it postgresql-b2 psql -U mydb_shard_2_user -d mydb -c "select * from books"
```

### Result

```
 id | category_id |    author     |  title  | year 
----+-------------+---------------+---------+------
  3 |           2 | Lina Kostenko | Vitryla | 1958
(1 row)
```

## Compare performance

### Run
```
python3 insert-data.py
```
### Result

```
insert-script_1  | Start generating books...
insert-script_1  | Finished generating books
insert-script_1  | Start inserting books...
insert-script_1  | Inserted 1000000 books in 2308.8755207061768 seconds
insert-script_1  | Start inserting books without sharding...
insert-script_1  | Inserted 1000000 books in 909.308357000351 seconds
```