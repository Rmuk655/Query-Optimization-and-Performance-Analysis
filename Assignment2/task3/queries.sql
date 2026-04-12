-- ==========================================
-- QUERY 1 EXECUTIONS
-- ==========================================

LOAD 'pg_hint_plan';

-- Switch 1: 1992-01-07 and 1992-01-08

EXPLAIN ANALYZE SELECT SUM(l_quantity), SUM(l_extendedprice), SUM(l_extendedprice * (1 - l_discount)), SUM(l_extendedprice * (1 - l_discount) * (1 + l_tax)), AVG(l_quantity), AVG(l_extendedprice), AVG(l_discount), COUNT(*) FROM lineitem WHERE l_shipdate <= DATE '1992-01-07';
;


EXPLAIN ANALYZE SELECT SUM(l_quantity), SUM(l_extendedprice), SUM(l_extendedprice * (1 - l_discount)), SUM(l_extendedprice * (1 - l_discount) * (1 + l_tax)), AVG(l_quantity), AVG(l_extendedprice), AVG(l_discount), COUNT(*) FROM lineitem WHERE l_shipdate <= DATE '1992-01-08';
;

/*+
  BitmapScan(lineitem)
*/
EXPLAIN ANALYZE SELECT SUM(l_quantity), SUM(l_extendedprice), SUM(l_extendedprice * (1 - l_discount)), SUM(l_extendedprice * (1 - l_discount) * (1 + l_tax)), AVG(l_quantity), AVG(l_extendedprice), AVG(l_discount), COUNT(*) FROM lineitem WHERE l_shipdate <= DATE '1992-01-08';
;

/*+
  IndexScan(lineitem idx_lineitem_shipdate)
*/
EXPLAIN ANALYZE SELECT SUM(l_quantity), SUM(l_extendedprice), SUM(l_extendedprice * (1 - l_discount)), SUM(l_extendedprice * (1 - l_discount) * (1 + l_tax)), AVG(l_quantity), AVG(l_extendedprice), AVG(l_discount), COUNT(*) FROM lineitem WHERE l_shipdate <= DATE '1992-01-07';
;

-- Switch 2: 1992-01-27 and 1992-01-28

EXPLAIN ANALYZE SELECT SUM(l_quantity), SUM(l_extendedprice), SUM(l_extendedprice * (1 - l_discount)), SUM(l_extendedprice * (1 - l_discount) * (1 + l_tax)), AVG(l_quantity), AVG(l_extendedprice), AVG(l_discount), COUNT(*) FROM lineitem WHERE l_shipdate <= DATE '1992-01-27';
;


EXPLAIN ANALYZE SELECT SUM(l_quantity), SUM(l_extendedprice), SUM(l_extendedprice * (1 - l_discount)), SUM(l_extendedprice * (1 - l_discount) * (1 + l_tax)), AVG(l_quantity), AVG(l_extendedprice), AVG(l_discount), COUNT(*) FROM lineitem WHERE l_shipdate <= DATE '1992-01-28';
;

/*+
  IndexScan(lineitem idx_lineitem_shipdate)
*/
EXPLAIN ANALYZE SELECT SUM(l_quantity), SUM(l_extendedprice), SUM(l_extendedprice * (1 - l_discount)), SUM(l_extendedprice * (1 - l_discount) * (1 + l_tax)), AVG(l_quantity), AVG(l_extendedprice), AVG(l_discount), COUNT(*) FROM lineitem WHERE l_shipdate <= DATE '1992-01-28';
;

/*+
  BitmapScan(lineitem)
  Parallel(lineitem 4)
*/
EXPLAIN ANALYZE SELECT SUM(l_quantity), SUM(l_extendedprice), SUM(l_extendedprice * (1 - l_discount)), SUM(l_extendedprice * (1 - l_discount) * (1 + l_tax)), AVG(l_quantity), AVG(l_extendedprice), AVG(l_discount), COUNT(*) FROM lineitem WHERE l_shipdate <= DATE '1992-01-27';
;

-- Switch 3: 1992-03-29 and 1992-03-30

EXPLAIN ANALYZE SELECT SUM(l_quantity), SUM(l_extendedprice), SUM(l_extendedprice * (1 - l_discount)), SUM(l_extendedprice * (1 - l_discount) * (1 + l_tax)), AVG(l_quantity), AVG(l_extendedprice), AVG(l_discount), COUNT(*) FROM lineitem WHERE l_shipdate <= DATE '1992-03-29';
;


EXPLAIN ANALYZE SELECT SUM(l_quantity), SUM(l_extendedprice), SUM(l_extendedprice * (1 - l_discount)), SUM(l_extendedprice * (1 - l_discount) * (1 + l_tax)), AVG(l_quantity), AVG(l_extendedprice), AVG(l_discount), COUNT(*) FROM lineitem WHERE l_shipdate <= DATE '1992-03-30';
;

