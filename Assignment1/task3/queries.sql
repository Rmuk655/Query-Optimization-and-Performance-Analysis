\set QUIET 1
\pset format unaligned
\pset tuples_only on

SET enable_seqscan = off;

\o query_plans/without_indexes.json
EXPLAIN (ANALYZE, FORMAT JSON)
SELECT SUM(l_extendedprice * l_discount) AS revenue
FROM lineitem
WHERE l_shipdate >= '1994-01-01'
  AND l_shipdate < date '1994-01-01' + interval '1' year
  AND l_discount BETWEEN 0.05 AND 0.07
  AND l_quantity < 24;

\o query_plans/with_indexes1.json
CREATE INDEX I_quantity on lineitem(l_quantity);
EXPLAIN (ANALYZE, FORMAT JSON)
SELECT SUM(l_extendedprice * l_discount) AS revenue
FROM lineitem
WHERE l_shipdate >= '1994-01-01'
  AND l_shipdate < date '1994-01-01' + interval '1' year
  AND l_discount BETWEEN 0.05 AND 0.07
  AND l_quantity < 24;
DROP INDEX I_quantity;

\o query_plans/with_indexes2.json
CREATE INDEX I_shipdate on lineitem(l_shipdate);
EXPLAIN (ANALYZE, FORMAT JSON)
SELECT SUM(l_extendedprice * l_discount) AS revenue
FROM lineitem
WHERE l_shipdate >= '1994-01-01'
  AND l_shipdate < date '1994-01-01' + interval '1' year
  AND l_discount BETWEEN 0.05 AND 0.07
  AND l_quantity < 24;
DROP INDEX I_shipdate;

\o query_plans/with_indexes3.json
CREATE INDEX I_discount on lineitem(l_discount);
EXPLAIN (ANALYZE, FORMAT JSON)
SELECT SUM(l_extendedprice * l_discount) AS revenue
FROM lineitem
WHERE l_shipdate >= '1994-01-01'
  AND l_shipdate < date '1994-01-01' + interval '1' year
  AND l_discount BETWEEN 0.05 AND 0.07
  AND l_quantity < 24;
DROP INDEX I_discount;

\o query_plans/with_indexes4.json
CREATE INDEX I_date_discount ON lineitem(l_shipdate, l_discount);
EXPLAIN (ANALYZE, FORMAT JSON)
SELECT SUM(l_extendedprice * l_discount) AS revenue
FROM lineitem
WHERE l_shipdate >= '1994-01-01'
  AND l_shipdate < date '1994-01-01' + interval '1' year
  AND l_discount BETWEEN 0.05 AND 0.07
  AND l_quantity < 24;
DROP INDEX I_date_discount;

\o query_plans/with_indexes5.json
CREATE INDEX I_discount_shipdate ON lineitem(l_discount, l_shipdate);
EXPLAIN (ANALYZE, FORMAT JSON) 
SELECT SUM(l_extendedprice * l_discount) AS revenue
FROM lineitem
WHERE l_shipdate >= '1994-01-01'
  AND l_shipdate < date '1994-01-01' + interval '1' year
  AND l_discount BETWEEN 0.05 AND 0.07
  AND l_quantity < 24;
DROP INDEX I_discount_shipdate;

\o query_plans/with_indexes6.json
CREATE INDEX I_shipdate_quantity ON lineitem(l_shipdate, l_quantity);
EXPLAIN (ANALYZE, FORMAT JSON) 
SELECT SUM(l_extendedprice * l_discount) AS revenue
FROM lineitem
WHERE l_shipdate >= '1994-01-01'
  AND l_shipdate < date '1994-01-01' + interval '1' year
  AND l_discount BETWEEN 0.05 AND 0.07
  AND l_quantity < 24;
DROP INDEX I_shipdate_quantity;

\o query_plans/with_indexes7.json
CREATE INDEX I_quantity_shipdate ON lineitem(l_quantity, l_shipdate);
EXPLAIN (ANALYZE, FORMAT JSON) 
SELECT SUM(l_extendedprice * l_discount) AS revenue
FROM lineitem
WHERE l_shipdate >= '1994-01-01'
  AND l_shipdate < date '1994-01-01' + interval '1' year
  AND l_discount BETWEEN 0.05 AND 0.07
  AND l_quantity < 24;
