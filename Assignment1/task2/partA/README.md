## Task 2: Index Usage  
# Part A: Query Parameter Computation for Target Selectivity

### Objective
The objective of this task is to compute a query parameter value for a given column such that a range query achieves a specified target selectivity.

Selectivity is defined as the fraction of input rows that satisfy a given predicate condition. For example, a selectivity of 0.25 means that 25% of the total rows in the table satisfy the condition.

---

### Problem Statement
Given a column name (e.g., `l_quantity`) and a target selectivity (sel) value between 0 and 1, write a program that computes a value X such that the selectivity of the query: SELECT * FROM lineitem WHERE <column_name> <= X; is approximately same as the target selectivity specified in the input.

A tolerance of **± 1% * (selectivity)** with respect to the target selectivity is allowed. If the value we get even after the maximum number of iterations is not within this range, we treat it as the closest possible value and return it directly.

---

### Approach

1. **Initial Bounds**
   - We find out the minimum and maximum values of the data in the specified column using the query:
    SELECT MIN(column), MAX(column) FROM lineitem;

2. **Initial Estimate**
   - We estimate X based on the assumption that data approaches a uniform distribution when the dataset is large as:
   X ≈ min + selectivity × (max − min)

3. **Binary Search Refinement**
   - Since the number of rows returned by the COUNT(*) WHERE column <= X part of the query increases with X, we use binary search to refine the value of X.
   - In each iteration: SELECT COUNT(*) FROM lineitem WHERE column <= X; is executed to compute the actual selectivity.
   - The search continues until the actual selectivity is within ±0.01 * target_selectivity, or the maximum number of iterations of the for loop is reached. We set the maximum number of iterations manually.

4. **Verification**
   - We then verify the final value of `X` computed above by recomputing the actual selectivity using another `COUNT(*)` query. This is implemented in the function verify_selectivity(cursor, quantity_threshold, total_rows).

---

### Query Counting
The program maintains a global variable no_of_queries, which tracks the total number of SQL queries issued during execution, including minimum/maximum computation, row count queries, binary search iterations and the final verification query.

---

### Input Format
The program accepts command-line arguments as follows:
python3 task2A.py <column_name> <target_selectivity>
Example: python3 task2A.py l_quantity 0.25

---

### Output Format
The program prints the following three lines to the standard output:

QUERY_PARAMETER: <computed_value>
QUERIES_EXECUTED: <number_of_queries>
ACTUAL_SELECTIVITY: <actual_selectivity>

Example:
QUERY_PARAMETER: 13.0
QUERIES_EXECUTED: 5
ACTUAL_SELECTIVITY: 0.26

---

### Assumptions
- The lineitem table exists in the PostgreSQL database tpch_db.
- The specified column (taken as input) contains only numeric values.
- The data distribution does not change during execution.
- PostgreSQL is accessible using the credentials specified in the code.

---

### Files Included
- `task2A.py` – Python implementation for computing the query parameter
- `README.md` – Description of approach and usage

---

### Notes
- The program uses a tolerance of ±0.01 * selectivity (or the closest possible value) for selectivity as specified.
- The use of Binary search with time complexity O(log n) ensures efficiency and reduces the time taken for large datasets.
- The core logic and main functions used to compute query parameters are reused in Part B.
