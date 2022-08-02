CREATE EXTENSION postgres_fdw;

CREATE SERVER shard_1
FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (host 'postgresql-b1', dbname 'mydb');

CREATE USER MAPPING FOR "mydb_user"
SERVER shard_1
OPTIONS (user 'mydb_shard_1_user', password 'mydb_shard_1_pwd');

CREATE FOREIGN TABLE books_1 (
id bigint not null,
category_id int not null,
author character varying not null,
title character varying not null, year int not null )
SERVER shard_1
OPTIONS (schema_name 'public', table_name 'books');

CREATE SERVER shard_2
FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (host 'postgresql-b2', dbname 'mydb');

CREATE USER MAPPING FOR "mydb_user"
SERVER shard_2
OPTIONS (user 'mydb_shard_2_user', password 'mydb_shard_2_pwd');

CREATE FOREIGN TABLE books_2 (
id bigint not null,
category_id int not null,
author character varying not null,
title character varying not null, year int not null )
SERVER shard_2
OPTIONS (schema_name 'public', table_name 'books');

CREATE VIEW books AS
SELECT * FROM books_1
UNION ALL
SELECT * FROM books_2;

CREATE RULE books_insert AS ON INSERT TO books DO INSTEAD NOTHING;
CREATE RULE books_update AS ON UPDATE TO books DO INSTEAD NOTHING;
CREATE RULE books_delete AS ON DELETE TO books DO INSTEAD NOTHING;

CREATE RULE books_insert_to_1 AS ON INSERT TO books WHERE ( category_id = 1 )
DO INSTEAD INSERT INTO books_1 VALUES (NEW.*);

CREATE RULE books_insert_to_2 AS ON INSERT TO books WHERE ( category_id = 2 )
DO INSTEAD INSERT INTO books_2 VALUES (NEW.*);


CREATE TABLE books_without_sharding (
id bigint not null,
category_id int not null,
author character varying not null,
title character varying not null, year int not null );

CREATE INDEX books_category_id_idx ON books_without_sharding USING btree(category_id);