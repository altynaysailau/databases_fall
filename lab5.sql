CREATE DATABASE LAB5;

--PART 1

--TASK 1.1
CREATE TABLE employees(
    employee_id integer,
    first_name text,
    last_name text,
    age integer CHECK ( age between 18 and 65),
    salary numeric CHECK ( salary > 0 )
);

--TASK 1.2
CREATE TABLE products_catalog(
    product_id integer,
    product_name text,
    regular_price numeric,
    discount_price numeric,
    CONSTRAINT valid_discount CHECK (  regular_price > 0 and discount_price > 0 and discount_price < regular_price)
);

--TASK 1.3
CREATE TABLE bookings(
    booking_id integer,
    check_in_date date,
    check_out_date date CHECK (check_out_date > check_in_date),
    num_guests integer CHECK (num_guests between 1 and  10)
);

--TASK 1.4

--table employees
INSERT INTO employees VALUES (1,'Meir', 'Saken', 19,1000000.0);
INSERT INTO employees VALUES (2,'Abl', 'Edil',18,1200000.2);

--[ERROR] salary is > 0 but age must be between 18 and 65
INSERT INTO employees VALUES (3,'Someone','Someoneovich',15,10000);

--[ERROR] age is between 19 and 65 but salary is not > 0
INSERT INTO employees VALUES (4,'WHOKNOWS','WHONOWSOVA',34,0);


--table products_catalogue
INSERT INTO products_catalog VALUES (1,'Melon',1000,500);
INSERT INTO products_catalog VALUES (2,'Tomato',700,370);

--[ERROR] regular_price is > 0 and discount_price is less than regular_price but discount_price not  > 0
INSERT INTO products_catalog VALUES (3,'Potato',350,0);

--[ERROR] regular_price is > 0 and discount_price is greater than 0 but discount_price is not less than regular_price
INSERT INTO products_catalog VALUES (4,'Apple',400,500);

--table bookings
INSERT INTO bookings VALUES (1,'2010-01-01','2011-01-01',9);
INSERT INTO bookings VALUES (2,'2024-01-01','2024-01-06',4);

--[ERROR] check_out_date is after check_in_date but num_guests is not between 1 and 10
INSERT INTO bookings VALUES (3,'2025-01-01','2025-01-06',11);

--[ERROR] num_guests is between 1 and 10 but check_out_date is not after check_in_date
INSERT INTO bookings VALUES(4,'2018-05-05','2018-05-03',3);

--PART 2

--TASK 2.1
CREATE TABLE customers (
    customer_id INTEGER NOT NULL ,
    email text NOT NULL,
    phone text NULL ,
    registration_date date NOT NULL
);

--TASK 2.2
CREATE TABLE inventory (
    item_id integer NOT NULL ,
    item_name text NOT NULL ,
    quantity INTEGER NOT NULL CHECK ( quantity >= 0 ),
    unit_price numeric NOT NULL CHECK ( unit_price > 0 ),
    last_updated timestamp NOT NULL
);

--TASK 2.3
--TABLE customers

--Successfully insert complete records
INSERT INTO customers VALUES (1,'sfsdf.@gmail.com',NULL, '2025-10-13');

--Attempt to insert records with NULL values in NOT NULL columns
INSERT INTO customers VALUES (2,'teriue.@kbtu.kz',NULL,NULL);
--ОШИБКА: значение NULL в столбце "registration_date" отношения "customers" нарушает ограничение NOT NULL

--TABLE inventory

--Successfully insert complete records
INSERT INTO inventory VALUES (1,'Something',22,5000,'2023-01-01 00:00:00');

--Attempt to insert records with NULL values in NOT NULL columns
INSERT INTO inventory VALUES(2,'ball',NULL,555,'2023-01-01 00:00:00');
-- ОШИБКА: значение NULL в столбце "quantity" отношения "inventory" нарушает ограничение NOT NUL

--Insert records with NULL values in nullable columns
INSERT INTO customers VALUES (2,'reytry@gmail.com',NULL,current_date);


--PART 3

--TASK 3.1
CREATE TABLE users(
    user_id integer,
    username text UNIQUE ,
    email text UNIQUE,
    created_at timestamp
);

--TASK 3.2
CREATE TABLE course_enrollments(
    enrollment_id integer,
    student_id integer,
    course_code text,
    semester text,
    UNIQUE (student_id,course_code,semester)
);

--TASK 3.3
ALTER TABLE users ADD CONSTRAINT unique_username UNIQUE (username);
ALTER TABLE users ADD CONSTRAINT unique_email UNIQUE (email);

