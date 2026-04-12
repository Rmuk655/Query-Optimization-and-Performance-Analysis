import psycopg2
import sys
import csv
import json

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
            password="postgres"
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
    
    for key in ["Relation Name", "Index Name", "Parent Relationship",  "Join Type", "Strategy", "Partial Mode", "Parallel Aware", "Operation"]:
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


if __name__ == "__main__":
    with open("plan1.json", "r") as f:
        plan1 = json.load(f)
    with open("plan2.json", "r") as f:
        plan2 = json.load(f)

    if compare_plans(plan1, plan2):
        print("YES: Both plans are structurally identical")
    else:
        print("NO: Plans are structurally different")