DROP INDEX I_quantity_shipdate;

\o query_plans/with_indexes8.json
CREATE INDEX I_discount_quantity ON lineitem(l_discount, l_quantity);
EXPLAIN (ANALYZE, FORMAT JSON) 
SELECT SUM(l_extendedprice * l_discount) AS revenue
FROM lineitem
WHERE l_shipdate >= '1994-01-01'
  AND l_shipdate < date '1994-01-01' + interval '1' year
  AND l_discount BETWEEN 0.05 AND 0.07
  AND l_quantity < 24;
DROP INDEX I_discount_quantity;

\o query_plans/with_indexes9.json
CREATE INDEX I_quantity_discount ON lineitem(l_quantity, l_discount);
EXPLAIN (ANALYZE, FORMAT JSON)
SELECT SUM(l_extendedprice * l_discount) AS revenue
FROM lineitem
WHERE l_shipdate >= '1994-01-01'
  AND l_shipdate < date '1994-01-01' + interval '1' year
  AND l_discount BETWEEN 0.05 AND 0.07
  AND l_quantity < 24;
DROP INDEX I_quantity_discount;

\o query_plans/with_indexes10.json
CREATE INDEX I_shipdate_discount_quantity ON lineitem(l_shipdate, l_discount, l_quantity);
EXPLAIN (ANALYZE, FORMAT JSON)
SELECT SUM(l_extendedprice * l_discount) AS revenue
FROM lineitem
WHERE l_shipdate >= '1994-01-01'
  AND l_shipdate < date '1994-01-01' + interval '1' year
  AND l_discount BETWEEN 0.05 AND 0.07
  AND l_quantity < 24;
DROP INDEX I_shipdate_discount_quantity;

\o query_plans/with_indexes11.json
CREATE INDEX I_shipdate_quantity_discount ON lineitem(l_shipdate, l_quantity, l_discount);
EXPLAIN (ANALYZE, FORMAT JSON)
SELECT SUM(l_extendedprice * l_discount) AS revenue
FROM lineitem
WHERE l_shipdate >= '1994-01-01'
  AND l_shipdate < date '1994-01-01' + interval '1' year
  AND l_discount BETWEEN 0.05 AND 0.07
  AND l_quantity < 24;
DROP INDEX I_shipdate_quantity_discount;

\o query_plans/with_indexes12.json
CREATE INDEX I_discount_shipdate_quantity ON lineitem(l_discount, l_shipdate, l_quantity);
EXPLAIN (ANALYZE, FORMAT JSON) 
SELECT SUM(l_extendedprice * l_discount) AS revenue
FROM lineitem
WHERE l_shipdate >= '1994-01-01'
  AND l_shipdate < date '1994-01-01' + interval '1' year
  AND l_discount BETWEEN 0.05 AND 0.07
  AND l_quantity < 24;
DROP INDEX I_discount_shipdate_quantity;

\o query_plans/with_indexes13.json
CREATE INDEX I_discount_quantity_shipdate ON lineitem(l_discount, l_quantity, l_shipdate);
EXPLAIN (ANALYZE, FORMAT JSON) 
SELECT SUM(l_extendedprice * l_discount) AS revenue
FROM lineitem
WHERE l_shipdate >= '1994-01-01'
  AND l_shipdate < date '1994-01-01' + interval '1' year
  AND l_discount BETWEEN 0.05 AND 0.07
  AND l_quantity < 24;
DROP INDEX I_discount_quantity_shipdate;

\o query_plans/with_indexes14.json
CREATE INDEX I_quantity_shipdate_discount ON lineitem(l_quantity, l_shipdate, l_discount);
EXPLAIN (ANALYZE, FORMAT JSON)
SELECT SUM(l_extendedprice * l_discount) AS revenue
FROM lineitem
WHERE l_shipdate >= '1994-01-01'
  AND l_shipdate < date '1994-01-01' + interval '1' year
  AND l_discount BETWEEN 0.05 AND 0.07
  AND l_quantity < 24;
DROP INDEX I_quantity_shipdate_discount;