INSERT INTO users VALUES (1,'ADSASD','ASDASD',current_date);
--DUPLICATE username
INSERT INTO users VALUES (1,'ADSASD','llggg',current_date);
--output: ОШИБКА: повторяющееся значение ключа нарушает ограничение уникальности "users_username_key"
--DUPLICATE email
INSERT INTO users VALUES (1,'Dano','ASDASD',current_date);
--output: ОШИБКА: повторяющееся значение ключа нарушает ограничение уникальности "users_email_key"
select * from users;


--PART 4

--TASK 4.1
CREATE TABLE departments(
    dept_id INTEGER PRIMARY KEY ,
    dept_name TEXT NOT NULL ,
    location TEXT
);

INSERT INTO departments VALUES (1,'IT','Almaty'),
                               (2,'Sales','Astana');

--DUPLICATE
INSERT INTO departments VALUES (1,'Management','Almaty');
--output: ОШИБКА: повторяющееся значение ключа нарушает ограничение уникальности "departments_pkey"


--TASK 4.2
CREATE TABLE student_courses(
    student_id INTEGER,
    course_id INTEGER,
    enrollment_date DATE,
    grade TEXT,
    PRIMARY KEY (student_id,course_id)
);

--TASK 4.3

--The difference between UNIQUE and PRIMARY KEY

--PRIMARY KEY:Cannot contain NULL value, Only one primary key per table,Used for uniquely identifying a row (record ID)
--UNIQUE Can contain one or more NULL values, You can have multiple unique constraints per table, Used for ensuring uniqueness of a column (like email, phone number, etc.)


--When to use a single-column vs. composite PRIMARY KEY
--Single-column PRIMARY KEY: Entities with a natural unique ID users, products, invoices,When simplicity and performance are key
--Composite PRIMARY KEY: Junction or association tables,When the data’s natural uniqueness spans multiple columns


--Why a table can have only one PRIMARY KEY but multiple UNIQUE constraints
--A PRIMARY KEY uniquely identifies each record in the table. It’s the main key used to define relationships — other tables often reference it through FOREIGN KEYs. A table represents a collection of unique rows, and each row needs one main identifier.
--A UNIQUE constraint ensures that values in one or more columns are distinct across all rows. ou can have multiple UNIQUE constraints in one table for different columns or column combinations.


--PART 5

--TASK 5.1
CREATE TABLE employees_dept(
    emp_id INTEGER PRIMARY KEY ,
    emp_name TEXT NOT NULL ,
    dept_id INTEGER REFERENCES departments,
    hire_date DATE
);
--Inserting employees with valid dept_id
INSERT INTO departments VALUES (1,'IT','ALMATY'),
                               (2,'HR','Astana'),
                               (3,'Management', 'Aktau');

INSERT INTO employees_dept VALUES (101,'Altyn',1,'2025-09-09'),
                                  (102,'Damir',2,'2023-01-01'),
                                  (103,'Baha',3,'2024-01-01');

--Attempting to insert an employee with a non-existent dept_id
INSERT INTO employees_dept VALUES(104,'Someone',99,current_date);
INSERT INTO employees_dept VALUES(105,'Someone',101,current_date);
--[ERROR]  INSERT или UPDATE в таблице "employees_dept" нарушает ограничение внешнего ключа "employees_dept_dept_id_fkey"

--TASK 5.2
CREATE TABLE authors(
    author_id INTEGER PRIMARY KEY ,
    author_name TEXT NOT NULL ,
    country TEXT
);

CREATE TABLE publishers(
    publisher_id INTEGER PRIMARY KEY ,
    publisher_name TEXT NOT NULL ,
    city TEXT
);

CREATE TABLE books(
    book_id INTEGER PRIMARY KEY ,
    title TEXT NOT NULL ,
    author_id INTEGER REFERENCES authors,
    publisher_id INTEGER REFERENCES publishers,
    publication_year INTEGER,
    isbn TEXT UNIQUE
);

INSERT INTO authors VALUES (1,'George Orwell','UK'),
                           (2,'Agatha Christie','UK'),
                           (3,'Adolf Hitler','Austria');

INSERT INTO publishers VALUES (101,'Secker & Warburg','London'),
                              (102,'Century Carroggio','London'),
                              (103,'Austrian Artist','Berlin');

INSERT INTO books VALUES (1001,'1984',1,101, 1949,'978-5-389-19109-9.'),
                         (1002,'10 negritos',2,102,1939,'978-852504529'),
                         (1003,'Mein Khampf',3,103,1924,'9780977476077');

--TASK 5.3

CREATE TABLE categories(
    category_id INTEGER PRIMARY KEY ,
    category_name TEXT NOT NULL
);

