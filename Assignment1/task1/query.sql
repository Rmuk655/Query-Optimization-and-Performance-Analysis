\timing on 

-- indexing before loading data
CREATE TABLE lineitem2 (
    l_orderkey        INTEGER,
    l_partkey         INTEGER,
    l_suppkey         INTEGER,
    l_linenumber      INTEGER,
    l_quantity        NUMERIC,
    l_extendedprice   NUMERIC,
    l_discount        NUMERIC,
    l_tax             NUMERIC,
    l_returnflag      CHAR(1),
    l_linestatus      CHAR(1),
    l_shipdate        DATE,
    l_commitdate      DATE,
    l_receiptdate     DATE,
    l_shipinstruct    TEXT,
    l_shipmode        TEXT,
    l_comment         TEXT
);

CREATE INDEX I2 ON lineitem2(l_quantity);
-- indexing after loading data

COPY lineitem2      
FROM '/tmp/lineitem_sf10.csv'
WITH (FORMAT csv, HEADER);
CREATE TABLE lineitem1 (
    l_orderkey        INTEGER,
    l_partkey         INTEGER,
    l_suppkey         INTEGER,
    l_linenumber      INTEGER,
    l_quantity        NUMERIC,
    l_extendedprice   NUMERIC,
    l_discount        NUMERIC,
    l_tax             NUMERIC,
    l_returnflag      CHAR(1),
    l_linestatus      CHAR(1),
    l_shipdate        DATE,
    l_commitdate      DATE,
    l_receiptdate     DATE,
    l_shipinstruct    TEXT,
    l_shipmode        TEXT,
    l_comment         TEXT
);

COPY lineitem1      
FROM '/tmp/lineitem_sf10.csv'
WITH (FORMAT csv, HEADER); 

CREATE INDEX I1 ON lineitem1(l_quantity);




