import psycopg2
import sys
# csv imported for creating a file output.csv which task2B.py uses to access the selectivity values.
import csv

# ------------------------------------------------------------
# Database Connection
# ------------------------------------------------------------

# For the binary search for loop, we define the max number of iterations we perform in it as 30.
no_of_iterations = 30
# To count the total no of sql queries used for calculating the value of X for a given value of selectivity.
no_of_queries = 0
# We accept the first input, the column name and store it in the variable l_quantity.
l_quantity = sys.argv[1]

# This piece of code connects to the database tpch_db, which contains the data present in the csv file.
def connect_to_db():
    """
    Establish connection to PostgreSQL database.
    """
    # We connect to the database tpch_db using appropriate credentials to access the data.
    # We use a try except to catch any errors in connection.
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

# This function returns the total number of rows in the lineitem table.
def get_total_rows(cursor):
    """
    TODO:
    Write a query to return total number of rows in lineitem table.
    """
    # SELECT COUNT(*) returns the number of rows present in the lineitem table.
    cursor.execute("SELECT COUNT(*) FROM lineitem")
    # We used an sql query, hence we increment the total no of queries by 1.
    global no_of_queries
    no_of_queries += 1
    # We return the result of the COUNT(*)
    return cursor.fetchone()[0]


# This function returns the value of X corresponding to the given value of selectivity.
def get_quantity_for_selectivity(cursor, selectivity):
    """
    TODO:
    Given a selectivity value (0–1), compute and return an l_quantity
    constant such that l_quantity <= constant achieves that selectivity.
    """
    # We find the min and max values in the table under the given column and approximate the X value based on that.
    global no_of_queries
    cursor.execute(f"SELECT MIN({l_quantity}), MAX({l_quantity}) FROM lineitem")
    no_of_queries += 1
    min, max = cursor.fetchone()
    min = float(min)
    max = float(max)
    # X ~ (max - min) * selecitivity + min by assuming data is pretty uniform across min to max which works if the dataset is
    # large enough just like this case.
    quan = (max - min) * selectivity + min
    # We need the total number of rows to update the value of actual_sel in the binary search.
    total_rows = get_total_rows(cursor)
    actual_sel = verify_selectivity(cursor, quan, total_rows)
    # If the value of selectivity we get is within +-1% error of the actual value, we return the value of X calculated.
    if(abs(actual_sel - selectivity) <= 0.01):
        return quan
    # Else, we do binary search using appropriate values of low and high.
    elif(actual_sel < selectivity):
        low = quan
        high = max
    else:
        low = min
        high = quan
    # In case we dont get anything within 1% of the target selectivity, we select the one with the closest value.
    # Error is the difference in value of actual_sel, selectivity which cannot be more than 1.
    best_error = 1.1
    # We perform binary search for n number of iterations, where n is hardcoded above.
    for _ in range(0, no_of_iterations):
        mid = (low + high)/2.0
        # Now estimate the selectivity using thw count query and increment the no of queries.
        cursor.execute("SELECT COUNT(*) FROM lineitem WHERE l_quantity <= %s",(mid,))
        no_of_queries += 1
        actual_sel = float(cursor.fetchone()[0])/total_rows
        # Recalculate error.
        error = abs(actual_sel - selectivity)

        # If we are able to reduce the error, then update the value of best error.
        if(error < best_error):
            best_error = error
            quan = mid
        # If the error is within 1% tolerance, then exit.
        if(error <= 0.01*selectivity):
            quan = mid
            break
        # Else update low, high to perform binary search repeatedly.
        if(actual_sel < selectivity):
            low = mid
        else:
            high = mid
        
    return quan


# This function returns the value of selectivity corresponding to the given value of X for verification.
def verify_selectivity(cursor, quantity_threshold, total_rows):
    """
    TODO:
    Verify the actual selectivity achieved by the computed threshold.
    """
    # We call the COUNT(*) query and increment the no of queries by 1.
    global no_of_queries
    no_of_queries += 1
    cursor.execute(f"SELECT COUNT(*) FROM lineitem WHERE {l_quantity} <= {quantity_threshold}")
    # We return the value of selectivity corresponding to the given value of X as COUNT(*)/total_rows.
    return cursor.fetchone()[0]/total_rows


# Main function which runs the code.
def main():
    """
    TODO:
    1. Connect to the database
    2. Read selectivity from user
    3. Call required functions
    4. Display results
    """
    # First we connect to the database and get the cursor that executes the queries on it.
    conn = connect_to_db()
    cursor = conn.cursor()
    # We calculate the total number of rows to be used by the verify selectivity function.
    total_rows = get_total_rows(cursor)
    # We accept the second input and store it as sel.
    sel = float(sys.argv[2])

    # If the value of sel is < 0 or > 1 - invalid, then we exit.
    if(sel > 1 or sel < 0):
        print("Enter a value for selectivity between 0 and 1, both inclusive")
        exit()
    # We store the value of X as quan.
    quan = get_quantity_for_selectivity(cursor, sel)

    # We print our values according to the output format of task2A.py.
    print(f"QUERY_PARAMETER: {quan:.1f}")
    print(f"QUERIES_EXECUTED: {no_of_queries}")
    print(f"ACTUAL_SELECTIVITY: {verify_selectivity(cursor, quan, total_rows):.4f}")

    # The code for generating a csv file output.csv, which contains the values of sel, actual_sel which task2B.py uses.
    # sel = [i * 0.02 for i in range(51)]
    # params = []
    # acl_sel = []

    # for s in sel:
    #     p = get_quantity_for_selectivity(cursor, s)
    #     params.append(p)
    #     acl_sel.append(verify_selectivity(cursor, p, total_rows))

    # with open("output.csv", mode="w", newline="") as file:
    #     writer = csv.writer(file)
    #     writer.writerow(["quantity", "actual_selectivity"])
    #     for p, a in zip(params, acl_sel):
    #         writer.writerow([p, a])
    
    # We end the program by closing the cursor and the connection.
    cursor.close()
    conn.close()

# We run the main() function by calling it here.
if __name__ == "__main__":
    main()