/*+
  BitmapScan(lineitem)
  Parallel(lineitem 4)
*/
EXPLAIN ANALYZE SELECT SUM(l_quantity), SUM(l_extendedprice), SUM(l_extendedprice * (1 - l_discount)), SUM(l_extendedprice * (1 - l_discount) * (1 + l_tax)), AVG(l_quantity), AVG(l_extendedprice), AVG(l_discount), COUNT(*) FROM lineitem WHERE l_shipdate <= DATE '1992-03-30';
;

/*+
  SeqScan(lineitem)
  Parallel(lineitem 4)
*/
EXPLAIN ANALYZE SELECT SUM(l_quantity), SUM(l_extendedprice), SUM(l_extendedprice * (1 - l_discount)), SUM(l_extendedprice * (1 - l_discount) * (1 + l_tax)), AVG(l_quantity), AVG(l_extendedprice), AVG(l_discount), COUNT(*) FROM lineitem WHERE l_shipdate <= DATE '1992-03-29';
;

-- ==========================================
-- QUERY 2 EXECUTIONS
-- ==========================================

LOAD 'pg_hint_plan';

-- Switch 1: 1992-01-01 and 1992-01-02

EXPLAIN ANALYZE SELECT o_orderpriority, count(*) AS order_count FROM orders WHERE o_orderdate >= DATE '1992-01-01' AND o_orderdate < DATE '1992-01-01' AND EXISTS (SELECT 1 FROM lineitem WHERE l_orderkey = o_orderkey AND l_commitdate < l_receiptdate) GROUP BY o_orderpriority;
;


EXPLAIN ANALYZE SELECT o_orderpriority, count(*) AS order_count FROM orders WHERE o_orderdate >= DATE '1992-01-01' AND o_orderdate < DATE '1992-01-02' AND EXISTS (SELECT 1 FROM lineitem WHERE l_orderkey = o_orderkey AND l_commitdate < l_receiptdate) GROUP BY o_orderpriority;
;

/*+
  NestLoop(orders lineitem)
  IndexScan(orders idx_orders_orderdate)
  IndexScan(lineitem lineitem_pkey)
*/
EXPLAIN ANALYZE SELECT o_orderpriority, count(*) AS order_count FROM orders WHERE o_orderdate >= DATE '1992-01-01' AND o_orderdate < DATE '1992-01-02' AND EXISTS (SELECT 1 FROM lineitem WHERE l_orderkey = o_orderkey AND l_commitdate < l_receiptdate) GROUP BY o_orderpriority;
;

/*+
  NestLoop(orders lineitem)
  BitmapScan(orders)
  Parallel(orders 4)
  IndexScan(lineitem lineitem_pkey)
*/
EXPLAIN ANALYZE SELECT o_orderpriority, count(*) AS order_count FROM orders WHERE o_orderdate >= DATE '1992-01-01' AND o_orderdate < DATE '1992-01-01' AND EXISTS (SELECT 1 FROM lineitem WHERE l_orderkey = o_orderkey AND l_commitdate < l_receiptdate) GROUP BY o_orderpriority;
;

-- Switch 2: 1992-02-18 and 1992-02-19

EXPLAIN ANALYZE SELECT o_orderpriority, count(*) AS order_count FROM orders WHERE o_orderdate >= DATE '1992-01-01' AND o_orderdate < DATE '1992-02-18' AND EXISTS (SELECT 1 FROM lineitem WHERE l_orderkey = o_orderkey AND l_commitdate < l_receiptdate) GROUP BY o_orderpriority;
;


EXPLAIN ANALYZE SELECT o_orderpriority, count(*) AS order_count FROM orders WHERE o_orderdate >= DATE '1992-01-01' AND o_orderdate < DATE '1992-02-19' AND EXISTS (SELECT 1 FROM lineitem WHERE l_orderkey = o_orderkey AND l_commitdate < l_receiptdate) GROUP BY o_orderpriority;
;

/*+
  NestLoop(orders lineitem)
  BitmapScan(orders)
  Parallel(orders 4)
  IndexScan(lineitem lineitem_pkey)
*/
EXPLAIN ANALYZE SELECT o_orderpriority, count(*) AS order_count FROM orders WHERE o_orderdate >= DATE '1992-01-01' AND o_orderdate < DATE '1992-02-19' AND EXISTS (SELECT 1 FROM lineitem WHERE l_orderkey = o_orderkey AND l_commitdate < l_receiptdate) GROUP BY o_orderpriority;
;

/*+
  NestLoop(orders lineitem)
  SeqScan(orders)
  Parallel(orders 4)
  IndexScan(lineitem lineitem_pkey)
*/
EXPLAIN ANALYZE SELECT o_orderpriority, count(*) AS order_count FROM orders WHERE o_orderdate >= DATE '1992-01-01' AND o_orderdate < DATE '1992-02-18' AND EXISTS (SELECT 1 FROM lineitem WHERE l_orderkey = o_orderkey AND l_commitdate < l_receiptdate) GROUP BY o_orderpriority;
;

-- Switch 3: 1992-03-17 and 1992-03-18

