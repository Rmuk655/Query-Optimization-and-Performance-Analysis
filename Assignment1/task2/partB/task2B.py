import psycopg2
import sys
import time
import matplotlib.pyplot as plt
import csv

# ------------------------------------------------------------
# Database Connection
# ------------------------------------------------------------

no_of_iterations = 30
l_quantity = "l_quantity"

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
            ## password="postgres"
        )
        return conn
    except Exception as e:
        print(f"Error connecting to database: {e}")
        sys.exit(1)


# ------------------------------------------------------------
# TASKS 
# ------------------------------------------------------------

def get_total_rows(cursor):
    """
    TODO:
    Write a query to return total number of rows in lineitem table.
    """
    cursor.execute("SELECT COUNT(*) FROM lineitem")
    return cursor.fetchone()[0]


def get_quantity_for_selectivity(min_val, max_val, cursor, selectivity, total_rows):
    """
    TODO:
    Given a selectivity value (0–1), compute and return an l_quantity
    constant such that l_quantity <= constant achieves that selectivity.
    """
    # cursor.execute(f"SELECT MIN({l_quantity}), MAX({l_quantity}) FROM lineitem")
    # min_val, max_val = cursor.fetchone()
    # min_val = float(min_val)
    # max_val = float(max_val)
    quan = (max_val - min_val) * selectivity + min_val
    # total_rows = get_total_rows(cursor)
    actual_sel = verify_selectivity(cursor, quan, total_rows)
    if(abs(actual_sel - selectivity) <= 0.01 * selectivity):
        return quan
    elif(actual_sel < selectivity):
        low = quan
        high = max_val
    else:
        low = min_val
        high = quan
    best_error = 1.1
    for _ in range(0, no_of_iterations):
        mid = (low + high)/2.0
        cursor.execute("SELECT COUNT(*) FROM lineitem WHERE l_quantity <= %s",(mid,))
        actual_sel = float(cursor.fetchone()[0])/total_rows
        error = abs(actual_sel - selectivity)

        if(error < best_error):
            best_error = error
            quan = mid
        
        if(error <= 0.01 * selectivity):
            quan = mid
            break
        
        if(actual_sel < selectivity):
            low = mid
        else:
            high = mid
        
    return quan


def verify_selectivity(cursor, quantity_threshold, total_rows):
    """
    TODO:
    Verify the actual selectivity achieved by the computed threshold.
    """
    cursor.execute(f"SELECT COUNT(*) FROM lineitem WHERE {l_quantity} <= %s",(quantity_threshold,))
    return cursor.fetchone()[0]/total_rows


def main():
    """
    TODO:
    1. Connect to the database
    2. Read selectivity from user
    3. Call required functions
    4. Display results
    """
    conn = connect_to_db()
    conn.autocommit = True
    cursor = conn.cursor()
    total_rows = get_total_rows(cursor)

    # sel = [i * 0.02 for i in range(51)]
    params = []
    acl_sel = []

    csv_path = "../partA/output.csv"
    with open(csv_path, newline="") as file:
        reader = csv.DictReader(file)
        for row in reader:
            params.append(float(row["quantity"]))
            acl_sel.append(float(row["actual_selectivity"]))

    # cursor.execute(f"SELECT MIN({l_quantity}), MAX({l_quantity}) FROM lineitem")
    # min_val, max_val = cursor.fetchone()
    # min_val = float(min_val)
    # max_val = float(max_val)
    # for s in sel:
        # p = (max_val - min_val) * s + min_val
        # p = get_quantity_for_selectivity(min_val, max_val, cursor, s, total_rows)
        # params.append(p)
        # acl_sel.append(verify_selectivity(cursor, p, total_rows))

    dura_no_index = []
    dura_index = []
    dura_index_no_seq = []
    dura_clus = []
    dura_index_col = []

    cursor.execute("SET enable_seqscan = ON")
    cursor.execute("SET enable_indexscan = OFF")
    cursor.execute("SET enable_bitmapscan = OFF")

    for p in params:
        start = time.perf_counter()
        cursor.execute("SELECT COUNT(*) FROM lineitem WHERE l_quantity <= %s ", (p,))
        # cursor.fetchall()
        cursor.fetchone()
        end = time.perf_counter()
        dura_no_index.append((end - start) * 1000)

    cursor.execute("CREATE INDEX IF NOT EXISTS idx_l_quantity ON lineitem(l_quantity)")

    cursor.execute("SET enable_seqscan = ON")
    cursor.execute("SET enable_indexscan = ON")
    cursor.execute("SET enable_bitmapscan = ON")

    for p in params:
        start = time.perf_counter()
        cursor.execute("SELECT COUNT(*) FROM lineitem WHERE l_quantity <= %s ", (p,))
        # cursor.fetchall()
        cursor.fetchone()
        end = time.perf_counter()
        dura_index.append((end - start) * 1000)
    

    cursor.execute("SET enable_seqscan = OFF")
    cursor.execute("SET enable_indexscan = ON")
    cursor.execute("SET enable_bitmapscan = ON")

    for p in params:
        start = time.perf_counter()
        cursor.execute("SELECT COUNT(*) FROM lineitem WHERE l_quantity <= %s ", (p,))
        # cursor.fetchall()
        cursor.fetchone()
        end = time.perf_counter()
        dura_index_no_seq.append((end - start) * 1000)
    
    cursor.execute("CLUSTER lineitem USING idx_l_quantity")
    cursor.execute("ANALYZE lineitem")
    # conn.commit()

    cursor.execute("SET enable_seqscan = ON")
    cursor.execute("SET enable_indexscan = ON")
    cursor.execute("SET enable_bitmapscan = ON")

    for p in params:
        start = time.perf_counter()
        cursor.execute(f"SELECT COUNT(*) FROM lineitem WHERE {l_quantity} <= %s ", (p,))
        # cursor.fetchall()
        cursor.fetchone()
        end = time.perf_counter()
        dura_clus.append((end - start) * 1000)
    
    
    cursor.execute("SET enable_seqscan = ON")
    cursor.execute("SET enable_indexscan = ON")
    cursor.execute("SET enable_bitmapscan = ON")

    for p in params:
        start = time.perf_counter()
        cursor.execute("SELECT COUNT(l_quantity) FROM lineitem WHERE l_quantity <= %s ", (p,))
        # cursor.fetchall()
        cursor.fetchone()
        end = time.perf_counter()
        dura_index_col.append((end - start) * 1000)

    plt.figure(figsize=(8, 6))

    combined = list(zip(acl_sel, dura_no_index, dura_index, dura_index_no_seq, dura_clus, dura_index_col))
    combined.sort(key=lambda x: x[0])
    acl_sel, dura_no_index, dura_index, dura_index_no_seq, dura_clus, dura_index_col = zip(*combined)

    plt.plot(acl_sel, dura_no_index, label="No Index", marker = 'o')
    plt.plot(acl_sel, dura_index, label="Index on l_quantity", marker = 'o')
    plt.plot(acl_sel, dura_index_no_seq, label="Index (Seq Scan OFF)", marker = 'o')
    plt.plot(acl_sel, dura_clus, label="Clustered Index", marker = 'o')
    plt.plot(acl_sel, dura_index_col, label="Index and column only Scan", marker = 'o')

    plt.xlabel("Actual Selectivity")
    plt.ylabel("Execution Time (ms)")
    plt.title("Range Query Performance vs Selectivity")
    plt.legend()
    plt.grid(True)

    plt.savefig("performance_plot.png")
    plt.show()

    cursor.close()
    conn.close()


if __name__ == "__main__":
    main()