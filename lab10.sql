-- Task 3.1 Setup: Create Test Database

CREATE TABLE accounts (
 id SERIAL PRIMARY KEY,
 name VARCHAR(100) NOT NULL,
 balance DECIMAL(10, 2) DEFAULT 0.00
);

CREATE TABLE products (
 id SERIAL PRIMARY KEY,
 shop VARCHAR(100) NOT NULL,
 product VARCHAR(100) NOT NULL,
 price DECIMAL(10, 2) NOT NULL
);

-- Insert test data
INSERT INTO accounts (name, balance) VALUES
 ('Alice', 1000.00),
 ('Bob', 500.00),
 ('Wally', 750.00);

INSERT INTO products (shop, product, price) VALUES
 ('Joe''s Shop', 'Coke', 2.50),
 ('Joe''s Shop', 'Pepsi', 3.00);


-- Task 3.2: Basic Transaction with COMMIT
BEGIN;
UPDATE accounts
SET balance = balance - 100.00
WHERE name = 'Alice';
UPDATE accounts
SET balance = balance + 100.00
WHERE name = 'Bob';
COMMIT;
-- a) Alice = $900.00; Bob = $600.00
-- b) Grouping ensures atomicity
-- c) Alice could be debited while Bob is not credited


-- Task 3.3: Using ROLLBACK
BEGIN;
UPDATE accounts SET balance = balance - 500.00
 WHERE name = 'Alice';
SELECT * FROM accounts WHERE name = 'Alice';
-- Oops! Wrong amount, let's undo
ROLLBACK;
SELECT * FROM accounts WHERE name = 'Alice';
-- a) After the UPDATE but before ROLLBACK Alice = $500.00
-- b) After ROLLBACK Alice = $1000.00
-- c) Use ROLLBACK when an error is detected, validation fails, an application exception occurs,
-- or you want to abort a multi-step operation to keep data consistent


-- Task 3.4: Working with SAVEPOINTs
BEGIN;
UPDATE accounts SET balance = balance - 100.00
WHERE name = 'Alice';
SAVEPOINT my_savepoint;
UPDATE accounts SET balance = balance + 100.00
WHERE name = 'Bob';
-- Oops, should transfer to Wally instead
ROLLBACK TO my_savepoint;
UPDATE accounts SET balance = balance + 100.00
WHERE name = 'Wally';
COMMIT;
-- a) Alice = $900.00, Bob = $500.00, Wally = $850.00
-- b) Bob was temporarily credited during the transaction but that change was undone by ROLLBACK TO my_savepoint
-- c) SAVEPOINT lets you undo part of a transaction without aborting the whole transaction


-- Task 3.5: Isolation Level Demonstration
-- Scenario A: READ COMMITTED
-- Terminal 1:
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT * FROM products WHERE shop = 'Joe''s Shop';
-- Wait for Terminal 2 to make changes and COMMIT
-- Then re-run:
SELECT * FROM products WHERE shop = 'Joe''s Shop';
COMMIT;
-- Terminal 2 (while Terminal 1 is still running):
BEGIN;
DELETE FROM products WHERE shop = 'Joe''s Shop';
INSERT INTO products (shop, product, price)
 VALUES ('Joe''s Shop', 'Fanta', 3.50);
COMMIT;

-- Scenario B: SERIALIZABLE
-- Terminal 1:
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
SELECT * FROM products WHERE shop = 'Joe''s Shop';
-- Wait for Terminal 2 to make changes and COMMIT
-- Then re-run:
SELECT * FROM products WHERE shop = 'Joe''s Shop';
COMMIT;
-- Terminal 2 (while Terminal 1 is still running):
BEGIN;
DELETE FROM products WHERE shop = 'Joe''s Shop';
INSERT INTO products (shop, product, price)
 VALUES ('Joe''s Shop', 'Fanta', 3.50);
COMMIT;
-- a) READ COMMITTED: Terminal 1 sees Coke, Pepsi on the first read; after Terminal 2 commits it sees Fanta on the second read
-- b) SERIALIZABLE: Terminal 1 sees Coke, Pepsi on both reads; it does not observe Terminal 2’s committed changes during its transaction
-- c) Difference: READ COMMITTED shows the latest committed data at each statement


-- Task 3.6: Phantom Read Demonstration
-- Terminal 1:
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT MAX(price), MIN(price) FROM products
 WHERE shop = 'Joe''s Shop';
-- Wait for Terminal 2
SELECT MAX(price), MIN(price) FROM products
 WHERE shop = 'Joe''s Shop';
COMMIT;
-- Terminal 2:
BEGIN;
INSERT INTO products (shop, product, price)
 VALUES ('Joe''s Shop', 'Sprite', 4.00);
COMMIT;
-- a) Terminal 1 can see the newly inserted row on the second read
-- b) A phantom read is when a transaction re-executes a range query and finds rows that were not visible before
-- c) SERIALIZABLE prevents phantom reads