CREATE TABLE products_fk(
    product_id INTEGER PRIMARY KEY ,
    product_name TEXT NOT NULL ,
    category_id INTEGER REFERENCES categories ON DELETE RESTRICT
);

CREATE TABLE orders(
    order_id INTEGER PRIMARY KEY ,
    order_date DATE NOT NULL
);

CREATE TABLE order_items(
    item_id INTEGER PRIMARY KEY ,
    order_id INTEGER REFERENCES orders ON DELETE CASCADE ,
    product_id INTEGER REFERENCES products_fk,
    quantity INTEGER CHECK ( quantity > 0 )
);

INSERT INTO categories VALUES (1,'vegetables'),
                              (2,'fruit');

INSERT INTO products_fk VALUES (101,'Tomato',1),
                               (102,'Apple',2);

INSERT INTO orders VALUES (1001,CURRENT_DATE),
                          (1002,CURRENT_DATE);

INSERT INTO order_items VALUES (10001,1001,101,500),
                               (10002,1002,102,500);

DELETE FROM products_fk WHERE category_id = 1;
--[ERROR]  UPDATE или DELETE в таблице "products_fk" нарушает ограничение внешнего ключа "order_items_product_id_fkey" таблицы "order_items"

DELETE FROM order_items WHERE item_id = 10002;
--When we delete an order, all products associated with it are automatically deleted from the order_items table.
select * from order_items;

--PART 6
CREATE DATABASE lab5_task6;
--TASK 6.1

CREATE TABLE customers2(
    customer_id INTEGER PRIMARY KEY ,
    name TEXT NOT NULL ,
    email TEXT UNIQUE NOT NULL ,
    phone TEXT ,
    registration_date DATE
);

CREATE TABLE products2(
    product_id INTEGER PRIMARY KEY ,
    name TEXT NOT NULL ,
    description TEXT,
    price INTEGER CHECK ( price > 0 ) ,
    stock_quantity INTEGER CHECK ( stock_quantity > 0 )
);

CREATE TABLE orders2(
    order_id INTEGER PRIMARY KEY ,
    customer_id INTEGER REFERENCES customers2 ON DELETE RESTRICT ,
    order_date DATE NOT NULL ,
    total_amount INTEGER ,
    status TEXT CHECK ( status IN ('pending','processing','shipped', 'delivered','cancelled')) NOT NULL
);

CREATE TABLE order_details2(
    order_detail_id INTEGER PRIMARY KEY ,
    order_id INTEGER REFERENCES orders2 ON DELETE CASCADE ,
    product_id INTEGER REFERENCES products2 ON DELETE RESTRICT ,
    quantity INTEGER CHECK ( quantity > 0 ) NOT NULL ,
    unit_price INTEGER
);

--At least 5 sample records per table
INSERT INTO customers2 VALUES (1,'altyn','altyn@kbtu.kz','87777777149','2024-09-01'),
                             (2,'ABL','abl@alt.kz','8777777777','2024-09-01'),
                             (3,'Damo', 'damir@gmail.com','87777772006','2025-09-01'),
                             (4,'Daulet','fouken@gmail.com','87778882005','2021-09-01'),
                             (5,'Mali', 'mali@gmail.com','8777200831','2025-09-01');

INSERT INTO products2 VALUES (1,'Laptop','bIG ONE',120000,10),
                             (2,'Apple', '17th version',1000000,100),
                             (3,'Car','faster one',100000000,3),
                             (4,'Ps','With spiderman',350000,100),
                             (5,'Education','the best one',50000,100);

INSERT INTO orders2 VALUES (1,1,CURRENT_DATE,1200000,'pending'),
                           (2,2,CURRENT_DATE,1000000000,'cancelled'),
                           (3,3,CURRENT_DATE,300000000,'shipped'),
                           (4,4,CURRENT_DATE,35000000,'processing'),
                           (5,5,CURRENT_DATE,5000000,'delivered');

INSERT INTO order_details2 VALUES (1,1,1,10,120000),
                                  (2,2,2,100,1000000),
                                  (3,3,3,3,100000000),
                                  (4,4,4,100,350000),
                                  (5,5,5,100,50000);

--TESTING
INSERT INTO customers2 VALUES (6,'Someone','meir@kbtu.kz','9999999',current_date);


INSERT INTO products2 VALUES (6,'DFGDFG','FDS',0,0);


INSERT INTO orders2 (order_id,customer_id,order_date, status) VALUES (6,6,CURRENT_DATE, 'unknown');


INSERT INTO order_details2 VALUES (6,6,6,0,0);


DELETE FROM customers2 WHERE customer_id = 5;



DELETE FROM orders2 WHERE order_id=5;
SELECT * FROM orders2;