"""Create and load the TPC-H database (default name: tpch_db) used by the assignments.

Data is generated with DuckDB's built-in TPC-H generator, so no external dbgen tool is needed.

    pip install -r requirements-data.txt
    export PGPASSWORD=<your postgres password>      # and PGHOST / PGPORT / PGUSER if not the defaults
    python setup_tpch.py --scale 0.1                # 0.1 is about 600k lineitem rows; the assignments used 10
"""
import argparse
import os
import tempfile

import duckdb
import psycopg2

TABLES = {
    "region": "r_regionkey INTEGER PRIMARY KEY, r_name TEXT, r_comment TEXT",
    "nation": "n_nationkey INTEGER PRIMARY KEY, n_name TEXT, n_regionkey INTEGER, n_comment TEXT",
    "supplier": "s_suppkey BIGINT PRIMARY KEY, s_name TEXT, s_address TEXT, s_nationkey INTEGER, "
                "s_phone TEXT, s_acctbal NUMERIC(15,2), s_comment TEXT",
    "customer": "c_custkey BIGINT PRIMARY KEY, c_name TEXT, c_address TEXT, c_nationkey INTEGER, "
                "c_phone TEXT, c_acctbal NUMERIC(15,2), c_mktsegment TEXT, c_comment TEXT",
    "part": "p_partkey BIGINT PRIMARY KEY, p_name TEXT, p_mfgr TEXT, p_brand TEXT, p_type TEXT, "
            "p_size INTEGER, p_container TEXT, p_retailprice NUMERIC(15,2), p_comment TEXT",
    "partsupp": "ps_partkey BIGINT, ps_suppkey BIGINT, ps_availqty BIGINT, ps_supplycost NUMERIC(15,2), "
                "ps_comment TEXT, PRIMARY KEY (ps_partkey, ps_suppkey)",
    "orders": "o_orderkey BIGINT PRIMARY KEY, o_custkey BIGINT, o_orderstatus TEXT, o_totalprice NUMERIC(15,2), "
              "o_orderdate DATE, o_orderpriority TEXT, o_clerk TEXT, o_shippriority INTEGER, o_comment TEXT",
    "lineitem": "l_orderkey BIGINT, l_partkey BIGINT, l_suppkey BIGINT, l_linenumber BIGINT, "
                "l_quantity NUMERIC(15,2), l_extendedprice NUMERIC(15,2), l_discount NUMERIC(15,2), "
                "l_tax NUMERIC(15,2), l_returnflag TEXT, l_linestatus TEXT, l_shipdate DATE, "
                "l_commitdate DATE, l_receiptdate DATE, l_shipinstruct TEXT, l_shipmode TEXT, l_comment TEXT",
}


def connect(dbname):
    return psycopg2.connect(
        host=os.environ.get("PGHOST", "localhost"),
        port=os.environ.get("PGPORT", "5432"),
        user=os.environ.get("PGUSER", "postgres"),
        password=os.environ.get("PGPASSWORD", "postgres"),
        dbname=dbname,
    )


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--scale", type=float, default=0.1, help="TPC-H scale factor")
    ap.add_argument("--dbname", default="tpch_db")
    args = ap.parse_args()

    admin = connect("postgres")
    admin.autocommit = True
    with admin.cursor() as cur:
        cur.execute("SELECT 1 FROM pg_database WHERE datname = %s", (args.dbname,))
        if cur.fetchone():
            raise SystemExit(f"database {args.dbname} already exists; drop it first or pass --dbname")
        cur.execute(f'CREATE DATABASE "{args.dbname}"')
    admin.close()

    duck = duckdb.connect()
    duck.execute("INSTALL tpch")
    duck.execute("LOAD tpch")
    duck.execute(f"CALL dbgen(sf={args.scale})")

    conn = connect(args.dbname)
    with tempfile.TemporaryDirectory() as tmp, conn, conn.cursor() as cur:
        for table, columns in TABLES.items():
            cur.execute(f"CREATE TABLE {table} ({columns})")
            path = os.path.join(tmp, f"{table}.csv")
            duck.execute(f"COPY {table} TO '{path}' (HEADER, DELIMITER ',')")
            with open(path, newline="") as fh:
                cur.copy_expert(f"COPY {table} FROM STDIN WITH (FORMAT csv, HEADER)", fh)
            cur.execute(f"SELECT count(*) FROM {table}")
            print(f"{table}: {cur.fetchone()[0]} rows")
    conn.autocommit = True
    with conn.cursor() as cur:
        cur.execute("ANALYZE")
    conn.close()


if __name__ == "__main__":
    main()