EXPLAIN ANALYZE SELECT o_orderpriority, count(*) AS order_count FROM orders WHERE o_orderdate >= DATE '1992-01-01' AND o_orderdate < DATE '1992-03-17' AND EXISTS (SELECT 1 FROM lineitem WHERE l_orderkey = o_orderkey AND l_commitdate < l_receiptdate) GROUP BY o_orderpriority;
;


EXPLAIN ANALYZE SELECT o_orderpriority, count(*) AS order_count FROM orders WHERE o_orderdate >= DATE '1992-01-01' AND o_orderdate < DATE '1992-03-18' AND EXISTS (SELECT 1 FROM lineitem WHERE l_orderkey = o_orderkey AND l_commitdate < l_receiptdate) GROUP BY o_orderpriority;
;

/*+
  NestLoop(orders lineitem)
  SeqScan(orders)
  Parallel(orders 4)
  IndexScan(lineitem lineitem_pkey)
*/
EXPLAIN ANALYZE SELECT o_orderpriority, count(*) AS order_count FROM orders WHERE o_orderdate >= DATE '1992-01-01' AND o_orderdate < DATE '1992-03-18' AND EXISTS (SELECT 1 FROM lineitem WHERE l_orderkey = o_orderkey AND l_commitdate < l_receiptdate) GROUP BY o_orderpriority;
;

/*+
  NestLoop(orders lineitem)
  BitmapScan(orders)
  Parallel(orders 4)
  IndexScan(lineitem lineitem_pkey)
*/
EXPLAIN ANALYZE SELECT o_orderpriority, count(*) AS order_count FROM orders WHERE o_orderdate >= DATE '1992-01-01' AND o_orderdate < DATE '1992-03-17' AND EXISTS (SELECT 1 FROM lineitem WHERE l_orderkey = o_orderkey AND l_commitdate < l_receiptdate) GROUP BY o_orderpriority;
;

-- Switch 4: 1992-05-17 and 1992-05-18

EXPLAIN ANALYZE SELECT o_orderpriority, count(*) AS order_count FROM orders WHERE o_orderdate >= DATE '1992-01-01' AND o_orderdate < DATE '1992-05-17' AND EXISTS (SELECT 1 FROM lineitem WHERE l_orderkey = o_orderkey AND l_commitdate < l_receiptdate) GROUP BY o_orderpriority;
;


EXPLAIN ANALYZE SELECT o_orderpriority, count(*) AS order_count FROM orders WHERE o_orderdate >= DATE '1992-01-01' AND o_orderdate < DATE '1992-05-18' AND EXISTS (SELECT 1 FROM lineitem WHERE l_orderkey = o_orderkey AND l_commitdate < l_receiptdate) GROUP BY o_orderpriority;
;

/*+
  NestLoop(orders lineitem)
  BitmapScan(orders)
  Parallel(orders 4)
  IndexScan(lineitem lineitem_pkey)
*/
EXPLAIN ANALYZE SELECT o_orderpriority, count(*) AS order_count FROM orders WHERE o_orderdate >= DATE '1992-01-01' AND o_orderdate < DATE '1992-05-18' AND EXISTS (SELECT 1 FROM lineitem WHERE l_orderkey = o_orderkey AND l_commitdate < l_receiptdate) GROUP BY o_orderpriority;
;

/*+
  NestLoop(orders lineitem)
  SeqScan(orders)
  Parallel(orders 4)
  IndexScan(lineitem lineitem_pkey)
*/
EXPLAIN ANALYZE SELECT o_orderpriority, count(*) AS order_count FROM orders WHERE o_orderdate >= DATE '1992-01-01' AND o_orderdate < DATE '1992-05-17' AND EXISTS (SELECT 1 FROM lineitem WHERE l_orderkey = o_orderkey AND l_commitdate < l_receiptdate) GROUP BY o_orderpriority;
;

-- Switch 5: 1992-05-18 and 1992-05-19

EXPLAIN ANALYZE SELECT o_orderpriority, count(*) AS order_count FROM orders WHERE o_orderdate >= DATE '1992-01-01' AND o_orderdate < DATE '1992-05-18' AND EXISTS (SELECT 1 FROM lineitem WHERE l_orderkey = o_orderkey AND l_commitdate < l_receiptdate) GROUP BY o_orderpriority;
;


EXPLAIN ANALYZE SELECT o_orderpriority, count(*) AS order_count FROM orders WHERE o_orderdate >= DATE '1992-01-01' AND o_orderdate < DATE '1992-05-19' AND EXISTS (SELECT 1 FROM lineitem WHERE l_orderkey = o_orderkey AND l_commitdate < l_receiptdate) GROUP BY o_orderpriority;
;

/*+
  NestLoop(orders lineitem)
  SeqScan(orders)
  Parallel(orders 4)
  IndexScan(lineitem lineitem_pkey)
*/
EXPLAIN ANALYZE SELECT o_orderpriority, count(*) AS order_count FROM orders WHERE o_orderdate >= DATE '1992-01-01' AND o_orderdate < DATE '1992-05-19' AND EXISTS (SELECT 1 FROM lineitem WHERE l_orderkey = o_orderkey AND l_commitdate < l_receiptdate) GROUP BY o_orderpriority;
;

