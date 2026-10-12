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
pip install -r requirements.txt     # psycopg2-binary, matplotlib
export PGPASSWORD=<your local postgres password>
```

The Python scripts connect to `localhost` as user `postgres` and expect a database named `tpch_db` containing the TPC-H tables (generate and load them with the TPC-H `dbgen` tool; the TPC-H data is not included here). `Assignment2/pg_hint_plan-REL17_1_7_1/` is a vendored copy of the third-party [pg_hint_plan](https://github.com/ossc-db/pg_hint_plan) extension, used for the plan-hint experiments in `Assignment2/task4`, and keeps its own license.

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
