import psycopg2
import sys
import subprocess
import time
import re
from datetime import timedelta, datetime

DB_HOST = "localhost"
DB_NAME = "tpch_db"
DB_USER = "postgres"
DB_PASS = "Babloo@1" # for running on teammate's laptop

TEMPLATES = {
    1: "SELECT SUM(l_quantity), SUM(l_extendedprice), SUM(l_extendedprice * (1 - l_discount)), SUM(l_extendedprice * (1 - l_discount) * (1 + l_tax)), AVG(l_quantity), AVG(l_extendedprice), AVG(l_discount), COUNT(*) FROM lineitem WHERE l_shipdate <= DATE '{}';",
    2: "SELECT o_orderpriority, count(*) AS order_count FROM orders WHERE o_orderdate >= DATE '1992-01-01' AND o_orderdate < DATE '{}' AND EXISTS (SELECT 1 FROM lineitem WHERE l_orderkey = o_orderkey AND l_commitdate < l_receiptdate) GROUP BY o_orderpriority;",
    3: "SELECT l.l_orderkey, l.l_extendedprice * (1 - l.l_discount) AS revenue, o.o_orderdate, o.o_shippriority FROM customer c JOIN orders o ON c.c_custkey = o.o_custkey JOIN lineitem l ON l.l_orderkey = o.o_orderkey WHERE c.c_mktsegment = 'BUILDING' AND o.o_orderdate < DATE '{}' AND l.l_shipdate > DATE '{}';"
}

