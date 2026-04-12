## Task 1: Plan Comparison (Done on Krishnan's Laptop, Roll no: CS24BTECH11036)

### Objective
The objective of this task is to write a function to determine if two given compile time Query Plans Pi and Pj are structurally identical or not.

Two Query Plans Pi and Pj are structurally identical if the operator algorithms and their sequence are identical and they differ in their parameter values (i and j) only.

---

### Problem Statement
Given a PostgreSQL compile time plan for a query instance as input, compute it's Physical Operator Tree for subsequent plan comparison.

Physical Operator Tree: The structure that discounts the query parameter values and other values such as the cost and cardinality estimates that are available in the query plans produced by PostgreSQL.

---

### Approach

1. **Connecting to the database**
   - We first connect to the PostgreSQL database tpch_db to access the relevant tables based on the query using the connect_to_db() function.
   - We use the try and except block which helps us debug. If for some reason we are not able to connect to the database, it gives us a proper error message making it easier to debug.

2. **Extracting the Physical Operator Tree**
   - We extract the Physical Operator Tree from the given query plan in .json format by defining a struct ans which stores each node and their respective children. 
   - The for key in part ensures only the necessary info from the .json data are appended to the struct ans for comparison of plans.
   - We then append the same info recursively to the children of each node by calling the function extract_physical_operator_tree(child) repeatedly.

3. **Compare plans**
   - We first check if the .json file structure is valid or not, else it might lead to errors and program crashes.
   - We first extract the physical operator trees from the plans .json files by calling the extract_physical_operator_tree(plan) function.
   - If the two structs match, then return true else false. Done directly by return tree1 == tree2

4. **Main function**
   - We first load the data in the json file and store them in the 2 dictionaries plan1, plan2.
   - We then call compare_plans(plan1, plan2) to determine if the 2 plans are equivalent or not.

5. **Verification**
   - We tested the above functions for various test cases and the program passed all of them.

---

### Input Format
The program takes no inputs from the command line, rather we must ensure two .json files named plan1.json and plan2.json exist in the same subfolder of the assignment as task1.py containing valid query plans for two different PostgreSQL queries.
The program can be run through the command-line as: python3 task1.py.

---

### Output Format
The program prints one of the following lines on the screen:
**YES: Both plans are structurally identical** if the plans are structurally identical OR
**NO: Plans are structurally different** if the plans are not structurally identical

---

### Assumptions
- PostgreSQL is accessible using the credentials specified in the code.
- The data distribution in the 3 tables of the tpch_db database in PostgreSQL does not change during execution.
- The lineitem, orders, customer table exists in the PostgreSQL database tpch_db.
- The files plan1.json, plan2.json are valid .json files. 
- The files plan1.json, plan2.json exist in the same subfolder of the assignment as task1.py.
- The content of the 2 files plan1.json and plan2.json does not change during execution.

---

### Files Included
- `plan1.json` - Input .json file 1 containing the PostgreSQL compile time query plan for the query Pi.
- `plan2.json` - Input .json file 2 containing the PostgreSQL compile time query plan for the query Pj.
- `task1.py` – Python implementation for determining if two PostgreSQL compile time query plans are equivalent or not.
- `README.md` – Description of approach and usage

---

### Notes
- The use of for key in clause ensures that only relevant fields of the query plan are compared increasing efficiency and reducing the time taken for large datasets.
- The core logic and main functions used to compute query parameters are reused in task2.

---