/*+
  HashJoin(orders lineitem)
  SeqScan(orders)
  Parallel(orders 4)
  SeqScan(lineitem)
  Parallel(lineitem 4)
*/
EXPLAIN ANALYZE SELECT o_orderpriority, count(*) AS order_count FROM orders WHERE o_orderdate >= DATE '1992-01-01' AND o_orderdate < DATE '1992-05-18' AND EXISTS (SELECT 1 FROM lineitem WHERE l_orderkey = o_orderkey AND l_commitdate < l_receiptdate) GROUP BY o_orderpriority;
;

-- Switch 6: 1997-12-24 and 1997-12-25

EXPLAIN ANALYZE SELECT o_orderpriority, count(*) AS order_count FROM orders WHERE o_orderdate >= DATE '1992-01-01' AND o_orderdate < DATE '1997-12-24' AND EXISTS (SELECT 1 FROM lineitem WHERE l_orderkey = o_orderkey AND l_commitdate < l_receiptdate) GROUP BY o_orderpriority;
;


EXPLAIN ANALYZE SELECT o_orderpriority, count(*) AS order_count FROM orders WHERE o_orderdate >= DATE '1992-01-01' AND o_orderdate < DATE '1997-12-25' AND EXISTS (SELECT 1 FROM lineitem WHERE l_orderkey = o_orderkey AND l_commitdate < l_receiptdate) GROUP BY o_orderpriority;
;

/*+
  HashJoin(orders lineitem)
  SeqScan(orders)
  Parallel(orders 4)
  SeqScan(lineitem)
  Parallel(lineitem 4)
*/
EXPLAIN ANALYZE SELECT o_orderpriority, count(*) AS order_count FROM orders WHERE o_orderdate >= DATE '1992-01-01' AND o_orderdate < DATE '1997-12-25' AND EXISTS (SELECT 1 FROM lineitem WHERE l_orderkey = o_orderkey AND l_commitdate < l_receiptdate) GROUP BY o_orderpriority;
;

/*+
  HashJoin(orders lineitem)
  SeqScan(orders)
  Parallel(orders 4)
  SeqScan(lineitem)
  Parallel(lineitem 4)
*/
EXPLAIN ANALYZE SELECT o_orderpriority, count(*) AS order_count FROM orders WHERE o_orderdate >= DATE '1992-01-01' AND o_orderdate < DATE '1997-12-24' AND EXISTS (SELECT 1 FROM lineitem WHERE l_orderkey = o_orderkey AND l_commitdate < l_receiptdate) GROUP BY o_orderpriority;
;

-- ==========================================
-- QUERY 3 EXECUTIONS
-- ==========================================

LOAD 'pg_hint_plan';

-- Switch 1: 1992-01-03 and 1992-01-04

EXPLAIN ANALYZE SELECT l.l_orderkey, l.l_extendedprice * (1 - l.l_discount) AS revenue, o.o_orderdate, o.o_shippriority FROM customer c JOIN orders o ON c.c_custkey = o.o_custkey JOIN lineitem l ON l.l_orderkey = o.o_orderkey WHERE c.c_mktsegment = 'BUILDING' AND o.o_orderdate < DATE '1992-01-03' AND l.l_shipdate > DATE '1992-01-03';
;


EXPLAIN ANALYZE SELECT l.l_orderkey, l.l_extendedprice * (1 - l.l_discount) AS revenue, o.o_orderdate, o.o_shippriority FROM customer c JOIN orders o ON c.c_custkey = o.o_custkey JOIN lineitem l ON l.l_orderkey = o.o_orderkey WHERE c.c_mktsegment = 'BUILDING' AND o.o_orderdate < DATE '1992-01-04' AND l.l_shipdate > DATE '1992-01-04';
;

/*+
  NestLoop(o c l)
  NestLoop(o c)
  BitmapScan(o)
  Parallel(o 4)
  IndexScan(c customer_pkey)
  IndexScan(l lineitem_pkey)
*/
EXPLAIN ANALYZE SELECT l.l_orderkey, l.l_extendedprice * (1 - l.l_discount) AS revenue, o.o_orderdate, o.o_shippriority FROM customer c JOIN orders o ON c.c_custkey = o.o_custkey JOIN lineitem l ON l.l_orderkey = o.o_orderkey WHERE c.c_mktsegment = 'BUILDING' AND o.o_orderdate < DATE '1992-01-04' AND l.l_shipdate > DATE '1992-01-04';
;

/*+
  NestLoop(c o l)
  HashJoin(c o)
  SeqScan(c)
  Parallel(c 4)
  BitmapScan(o)
  Parallel(o 4)
  IndexScan(l lineitem_pkey)
*/
EXPLAIN ANALYZE SELECT l.l_orderkey, l.l_extendedprice * (1 - l.l_discount) AS revenue, o.o_orderdate, o.o_shippriority FROM customer c JOIN orders o ON c.c_custkey = o.o_custkey JOIN lineitem l ON l.l_orderkey = o.o_orderkey WHERE c.c_mktsegment = 'BUILDING' AND o.o_orderdate < DATE '1992-01-03' AND l.l_shipdate > DATE '1992-01-03';
;