SWITCHES_DATA = [
    # QUERY 1 
    {
        "q_no": 1, "switch_no": 1, "qi": "1992-01-07", "qj": "1992-01-08", "classification": "EARLY",
        "hint_i": "/*+\n  BitmapScan(lineitem)\n*/",
        "hint_j": "/*+\n  IndexScan(lineitem idx_lineitem_shipdate)\n*/"
    },
    {
        "q_no": 1, "switch_no": 2, "qi": "1992-01-27", "qj": "1992-01-28", "classification": "DELAYED",
        "hint_i": "/*+\n  IndexScan(lineitem idx_lineitem_shipdate)\n*/",
        "hint_j": "/*+\n  BitmapScan(lineitem)\n  Parallel(lineitem 4)\n*/"
    },
    {
        "q_no": 1, "switch_no": 3, "qi": "1992-03-29", "qj": "1992-03-30", "classification": "DELAYED",
        "hint_i": "/*+\n  BitmapScan(lineitem)\n  Parallel(lineitem 4)\n*/",
        "hint_j": "/*+\n  SeqScan(lineitem)\n  Parallel(lineitem 4)\n*/"
    },

    # QUERY 2 
    {
        "q_no": 2, "switch_no": 1, "qi": "1992-01-01", "qj": "1992-01-02", "classification": "CORRECT",
        "hint_i": "/*+\n  NestLoop(orders lineitem)\n  IndexScan(orders idx_orders_orderdate)\n  IndexScan(lineitem lineitem_pkey)\n*/",
        "hint_j": "/*+\n  NestLoop(orders lineitem)\n  BitmapScan(orders)\n  Parallel(orders 4)\n  IndexScan(lineitem lineitem_pkey)\n*/"
    },
    {
        "q_no": 2, "switch_no": 2, "qi": "1992-02-18", "qj": "1992-02-19", "classification": "DELAYED",
        "hint_i": "/*+\n  NestLoop(orders lineitem)\n  BitmapScan(orders)\n  Parallel(orders 4)\n  IndexScan(lineitem lineitem_pkey)\n*/",
        "hint_j": "/*+\n  NestLoop(orders lineitem)\n  SeqScan(orders)\n  Parallel(orders 4)\n  IndexScan(lineitem lineitem_pkey)\n*/"
    },
    {
        "q_no": 2, "switch_no": 3, "qi": "1992-03-17", "qj": "1992-03-18", "classification": "EARLY",
        "hint_i": "/*+\n  NestLoop(orders lineitem)\n  SeqScan(orders)\n  Parallel(orders 4)\n  IndexScan(lineitem lineitem_pkey)\n*/",
        "hint_j": "/*+\n  NestLoop(orders lineitem)\n  BitmapScan(orders)\n  Parallel(orders 4)\n  IndexScan(lineitem lineitem_pkey)\n*/"
    },
    {
        "q_no": 2, "switch_no": 4, "qi": "1992-05-17", "qj": "1992-05-18", "classification": "DELAYED",
        "hint_i": "/*+\n  NestLoop(orders lineitem)\n  BitmapScan(orders)\n  Parallel(orders 4)\n  IndexScan(lineitem lineitem_pkey)\n*/",
        "hint_j": "/*+\n  NestLoop(orders lineitem)\n  SeqScan(orders)\n  Parallel(orders 4)\n  IndexScan(lineitem lineitem_pkey)\n*/"
    },
    {
        "q_no": 2, "switch_no": 5, "qi": "1992-05-18", "qj": "1992-05-19", "classification": "EARLY",
        "hint_i": "/*+\n  NestLoop(orders lineitem)\n  SeqScan(orders)\n  Parallel(orders 4)\n  IndexScan(lineitem lineitem_pkey)\n*/",
        "hint_j": "/*+\n  HashJoin(orders lineitem)\n  SeqScan(orders)\n  Parallel(orders 4)\n  SeqScan(lineitem)\n  Parallel(lineitem 4)\n*/"
    },
    {
        "q_no": 2, "switch_no": 6, "qi": "1997-12-24", "qj": "1997-12-25", "classification": "DELAYED",
        "hint_i": "/*+\n  HashJoin(orders lineitem)\n  SeqScan(orders)\n  Parallel(orders 4)\n  SeqScan(lineitem)\n  Parallel(lineitem 4)\n*/",
        "hint_j": "/*+\n  HashJoin(orders lineitem)\n  SeqScan(orders)\n  Parallel(orders 4)\n  SeqScan(lineitem)\n  Parallel(lineitem 4)\n*/"
    },

    # QUERY 3
    {
        "q_no": 3, "switch_no": 1, "qi": "1992-01-03", "qj": "1992-01-04", "classification": "DELAYED",
        "hint_i": "/*+\n  NestLoop(o c l)\n  NestLoop(o c)\n  BitmapScan(o)\n  Parallel(o 4)\n  IndexScan(c customer_pkey)\n  IndexScan(l lineitem_pkey)\n*/",
        "hint_j": "/*+\n  NestLoop(c o l)\n  HashJoin(c o)\n  SeqScan(c)\n  Parallel(c 4)\n  BitmapScan(o)\n  Parallel(o 4)\n  IndexScan(l lineitem_pkey)\n*/"
    },
    {
        "q_no": 3, "switch_no": 2, "qi": "1992-01-06", "qj": "1992-01-07", "classification": "DELAYED",
        "hint_i": "/*+\n  NestLoop(c o l)\n  HashJoin(c o)\n  SeqScan(c)\n  Parallel(c 4)\n  BitmapScan(o)\n  Parallel(o 4)\n  IndexScan(l lineitem_pkey)\n*/",
        "hint_j": "/*+\n  NestLoop(o c l)\n  HashJoin(o c)\n  BitmapScan(o)\n  Parallel(o 4)\n  SeqScan(c)\n  Parallel(c 4)\n  IndexScan(l lineitem_pkey)\n*/"
    },
    {
        "q_no": 3, "switch_no": 3, "qi": "1992-01-17", "qj": "1992-01-18", "classification": "EARLY",
        "hint_i": "/*+\n  NestLoop(o c l)\n  HashJoin(o c)\n  BitmapScan(o)\n  Parallel(o 4)\n  SeqScan(c)\n  Parallel(c 4)\n  IndexScan(l lineitem_pkey)\n*/",
        "hint_j": "/*+\n  HashJoin(l o c)\n  HashJoin(l o)\n  SeqScan(l)\n  Parallel(l 4)\n  BitmapScan(o)\n  Parallel(o 4)\n  SeqScan(c)\n  Parallel(c 4)\n*/"
    },
    {
        "q_no": 3, "switch_no": 4, "qi": "1992-02-16", "qj": "1992-02-17", "classification": "DELAYED",
        "hint_i": "/*+\n  HashJoin(l o c)\n  HashJoin(l o)\n  SeqScan(l)\n  Parallel(l 4)\n  BitmapScan(o)\n  Parallel(o 4)\n  SeqScan(c)\n  Parallel(c 4)\n*/",
        "hint_j": "/*+\n  HashJoin(l o c)\n  HashJoin(l o)\n  SeqScan(l)\n  Parallel(l 4)\n  SeqScan(o)\n  Parallel(o 4)\n  SeqScan(c)\n  Parallel(c 4)\n*/"
    },
    {
        "q_no": 3, "switch_no": 5, "qi": "1992-03-13", "qj": "1992-03-14", "classification": "DELAYED",
        "hint_i": "/*+\n  HashJoin(l o c)\n  HashJoin(l o)\n  SeqScan(l)\n  Parallel(l 4)\n  SeqScan(o)\n  Parallel(o 4)\n  SeqScan(c)\n  Parallel(c 4)\n*/",
        "hint_j": "/*+\n  HashJoin(l o c)\n  SeqScan(l)\n  Parallel(l 4)\n  HashJoin(o c)\n  SeqScan(o)\n  Parallel(o 4)\n  SeqScan(c)\n  Parallel(c 4)\n*/"
    },
    {
        "q_no": 3, "switch_no": 6, "qi": "1992-03-19", "qj": "1992-03-20", "classification": "EARLY",
        "hint_i": "/*+\n  HashJoin(l o c)\n  SeqScan(l)\n  Parallel(l 4)\n  HashJoin(o c)\n  SeqScan(o)\n  Parallel(o 4)\n  SeqScan(c)\n  Parallel(c 4)\n*/",
        "hint_j": "/*+\n  HashJoin(l o c)\n  SeqScan(l)\n  Parallel(l 4)\n  HashJoin(o c)\n  BitmapScan(o)\n  Parallel(o 4)\n  SeqScan(c)\n  Parallel(c 4)\n*/"
    },
    {
        "q_no": 3, "switch_no": 7, "qi": "1992-05-20", "qj": "1992-05-21", "classification": "DELAYED",
        "hint_i": "/*+\n  HashJoin(l o c)\n  SeqScan(l)\n  Parallel(l 4)\n  HashJoin(o c)\n  BitmapScan(o)\n  Parallel(o 4)\n  SeqScan(c)\n  Parallel(c 4)\n*/",
        "hint_j": "/*+\n  HashJoin(l o c)\n  SeqScan(l)\n  Parallel(l 4)\n  HashJoin(o c)\n  SeqScan(o)\n  Parallel(o 4)\n  SeqScan(c)\n  Parallel(c 4)\n*/"
    },
    {
        "q_no": 3, "switch_no": 8, "qi": "1992-12-04", "qj": "1992-12-05", "classification": "DELAYED",
        "hint_i": "/*+\n  HashJoin(l o c)\n  SeqScan(l)\n  Parallel(l 4)\n  HashJoin(o c)\n  SeqScan(o)\n  Parallel(o 4)\n  SeqScan(c)\n  Parallel(c 4)\n*/",
        "hint_j": "/*+\n  HashJoin(l o c)\n  HashJoin(l o)\n  SeqScan(l)\n  Parallel(l 4)\n  SeqScan(o)\n  Parallel(o 4)\n  SeqScan(c)\n  Parallel(c 4)\n*/"
    },
    {
        "q_no": 3, "switch_no": 9, "qi": "1993-03-07", "qj": "1993-03-08", "classification": "DELAYED",
        "hint_i": "/*+\n  HashJoin(l o c)\n  HashJoin(l o)\n  SeqScan(l)\n  Parallel(l 4)\n  SeqScan(o)\n  Parallel(o 4)\n  SeqScan(c)\n  Parallel(c 4)\n*/",
        "hint_j": "/*+\n  HashJoin(l o c)\n  SeqScan(l)\n  Parallel(l 4)\n  HashJoin(o c)\n  SeqScan(o)\n  Parallel(o 4)\n  SeqScan(c)\n  Parallel(c 4)\n*/"
    }
]