\o query_plans/with_indexes15.json
CREATE INDEX I_quantity_discount_shipdate ON lineitem(l_quantity, l_discount, l_shipdate);
EXPLAIN (ANALYZE, FORMAT JSON) 
SELECT SUM(l_extendedprice * l_discount) AS revenue
FROM lineitem
WHERE l_shipdate >= '1994-01-01'
  AND l_shipdate < date '1994-01-01' + interval '1' year
  AND l_discount BETWEEN 0.05 AND 0.07
  AND l_quantity < 24;
DROP INDEX I_quantity_discount_shipdate;

\o query_plans/with_indexes16.json
CREATE INDEX I_cov_sd_ds_qt ON lineitem(l_shipdate, l_discount, l_quantity, l_extendedprice);
EXPLAIN (ANALYZE, FORMAT JSON)
SELECT SUM(l_extendedprice * l_discount) AS revenue
FROM lineitem
WHERE l_shipdate >= '1994-01-01'
  AND l_shipdate < date '1994-01-01' + interval '1' year
  AND l_discount BETWEEN 0.05 AND 0.07
  AND l_quantity < 24;
DROP INDEX I_cov_sd_ds_qt;

\o query_plans/with_indexes17.json
CREATE INDEX I_cov_sd_qt_ds ON lineitem(l_shipdate, l_quantity, l_discount, l_extendedprice);
EXPLAIN (ANALYZE, FORMAT JSON)
SELECT SUM(l_extendedprice * l_discount) AS revenue
FROM lineitem
WHERE l_shipdate >= '1994-01-01'
  AND l_shipdate < date '1994-01-01' + interval '1' year
  AND l_discount BETWEEN 0.05 AND 0.07
  AND l_quantity < 24;
DROP INDEX I_cov_sd_qt_ds;

\o query_plans/with_indexes18.json
CREATE INDEX I_cov_ds_sd_qt ON lineitem(l_discount, l_shipdate, l_quantity, l_extendedprice);
EXPLAIN (ANALYZE, FORMAT JSON)
SELECT SUM(l_extendedprice * l_discount) AS revenue
FROM lineitem
WHERE l_shipdate >= '1994-01-01'
  AND l_shipdate < date '1994-01-01' + interval '1' year
  AND l_discount BETWEEN 0.05 AND 0.07
  AND l_quantity < 24;
DROP INDEX I_cov_ds_sd_qt;

\o query_plans/with_indexes19.json
CREATE INDEX I_cov_ds_qt_sd ON lineitem(l_discount, l_quantity, l_shipdate, l_extendedprice);
EXPLAIN (ANALYZE, FORMAT JSON)
SELECT SUM(l_extendedprice * l_discount) AS revenue
FROM lineitem
WHERE l_shipdate >= '1994-01-01'
  AND l_shipdate < date '1994-01-01' + interval '1' year
  AND l_discount BETWEEN 0.05 AND 0.07
  AND l_quantity < 24;
DROP INDEX I_cov_ds_qt_sd;

\o query_plans/with_indexes20.json
CREATE INDEX I_cov_qt_sd_ds ON lineitem(l_quantity, l_shipdate, l_discount, l_extendedprice);
EXPLAIN (ANALYZE, FORMAT JSON)
SELECT SUM(l_extendedprice * l_discount) AS revenue
FROM lineitem
WHERE l_shipdate >= '1994-01-01'
  AND l_shipdate < date '1994-01-01' + interval '1' year
  AND l_discount BETWEEN 0.05 AND 0.07
  AND l_quantity < 24;
DROP INDEX I_cov_qt_sd_ds;

\o query_plans/with_indexes21.json
CREATE INDEX I_cov_qt_ds_sd ON lineitem(l_quantity, l_discount, l_shipdate, l_extendedprice);
EXPLAIN (ANALYZE, FORMAT JSON)
SELECT SUM(l_extendedprice * l_discount) AS revenue
FROM lineitem
WHERE l_shipdate >= '1994-01-01'
  AND l_shipdate < date '1994-01-01' + interval '1' year
  AND l_discount BETWEEN 0.05 AND 0.07
  AND l_quantity < 24;
DROP INDEX I_cov_qt_ds_sd;

\o
\pset format aligned
\pset tuples_only off