-- Switch 2: 1992-01-06 and 1992-01-07

EXPLAIN ANALYZE SELECT l.l_orderkey, l.l_extendedprice * (1 - l.l_discount) AS revenue, o.o_orderdate, o.o_shippriority FROM customer c JOIN orders o ON c.c_custkey = o.o_custkey JOIN lineitem l ON l.l_orderkey = o.o_orderkey WHERE c.c_mktsegment = 'BUILDING' AND o.o_orderdate < DATE '1992-01-06' AND l.l_shipdate > DATE '1992-01-06';
;


EXPLAIN ANALYZE SELECT l.l_orderkey, l.l_extendedprice * (1 - l.l_discount) AS revenue, o.o_orderdate, o.o_shippriority FROM customer c JOIN orders o ON c.c_custkey = o.o_custkey JOIN lineitem l ON l.l_orderkey = o.o_orderkey WHERE c.c_mktsegment = 'BUILDING' AND o.o_orderdate < DATE '1992-01-07' AND l.l_shipdate > DATE '1992-01-07';
;

/*+
  NestLoop(c o l)
  HashJoin(c o)
  SeqScan(c)
  Parallel(c 4)
  BitmapScan(o)
  Parallel(o 4)
  IndexScan(l lineitem_pkey)
*/
EXPLAIN ANALYZE SELECT l.l_orderkey, l.l_extendedprice * (1 - l.l_discount) AS revenue, o.o_orderdate, o.o_shippriority FROM customer c JOIN orders o ON c.c_custkey = o.o_custkey JOIN lineitem l ON l.l_orderkey = o.o_orderkey WHERE c.c_mktsegment = 'BUILDING' AND o.o_orderdate < DATE '1992-01-07' AND l.l_shipdate > DATE '1992-01-07';
;

/*+
  NestLoop(o c l)
  HashJoin(o c)
  BitmapScan(o)
  Parallel(o 4)
  SeqScan(c)
  Parallel(c 4)
  IndexScan(l lineitem_pkey)
*/
EXPLAIN ANALYZE SELECT l.l_orderkey, l.l_extendedprice * (1 - l.l_discount) AS revenue, o.o_orderdate, o.o_shippriority FROM customer c JOIN orders o ON c.c_custkey = o.o_custkey JOIN lineitem l ON l.l_orderkey = o.o_orderkey WHERE c.c_mktsegment = 'BUILDING' AND o.o_orderdate < DATE '1992-01-06' AND l.l_shipdate > DATE '1992-01-06';
;

-- Switch 3: 1992-01-17 and 1992-01-18

EXPLAIN ANALYZE SELECT l.l_orderkey, l.l_extendedprice * (1 - l.l_discount) AS revenue, o.o_orderdate, o.o_shippriority FROM customer c JOIN orders o ON c.c_custkey = o.o_custkey JOIN lineitem l ON l.l_orderkey = o.o_orderkey WHERE c.c_mktsegment = 'BUILDING' AND o.o_orderdate < DATE '1992-01-17' AND l.l_shipdate > DATE '1992-01-17';
;


EXPLAIN ANALYZE SELECT l.l_orderkey, l.l_extendedprice * (1 - l.l_discount) AS revenue, o.o_orderdate, o.o_shippriority FROM customer c JOIN orders o ON c.c_custkey = o.o_custkey JOIN lineitem l ON l.l_orderkey = o.o_orderkey WHERE c.c_mktsegment = 'BUILDING' AND o.o_orderdate < DATE '1992-01-18' AND l.l_shipdate > DATE '1992-01-18';
;

/*+
  NestLoop(o c l)
  HashJoin(o c)
  BitmapScan(o)
  Parallel(o 4)
  SeqScan(c)
  Parallel(c 4)
  IndexScan(l lineitem_pkey)
*/
EXPLAIN ANALYZE SELECT l.l_orderkey, l.l_extendedprice * (1 - l.l_discount) AS revenue, o.o_orderdate, o.o_shippriority FROM customer c JOIN orders o ON c.c_custkey = o.o_custkey JOIN lineitem l ON l.l_orderkey = o.o_orderkey WHERE c.c_mktsegment = 'BUILDING' AND o.o_orderdate < DATE '1992-01-18' AND l.l_shipdate > DATE '1992-01-18';
;

/*+
  HashJoin(l o c)
  HashJoin(l o)
  SeqScan(l)
  Parallel(l 4)
  BitmapScan(o)
  Parallel(o 4)
  SeqScan(c)
  Parallel(c 4)
*/
EXPLAIN ANALYZE SELECT l.l_orderkey, l.l_extendedprice * (1 - l.l_discount) AS revenue, o.o_orderdate, o.o_shippriority FROM customer c JOIN orders o ON c.c_custkey = o.o_custkey JOIN lineitem l ON l.l_orderkey = o.o_orderkey WHERE c.c_mktsegment = 'BUILDING' AND o.o_orderdate < DATE '1992-01-17' AND l.l_shipdate > DATE '1992-01-17';
;