def clear_system_caches():
    try:
        subprocess.run(["sh", "-c", "echo 3 > /proc/sys/vm/drop_caches"], check=True)
        subprocess.run(["systemctl", "restart", "postgresql"], check=True) 
        time.sleep(2)
    except subprocess.CalledProcessError as e:
        print(f"\nERROR: Failed to clear caches. 'sudo'?\n{e}")
        sys.exit(1)

def run_and_measure(query_template, date_val, hint, query_no):
    clear_system_caches()
    
    conn = psycopg2.connect(host=DB_HOST, database=DB_NAME, user=DB_USER, password=DB_PASS)
    cur = conn.cursor()
    cur.execute("LOAD 'pg_hint_plan';")
    
    if query_no == 3:
        final_query = f"{hint}\nEXPLAIN ANALYZE {query_template.format(date_val, date_val)}"
    else:
        final_query = f"{hint}\nEXPLAIN ANALYZE {query_template.format(date_val)}"
        
    cur.execute(final_query)
    output = cur.fetchall()
    
    cur.close()
    conn.close()
    
    for row in output:
        line = row[0]
        if "Execution Time" in line:
            match = re.search(r"Execution Time:\s+([0-9.]+)\s+ms", line)
            if match:
                return float(match.group(1))
    return 999999.0 

