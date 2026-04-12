## Task 2: Plan Switch Detection (Done on Krishnan's Laptop, Roll no: CS24BTECH11036)

### Objective
The objective of this task is to identify all Plan switches where the PostgreSQL optimizer changes it's execution plan strategy as the query parameter varies given a parametrized range query.

---

### Problem Statement
Implement an efficient algorithm to explore the parameter space to detect plan switches. Determine the valid parameter range for the query by examining the dataset. Perform this computation for all three assignment queries.

---

### Approach

1. **Task 1 functions**
   - The functions implemented in task 1 are rewritten here for comparing if 2 plans are equivalent or not.

2. **Get plan**
   - This is a helper function to fetch the execution plan for a specific date.

3. **Linear Search in Plan Switch**
   - We open the file output.txt in append mode to append the plan switch details for the each of the 3 queries separately.
   - We keep track of the old_date, old_plan and then perform a linear search to figure out when the current plan (from the binary search) differs from the original.
   - We use the if not compare_plans(plan_old, plan_current) to check if the plan differs or not. If the plan differs, then we append Plan Switch {switch_count}: {old_date} and {current_date}" to the output.txt file.

4. **Main**
   - We then call the plan_switch() function for each of the 3 queries separately and append the output into the file output.txt.

---

### Input Format
The program does not accept any input through the command-line arguments as the 3 queries are hardcoded.
We run it through the command line as: python3 task2.py

---

### Output Format
The program prints the following details to the file output.txt:

Query: <query_number>
Plan Switch i: <start_date_for_plan_switch_i> and <end_date_for_plan_switch_i>

Example:
Query 1:
Plan Switch 1: 1992-01-07 and 1992-01-08
Plan Switch 2: 1992-01-27 and 1992-01-28
Plan Switch 3: 1992-03-28 and 1992-03-29

Query 2:
Plan Switch 1: 1992-01-01 and 1992-01-02
Plan Switch 2: 1992-02-21 and 1992-02-22
... and so on till Query 3

---

### Assumptions
- PostgreSQL is accessible using the credentials specified in the code.
- The data distribution in the 3 tables of the tpch_db database in PostgreSQL does not change during execution.
- The Plan Comparator code from task1 works correct and is used to compare plans here.
- The lineitem, orders, customer table exists in the PostgreSQL database tpch_db.

---

### Files Included
- `task2.py` – Python implementation for detection plan switches
- `output.txt` - Lists all detected plan switches of each query.
- `analysis.pdf` - Containing details of the dates at which each plan switch occurs, the plan before and the plan after.
- `README.md` – Description of approach and usage

---

### Notes
- The use of Binary search with time complexity O(log n) ensures efficiency and reduces the time taken for large datasets.
- The core logic and main functions used to determine if 2 query plans are structurally identical in task1 are reused in task2.