-- Switch 4: 1992-02-16 and 1992-02-17

EXPLAIN ANALYZE SELECT l.l_orderkey, l.l_extendedprice * (1 - l.l_discount) AS revenue, o.o_orderdate, o.o_shippriority FROM customer c JOIN orders o ON c.c_custkey = o.o_custkey JOIN lineitem l ON l.l_orderkey = o.o_orderkey WHERE c.c_mktsegment = 'BUILDING' AND o.o_orderdate < DATE '1992-02-16' AND l.l_shipdate > DATE '1992-02-16';
;


EXPLAIN ANALYZE SELECT l.l_orderkey, l.l_extendedprice * (1 - l.l_discount) AS revenue, o.o_orderdate, o.o_shippriority FROM customer c JOIN orders o ON c.c_custkey = o.o_custkey JOIN lineitem l ON l.l_orderkey = o.o_orderkey WHERE c.c_mktsegment = 'BUILDING' AND o.o_orderdate < DATE '1992-02-17' AND l.l_shipdate > DATE '1992-02-17';
;

/*+
  HashJoin(l o c)
  HashJoin(l o)
  SeqScan(l)
  Parallel(l 4)
  BitmapScan(o)
  Parallel(o 4)
  SeqScan(c)
  Parallel(c 4)
*/
EXPLAIN ANALYZE SELECT l.l_orderkey, l.l_extendedprice * (1 - l.l_discount) AS revenue, o.o_orderdate, o.o_shippriority FROM customer c JOIN orders o ON c.c_custkey = o.o_custkey JOIN lineitem l ON l.l_orderkey = o.o_orderkey WHERE c.c_mktsegment = 'BUILDING' AND o.o_orderdate < DATE '1992-02-17' AND l.l_shipdate > DATE '1992-02-17';
;

/*+
  HashJoin(l o c)
  HashJoin(l o)
  SeqScan(l)
  Parallel(l 4)
  SeqScan(o)
  Parallel(o 4)
  SeqScan(c)
  Parallel(c 4)
*/
EXPLAIN ANALYZE SELECT l.l_orderkey, l.l_extendedprice * (1 - l.l_discount) AS revenue, o.o_orderdate, o.o_shippriority FROM customer c JOIN orders o ON c.c_custkey = o.o_custkey JOIN lineitem l ON l.l_orderkey = o.o_orderkey WHERE c.c_mktsegment = 'BUILDING' AND o.o_orderdate < DATE '1992-02-16' AND l.l_shipdate > DATE '1992-02-16';
;

-- Switch 5: 1992-03-13 and 1992-03-14

EXPLAIN ANALYZE SELECT l.l_orderkey, l.l_extendedprice * (1 - l.l_discount) AS revenue, o.o_orderdate, o.o_shippriority FROM customer c JOIN orders o ON c.c_custkey = o.o_custkey JOIN lineitem l ON l.l_orderkey = o.o_orderkey WHERE c.c_mktsegment = 'BUILDING' AND o.o_orderdate < DATE '1992-03-13' AND l.l_shipdate > DATE '1992-03-13';
;


EXPLAIN ANALYZE SELECT l.l_orderkey, l.l_extendedprice * (1 - l.l_discount) AS revenue, o.o_orderdate, o.o_shippriority FROM customer c JOIN orders o ON c.c_custkey = o.o_custkey JOIN lineitem l ON l.l_orderkey = o.o_orderkey WHERE c.c_mktsegment = 'BUILDING' AND o.o_orderdate < DATE '1992-03-14' AND l.l_shipdate > DATE '1992-03-14';
;

/*+
  HashJoin(l o c)
  HashJoin(l o)
  SeqScan(l)
  Parallel(l 4)
  SeqScan(o)
  Parallel(o 4)
  SeqScan(c)
  Parallel(c 4)
*/
EXPLAIN ANALYZE SELECT l.l_orderkey, l.l_extendedprice * (1 - l.l_discount) AS revenue, o.o_orderdate, o.o_shippriority FROM customer c JOIN orders o ON c.c_custkey = o.o_custkey JOIN lineitem l ON l.l_orderkey = o.o_orderkey WHERE c.c_mktsegment = 'BUILDING' AND o.o_orderdate < DATE '1992-03-14' AND l.l_shipdate > DATE '1992-03-14';
;

/*+
  HashJoin(l o c)
  SeqScan(l)
  Parallel(l 4)
  HashJoin(o c)
  SeqScan(o)
  Parallel(o 4)
  SeqScan(c)
  Parallel(c 4)
*/
EXPLAIN ANALYZE SELECT l.l_orderkey, l.l_extendedprice * (1 - l.l_discount) AS revenue, o.o_orderdate, o.o_shippriority FROM customer c JOIN orders o ON c.c_custkey = o.o_custkey JOIN lineitem l ON l.l_orderkey = o.o_orderkey WHERE c.c_mktsegment = 'BUILDING' AND o.o_orderdate < DATE '1992-03-13' AND l.l_shipdate > DATE '1992-03-13';
;

