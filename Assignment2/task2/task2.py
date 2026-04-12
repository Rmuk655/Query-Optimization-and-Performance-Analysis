import psycopg2
import sys
from datetime import timedelta

def connect_to_db():
    """
    Establish connection to PostgreSQL database.
    """
    try:
        conn = psycopg2.connect(
            host="localhost",
            database="tpch_db",
            user="postgres",
            password="MukKed&62"
        )
        return conn
    except Exception as e:
        print(f"Error connecting to database: {e}")
        sys.exit(1)
    
def extract_physical_operator_tree(plan):

    if not isinstance(plan, dict) or "Node Type" not in plan:
        raise ValueError(f"Plan missing 'Node Type' or invalid structure: {plan}")
    
    ans = {
        "Node Type": plan["Node Type"], 
        "Children": []
    }
    
    for key in ["Relation Name", "Index Name", "Parent Relationship",  "Join Type", "Strategy" , "Partial Mode", "Parallel Aware", "Operation"]:
        if key in plan:
            ans[key] = plan[key]
        
    if "Plans" in plan:
        for child in plan["Plans"]:
            ans["Children"].append(extract_physical_operator_tree(child))
            
    return ans


def compare_plans(plan1, plan2):
    try:
        root_plan1 = plan1[0]["Plan"]
        root_plan2 = plan2[0]["Plan"]
    except (IndexError, KeyError, TypeError) as e:
        raise ValueError(f"Invalid plan structure at root level: {e}") from e

    tree1 = extract_physical_operator_tree(root_plan1)
    tree2 = extract_physical_operator_tree(root_plan2)
    
    return tree1 == tree2

def get_plan(cur, date, query_no, query_template):

    if query_no == 3:
        query = query_template.format(date, date)
    else:
        query = query_template.format(date)

    cur.execute(query)
    return cur.fetchone()[0]

def plan_switch(cur, min_date, max_date, query_no, query_template):
    with open("output.txt", "a") as f:
        print(f"\nQuery {query_no}:", file=f)
        
        old_date = min_date
        plan_old = get_plan(cur, old_date, query_no, query_template)
        
        current_date = min_date + timedelta(days=1)
        switch_count = 1
        
        while current_date <= max_date:
            plan_current = get_plan(cur, current_date, query_no, query_template)

            if not compare_plans(plan_old, plan_current):
                print(f"Plan Switch {switch_count}: {old_date} and {current_date}", file=f)
                switch_count += 1
                plan_old = plan_current 
                
            old_date = current_date
            current_date += timedelta(days=1)

if __name__ == "__main__":
    conn = connect_to_db()
    cur = conn.cursor()

    query_1 = "SELECT MIN(l_shipdate), MAX(l_shipdate) FROM lineitem;"
    cur.execute(query_1)
    min_shipdate, max_shipdate = cur.fetchone()

    query1 = "EXPLAIN (FORMAT JSON) SELECT SUM(l_quantity), SUM(l_extendedprice), SUM(l_extendedprice * (1 - l_discount)), SUM(l_extendedprice * " \
            "(1 - l_discount) * (1 + l_tax)), AVG(l_quantity), AVG(l_extendedprice), AVG(l_discount), COUNT(*) FROM lineitem WHERE " \
            "l_shipdate <= DATE '{}';"
    
    plan_switch(cur, min_shipdate, max_shipdate, 1, query1)

    query_2 = "SELECT MIN(o_orderdate), MAX(o_orderdate) FROM orders;"
    cur.execute(query_2)
    min_orderdate, max_orderdate = cur.fetchone()

    query2 = "EXPLAIN (FORMAT JSON) SELECT o_orderpriority, count(*) AS order_count FROM orders WHERE o_orderdate >= DATE '1992-01-01' AND o_orderdate " \
        "< DATE '{}' AND EXISTS (SELECT 1 FROM lineitem WHERE l_orderkey = o_orderkey AND l_commitdate < l_receiptdate) " \
        "GROUP BY o_orderpriority;"

    plan_switch(cur, min_orderdate, max_orderdate, 2, query2)

    min_date = max(min_orderdate, min_shipdate)
    max_date = min(max_orderdate, max_shipdate)

    query3 = "EXPLAIN (FORMAT JSON) SELECT l.l_orderkey, l.l_extendedprice * (1 - l.l_discount) AS revenue, o.o_orderdate, o.o_shippriority FROM " \
        "customer c JOIN orders o ON c.c_custkey = o.o_custkey JOIN lineitem l ON l.l_orderkey = o.o_orderkey WHERE " \
        "c.c_mktsegment = 'BUILDING' AND o.o_orderdate < DATE '{}' AND l.l_shipdate > DATE '{}';"
    
    plan_switch(cur, min_date, max_date, 3, query3)

    cur.close()
    conn.close()