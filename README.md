# Query Optimization and Performance Analysis

This repository contains the practical implementation and analysis of **query optimization, indexing, and performance evaluation** using PostgreSQL.

---

## Overview

The project explores how database systems efficiently execute queries using **query optimization techniques and indexing strategies**. Through this, I analyzed and improved query performance using real-world datasets and execution plans.

---

## Repository Structure

Query-Optimization-and-Performance-Analysis/
 ├── Assignment1/
 │    ├── task1/
 │    ├── task2/
 │    └── task3/
 ├── Assignment2/
 │    ├── task1/
 │    ├── task2/
 │    ├── task3/
 │    ├── task4/
 │    └── pg_hint_plan-REL17_1_7_1/   (third-party PostgreSQL extension, used for plan hints)

---

## Key Concepts Covered

- SQL Query Optimization (EXPLAIN ANALYZE)
- Indexing Techniques (B-Tree, index scans)
- Query Execution Plans (sequential vs index scan)
- Performance Analysis (runtime comparison)
- Database Internals (cost models, cardinality)

---

## Setup

Requires PostgreSQL 17 and Python 3.

```bash
pip install -r requirements.txt        # psycopg2-binary, matplotlib
pip install -r requirements-data.txt   # duckdb (only to generate the TPC-H data)
export PGPASSWORD=<your local postgres password>

python setup_tpch.py --scale 0.1       # creates and loads the tpch_db database (about 600k lineitem rows)
```

`setup_tpch.py` generates TPC-H data with DuckDB's built-in generator, so no separate `dbgen` is needed. The assignments themselves used scale factor 10 (`Assignment1/task1/query.sql` loads `lineitem_sf10.csv`); use `--scale 10` to match, which needs several GB of disk. Connection settings come from `PGHOST`, `PGPORT`, `PGUSER` and `PGPASSWORD` (defaults: `localhost`, `5432`, `postgres`).

### What runs where

Verified against a scale-0.1 database:

| Script | Result |
|---|---|
| `Assignment1/task2/partA/task2A.py <column> <selectivity>` | runs; finds the threshold for a target selectivity |
| `Assignment1/task2/partB/task2B.py` | runs; produces the performance plot |
| `Assignment2/task1/task1.py` | runs; compares the two stored plans |
| `Assignment2/task2/task2.py` | runs; reports plan switches per query |

`Assignment2/task4/task4.py` also needs the `pg_hint_plan` extension (loaded via `shared_preload_libraries`) and an index on `lineitem(l_shipdate)`, and it drops OS caches and restarts PostgreSQL between runs for cold-cache timings, which requires root and a systemd-managed server (`echo 3 > /proc/sys/vm/drop_caches`). Without them it prints a warning and continues with warm caches. `Assignment2/pg_hint_plan-REL17_1_7_1/` is a vendored copy of the third-party [pg_hint_plan](https://github.com/ossc-db/pg_hint_plan) extension and keeps its own license.

Results depend on the scale factor and machine, so plan-switch dates and timings will differ from the committed analysis PDFs (which used scale 10).

## Technologies Used

- PostgreSQL
- SQL
- Python
- JSON

---

## Highlights

- Analyzed query performance before and after indexing  
- Demonstrated improvements using optimized queries  
- Explored execution plans and optimizer decisions  
- Conducted experiments on datasets  

---

## Key Learnings

- Execution plans matter more than just SQL syntax  
- Indexes improve performance but must be used carefully  
- Optimizers rely on cost estimation and statistics  
- Understanding scans and joins is critical  

---

## Future Improvements

- Add benchmarking scripts  
- Improve visualization of query plans  
- Extend to distributed databases  

---

## Author

Krishnan R  
B.Tech CSE, IIT Hyderabad