-- Switch 6: 1992-03-19 and 1992-03-20

EXPLAIN ANALYZE SELECT l.l_orderkey, l.l_extendedprice * (1 - l.l_discount) AS revenue, o.o_orderdate, o.o_shippriority FROM customer c JOIN orders o ON c.c_custkey = o.o_custkey JOIN lineitem l ON l.l_orderkey = o.o_orderkey WHERE c.c_mktsegment = 'BUILDING' AND o.o_orderdate < DATE '1992-03-19' AND l.l_shipdate > DATE '1992-03-19';
;


EXPLAIN ANALYZE SELECT l.l_orderkey, l.l_extendedprice * (1 - l.l_discount) AS revenue, o.o_orderdate, o.o_shippriority FROM customer c JOIN orders o ON c.c_custkey = o.o_custkey JOIN lineitem l ON l.l_orderkey = o.o_orderkey WHERE c.c_mktsegment = 'BUILDING' AND o.o_orderdate < DATE '1992-03-20' AND l.l_shipdate > DATE '1992-03-20';
;

/*+
  HashJoin(l o c)
  SeqScan(l)
  Parallel(l 4)
  HashJoin(o c)
  SeqScan(o)
  Parallel(o 4)
  SeqScan(c)
  Parallel(c 4)
*/
EXPLAIN ANALYZE SELECT l.l_orderkey, l.l_extendedprice * (1 - l.l_discount) AS revenue, o.o_orderdate, o.o_shippriority FROM customer c JOIN orders o ON c.c_custkey = o.o_custkey JOIN lineitem l ON l.l_orderkey = o.o_orderkey WHERE c.c_mktsegment = 'BUILDING' AND o.o_orderdate < DATE '1992-03-20' AND l.l_shipdate > DATE '1992-03-20';
;

/*+
  HashJoin(l o c)
  SeqScan(l)
  Parallel(l 4)
  HashJoin(o c)
  BitmapScan(o)
  Parallel(o 4)
  SeqScan(c)
  Parallel(c 4)
*/
EXPLAIN ANALYZE SELECT l.l_orderkey, l.l_extendedprice * (1 - l.l_discount) AS revenue, o.o_orderdate, o.o_shippriority FROM customer c JOIN orders o ON c.c_custkey = o.o_custkey JOIN lineitem l ON l.l_orderkey = o.o_orderkey WHERE c.c_mktsegment = 'BUILDING' AND o.o_orderdate < DATE '1992-03-19' AND l.l_shipdate > DATE '1992-03-19';
;

-- Switch 7: 1992-05-20 and 1992-05-21

EXPLAIN ANALYZE SELECT l.l_orderkey, l.l_extendedprice * (1 - l.l_discount) AS revenue, o.o_orderdate, o.o_shippriority FROM customer c JOIN orders o ON c.c_custkey = o.o_custkey JOIN lineitem l ON l.l_orderkey = o.o_orderkey WHERE c.c_mktsegment = 'BUILDING' AND o.o_orderdate < DATE '1992-05-20' AND l.l_shipdate > DATE '1992-05-20';
;


EXPLAIN ANALYZE SELECT l.l_orderkey, l.l_extendedprice * (1 - l.l_discount) AS revenue, o.o_orderdate, o.o_shippriority FROM customer c JOIN orders o ON c.c_custkey = o.o_custkey JOIN lineitem l ON l.l_orderkey = o.o_orderkey WHERE c.c_mktsegment = 'BUILDING' AND o.o_orderdate < DATE '1992-05-21' AND l.l_shipdate > DATE '1992-05-21';
;

/*+
  HashJoin(l o c)
  SeqScan(l)
  Parallel(l 4)
  HashJoin(o c)
  BitmapScan(o)
  Parallel(o 4)
  SeqScan(c)
  Parallel(c 4)
*/
EXPLAIN ANALYZE SELECT l.l_orderkey, l.l_extendedprice * (1 - l.l_discount) AS revenue, o.o_orderdate, o.o_shippriority FROM customer c JOIN orders o ON c.c_custkey = o.o_custkey JOIN lineitem l ON l.l_orderkey = o.o_orderkey WHERE c.c_mktsegment = 'BUILDING' AND o.o_orderdate < DATE '1992-05-21' AND l.l_shipdate > DATE '1992-05-21';
;

/*+
  HashJoin(l o c)
  SeqScan(l)
  Parallel(l 4)
  HashJoin(o c)
  SeqScan(o)
  Parallel(o 4)
  SeqScan(c)
  Parallel(c 4)
*/
EXPLAIN ANALYZE SELECT l.l_orderkey, l.l_extendedprice * (1 - l.l_discount) AS revenue, o.o_orderdate, o.o_shippriority FROM customer c JOIN orders o ON c.c_custkey = o.o_custkey JOIN lineitem l ON l.l_orderkey = o.o_orderkey WHERE c.c_mktsegment = 'BUILDING' AND o.o_orderdate < DATE '1992-05-20' AND l.l_shipdate > DATE '1992-05-20';
;