def find_optimal_switch(search_start, search_end, hint_i, hint_j, query_template, query_no):
    low = search_start
    high = search_end
    best_qi_prime = search_start
    
    while low <= high:
        delta_days = (high - low).days
        mid_date = low + timedelta(days=delta_days // 2)
        
        rt_i = run_and_measure(query_template, mid_date, hint_i, query_no)
        rt_j = run_and_measure(query_template, mid_date, hint_j, query_no)
        
        if rt_i <= rt_j:
            best_qi_prime = mid_date
            low = mid_date + timedelta(days=1)
        else:
            high = mid_date - timedelta(days=1)
            
    qi_prime = best_qi_prime
    qj_prime = qi_prime + timedelta(days=1)
    
    return qi_prime, qj_prime

def main():
    conn = psycopg2.connect(host=DB_HOST, database=DB_NAME, user=DB_USER, password=DB_PASS)
    cur = conn.cursor()
    bounds = {}
    
    cur.execute("SELECT MIN(l_shipdate), MAX(l_shipdate) FROM lineitem;")
    bounds[1] = cur.fetchone()
    
    cur.execute("SELECT MIN(o_orderdate), MAX(o_orderdate) FROM orders;")
    bounds[2] = cur.fetchone()
    
    cur.execute("SELECT MIN(o_orderdate), MAX(o_orderdate) FROM orders;")
    min_o, max_o = cur.fetchone()
    cur.execute("SELECT MIN(l_shipdate), MAX(l_shipdate) FROM lineitem;")
    min_l, max_l = cur.fetchone()
    bounds[3] = (max(min_o, min_l), min(max_o, max_l))
    
    cur.close()
    conn.close() 

    with open("task4_results.txt", "w") as out_file:
        out_file.write("TASK 4 OPTIMAL SWITCH RESULTS\n\n")

    # enumerate to easily access previous/next switches
    for idx, switch in enumerate(SWITCHES_DATA):
        q_no = switch["q_no"]
        s_no = switch["switch_no"]
        classification = switch["classification"]
        
        qi = datetime.strptime(switch["qi"], "%Y-%m-%d").date()
        qj = datetime.strptime(switch["qj"], "%Y-%m-%d").date()
        
        hint_i = switch["hint_i"]
        hint_j = switch["hint_j"]

        min_date, max_date = bounds[q_no] 
        template = TEMPLATES[q_no]

        if classification == "CORRECT":
            continue
        
        if classification == "DELAYED":
            # For DELAYED, we search BACKWARDS. 
            # Lower bound is the 'qj' of the previous switch (if it exists for the same query), else min_date.
            if idx > 0 and SWITCHES_DATA[idx-1]["q_no"] == q_no:
                search_start = datetime.strptime(SWITCHES_DATA[idx-1]["qj"], "%Y-%m-%d").date()
                bound_source = f"Previous Switch (qj = {search_start})"
            else:
                search_start = min_date
                bound_source = f"Query Min Date ({search_start})"
                
            search_end = qi
            print(f"Bounded Search Space: {bound_source} to Current qi ({search_end})")
            opt_qi, opt_qj = find_optimal_switch(search_start, search_end, hint_i, hint_j, template, q_no)

        elif classification == "EARLY":
            # For EARLY, we search FORWARDS.
            # Upper bound is the 'qi-1' of the next switch (if it exists for the same query), else max_date.
            search_start = qj
            if idx < len(SWITCHES_DATA) - 1 and SWITCHES_DATA[idx+1]["q_no"] == q_no:
                search_end = datetime.strptime(SWITCHES_DATA[idx+1]["qi"], "%Y-%m-%d").date()
                bound_source = f"Next Switch (qi = {search_end})"
            else:
                search_end = max_date
                bound_source = f"Query Max Date ({search_end})"

            search_end-=timedelta(days = 1)             
            opt_qi, opt_qj = find_optimal_switch(search_start, search_end, hint_i, hint_j, template, q_no)

        rt_pi_opt_qi = run_and_measure(template, opt_qi, hint_i, q_no)
        rt_pj_opt_qj = run_and_measure(template, opt_qj, hint_j, q_no)
        rt_pi_opt_qj = run_and_measure(template, opt_qj, hint_i, q_no)
        rt_pj_opt_qi = run_and_measure(template, opt_qi, hint_j, q_no)

        result_str = (
            f"Query {q_no}, Switch {s_no} Original: {qi} -> {qj} ({classification})\n"
            f"Optimal Switch Dates: qi' = {opt_qi}, qj' = {opt_qj}\n"
            f"RT(Pi', qi'): {rt_pi_opt_qi:.2f} ms\n"
            f"RT(Pj', qj'): {rt_pj_opt_qj:.2f} ms\n"
            f"RT(Pi', qj'): {rt_pi_opt_qj:.2f} ms\n"
            f"RT(Pj', qi'): {rt_pj_opt_qi:.2f} ms\n"
            f"-------------------------------------------------\n"
        )
        
        print(f"\n{result_str}")
        with open("task4_results.txt", "a") as out_file:
            out_file.write(result_str)

if __name__ == "__main__":
    main()