-- Task 3.7: Dirty Read Demonstration
-- Terminal 1:
BEGIN TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SELECT * FROM products WHERE shop = 'Joe''s Shop';
-- Wait for Terminal 2 to UPDATE but NOT commit
SELECT * FROM products WHERE shop = 'Joe''s Shop';
-- Wait for Terminal 2 to ROLLBACK
SELECT * FROM products WHERE shop = 'Joe''s Shop';
COMMIT;
-- Terminal 2:
BEGIN;
UPDATE products SET price = 99.99
 WHERE product = 'Fanta';
-- Wait here (don't commit yet)
-- Then:
ROLLBACK;
-- a) Yes, Terminal 1 may see the price 99.99 before Terminal 2 commits
-- This is problematic because the value was never committed and later rolled back, so Terminal 1 observed transient, incorrect data
-- b) A dirty read is reading data written by another transaction that has not yet committed
-- c) READ UNCOMMITTED should be avoided because it allows inconsistent, uncommitted data to be observed


-- Exercise 1
BEGIN;
UPDATE accounts
SET balance = balance - 200.00
WHERE name = 'Bob' AND balance >= 200.00;
WITH debit AS (
  UPDATE accounts
  SET balance = balance - 200.00
  WHERE name = 'Bob' AND balance >= 200.00
  RETURNING id
)
INSERT INTO accounts (name, balance)
SELECT 'WALLY_TEMP', 0
WHERE FALSE;

ROLLBACK;

-- Exercise 2
BEGIN;
INSERT INTO products (shop, product, price)
VALUES ('Joe''s Shop', 'LimitedEdition', 10.00);

SAVEPOINT sp_a;
UPDATE products
SET price = 12.50
WHERE shop = 'Joe''s Shop' AND product = 'LimitedEdition';

SAVEPOINT sp_b;
DELETE FROM products
WHERE shop = 'Joe''s Shop' AND product = 'LimitedEdition';

ROLLBACK TO SAVEPOINT sp_a;
COMMIT;
SELECT * FROM products WHERE product = 'LimitedEdition';

-- Exercise 3
-- Terminal 1:
BEGIN;
SELECT id, name, balance FROM accounts
WHERE name = 'SharedAccount' FOR UPDATE;
UPDATE accounts
SET balance = balance - 100.00
WHERE name = 'SharedAccount' AND balance >= 100.00;
COMMIT;
-- Terminal 2:
BEGIN;
SELECT id, name, balance FROM accounts
WHERE name = 'SharedAccount' FOR UPDATE;
UPDATE accounts
SET balance = balance - 100.00
WHERE name = 'SharedAccount' AND balance >= 100.00;
COMMIT;

-- Exercise 4
BEGIN;
UPDATE products SET price = 10 WHERE shop = 'S' AND product = 'p1';
UPDATE products SET price = 20 WHERE shop = 'S' AND product = 'p2';
COMMIT;
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT MAX(price) AS max_price, MIN(price) AS min_price FROM products WHERE shop = 'S';
COMMIT;


-- Questions for Self-Assessment
-- 1. ACID properties
-- Atomicity: All-or-nothing, e.g., transferring money between accounts either debits and credits both or none
-- Consistency: Constraints preserved, e.g., foreign keys prevent inserting an order for a non-existent customer
-- Isolation: Concurrent transactions don’t interfere, e.g., two users booking tickets don’t see each other’s partial updates
-- Durability: Committed changes survive crashes, e.g., once an order is confirmed it remains after restart
--
-- 2. COMMIT vs ROLLBACK
-- COMMIT: Makes all changes permanent
-- ROLLBACK: Undoes all changes since the transaction began
--
-- 3. SAVEPOINT vs full ROLLBACK
-- Use SAVEPOINT when you want to undo part of a transaction but keep earlier successful steps intact
--
-- 4. Isolation levels
-- READ UNCOMMITTED: Allows dirty reads
-- READ COMMITTED: Prevents dirty reads but allows non-repeatable reads and phantoms
-- REPEATABLE READ: Prevents dirty and non-repeatable reads but allows phantoms
-- SERIALIZABLE: Prevents all anomalies, strongest isolation, lowest concurrency
--
-- 5. Dirty read
-- Reading uncommitted changes from another transaction
-- Allowed in READ UNCOMMITTED
--
-- 6. Non-repeatable read
-- Same query returns different results within one transaction because another transaction updated data
-- Example: Transaction A reads Alice’s balance = 1000; Transaction B updates it to 900; Transaction A re-reads and sees 900
--
-- 7. Phantom read
-- New rows appear in a repeated query due to another transaction’s insert/delete
-- Prevented only by SERIALIZABLE
--
-- 8. READ COMMITTED vs SERIALIZABLE
-- READ COMMITTED offers better performance and concurrency in high-traffic systems, while SERIALIZABLE can cause blocking or serialization failures
--
-- 9. Transactions and consistency
-- Transactions ensure operations are atomic and isolated, so concurrent access doesn’t corrupt data or violate constraints
--
-- 10. Uncommitted changes on crash
-- They are lost; only committed changes are durable and survive system crashes