-- Switch 8: 1992-12-04 and 1992-12-05

EXPLAIN ANALYZE SELECT l.l_orderkey, l.l_extendedprice * (1 - l.l_discount) AS revenue, o.o_orderdate, o.o_shippriority FROM customer c JOIN orders o ON c.c_custkey = o.o_custkey JOIN lineitem l ON l.l_orderkey = o.o_orderkey WHERE c.c_mktsegment = 'BUILDING' AND o.o_orderdate < DATE '1992-12-04' AND l.l_shipdate > DATE '1992-12-04';
;


EXPLAIN ANALYZE SELECT l.l_orderkey, l.l_extendedprice * (1 - l.l_discount) AS revenue, o.o_orderdate, o.o_shippriority FROM customer c JOIN orders o ON c.c_custkey = o.o_custkey JOIN lineitem l ON l.l_orderkey = o.o_orderkey WHERE c.c_mktsegment = 'BUILDING' AND o.o_orderdate < DATE '1992-12-05' AND l.l_shipdate > DATE '1992-12-05';
;

/*+
  HashJoin(l o c)
  SeqScan(l)
  Parallel(l 4)
  HashJoin(o c)
  SeqScan(o)
  Parallel(o 4)
  SeqScan(c)
  Parallel(c 4)
*/
EXPLAIN ANALYZE SELECT l.l_orderkey, l.l_extendedprice * (1 - l.l_discount) AS revenue, o.o_orderdate, o.o_shippriority FROM customer c JOIN orders o ON c.c_custkey = o.o_custkey JOIN lineitem l ON l.l_orderkey = o.o_orderkey WHERE c.c_mktsegment = 'BUILDING' AND o.o_orderdate < DATE '1992-12-05' AND l.l_shipdate > DATE '1992-12-05';
;

/*+
  HashJoin(l o c)
  HashJoin(l o)
  SeqScan(l)
  Parallel(l 4)
  SeqScan(o)
  Parallel(o 4)
  SeqScan(c)
  Parallel(c 4)
*/
EXPLAIN ANALYZE SELECT l.l_orderkey, l.l_extendedprice * (1 - l.l_discount) AS revenue, o.o_orderdate, o.o_shippriority FROM customer c JOIN orders o ON c.c_custkey = o.o_custkey JOIN lineitem l ON l.l_orderkey = o.o_orderkey WHERE c.c_mktsegment = 'BUILDING' AND o.o_orderdate < DATE '1992-12-04' AND l.l_shipdate > DATE '1992-12-04';
;

-- Switch 9: 1993-03-07 and 1993-03-08

EXPLAIN ANALYZE SELECT l.l_orderkey, l.l_extendedprice * (1 - l.l_discount) AS revenue, o.o_orderdate, o.o_shippriority FROM customer c JOIN orders o ON c.c_custkey = o.o_custkey JOIN lineitem l ON l.l_orderkey = o.o_orderkey WHERE c.c_mktsegment = 'BUILDING' AND o.o_orderdate < DATE '1993-03-07' AND l.l_shipdate > DATE '1993-03-07';
;


EXPLAIN ANALYZE SELECT l.l_orderkey, l.l_extendedprice * (1 - l.l_discount) AS revenue, o.o_orderdate, o.o_shippriority FROM customer c JOIN orders o ON c.c_custkey = o.o_custkey JOIN lineitem l ON l.l_orderkey = o.o_orderkey WHERE c.c_mktsegment = 'BUILDING' AND o.o_orderdate < DATE '1993-03-08' AND l.l_shipdate > DATE '1993-03-08';
;

/*+
  HashJoin(l o c)
  HashJoin(l o)
  SeqScan(l)
  Parallel(l 4)
  SeqScan(o)
  Parallel(o 4)
  SeqScan(c)
  Parallel(c 4)
*/
EXPLAIN ANALYZE SELECT l.l_orderkey, l.l_extendedprice * (1 - l.l_discount) AS revenue, o.o_orderdate, o.o_shippriority FROM customer c JOIN orders o ON c.c_custkey = o.o_custkey JOIN lineitem l ON l.l_orderkey = o.o_orderkey WHERE c.c_mktsegment = 'BUILDING' AND o.o_orderdate < DATE '1993-03-08' AND l.l_shipdate > DATE '1993-03-08';
;

/*+
  HashJoin(l o c)
  SeqScan(l)
  Parallel(l 4)
  HashJoin(o c)
  SeqScan(o)
  Parallel(o 4)
  SeqScan(c)
  Parallel(c 4)
*/
EXPLAIN ANALYZE SELECT l.l_orderkey, l.l_extendedprice * (1 - l.l_discount) AS revenue, o.o_orderdate, o.o_shippriority FROM customer c JOIN orders o ON c.c_custkey = o.o_custkey JOIN lineitem l ON l.l_orderkey = o.o_orderkey WHERE c.c_mktsegment = 'BUILDING' AND o.o_orderdate < DATE '1993-03-07' AND l.l_shipdate > DATE '1993-03-07';
;

