import mysql.connector
from mysql.connector import Error
import os
import json
from dotenv import load_dotenv

load_dotenv()


db_creds_string = os.getenv("DB_CREDENTIALS", "{}")
DB_CREDENTIALS = json.loads(db_creds_string)

def get_db_connection(username, password):
    try:
        conn = mysql.connector.connect(
            host="localhost",
            user=username,
            password=password,
            database="final_project"
        )
        return conn
    except Error as e:
        print(f"\n[!] Can't connect to database: {e}")
        return None
    

def create_order(conn):
    cursor = conn.cursor()
    try:
        conn.start_transaction() 

        print("\n--- Create new order ---")
        product_id = int(input("Enter Product ID: "))
        plant_id = int(input("Enter Plant ID: "))
        quantity = int(input("Enter quantity to produce: "))
        start_date = input("Start date (YYYY-MM-DD) [Leave blank for today]: ")

        if not start_date:
            from datetime import date
            start_date = date.today().strftime('%Y-%m-%d')

        query_order = """
            INSERT INTO Orders (ProductID, PlantID, Quantity, StartDate, Status) 
            VALUES (%s, %s, %s, %s, 'In Progress')
        """
        cursor.execute(query_order, (product_id, plant_id, quantity, start_date))

        query_deduct = """
            UPDATE Materials m
            JOIN Product_Materials pm ON m.MaterialID = pm.MaterialID
            SET m.StockQuantity = m.StockQuantity - (pm.Quantity * %s)
            WHERE pm.ProductID = %s
        """
        cursor.execute(query_deduct, (quantity, product_id))

        conn.commit()
        print("[V] Order created successfully! Raw materials have been deducted.")

    except Error as e:
        conn.rollback() 
        if e.errno == 3819: 
            print("[!] Error: Not enough raw materials in inventory!")
        else:
            print(f"[!] Database Error: {e}")
    except Exception as e:
        print(f"[!] Error: {e}")
    finally:
        cursor.close()

def update_inventories(conn):
    cursor = conn.cursor()
    try:
        print("\n--- Update Order Status & Inventory ---")
        order_id = int(input("Enter Order ID to update: "))
        new_status = "Completed"

        query = "UPDATE Orders SET Status = %s WHERE OrderID = %s"
        cursor.execute(query, (new_status, order_id))
        conn.commit()
        
        print(f"[V] Order status updated successfully for order #{order_id} to '{new_status}'.")
        print("[i] Trigger has automatically added the quantity to the finished goods inventory (Products).")
    except Exception as e:
        print(f"[!] Error: {e}")
    finally:
        cursor.close()

def generate_report(conn):
    cursor = conn.cursor(dictionary=True)
    try:
        print("\n--- Generate Financial & Production Report ---")
        print("1. Production & Profitability report (Finance)")
        print("2. Current inventory report")
        sub_choice = input("Choose report type (1/2): ")

        if sub_choice == "1":
            period = input("View report for (Day/Week/Month)? ").lower()
            interval_map = {"day": 0, "week": 7, "month": 30}
            days = interval_map.get(period, 0)
            
            query = """
                SELECT 
                    ProductName, 
                    SUM(Quantity) as TotalQty, 
                    MaterialCostPerUnit as UnitCost, 
                    SUM(EstimatedProfit) as TotalProfit, 
                    Status
                FROM vw_ProductionStatus
                WHERE StartDate >= DATE_SUB(CURDATE(), INTERVAL %s DAY)
                GROUP BY ProductName, Status, MaterialCostPerUnit
            """
            cursor.execute(query, (days,))
            results = cursor.fetchall()
            
            print(f"\n>> Production & Profit Report for {period.upper()}:")
            print(f"{'Product':<15} | {'Qty':<5} | {'Unit Cost':<12} | {'Total Profit':<15} | {'Status'}")
            print("-" * 70)
            
            for row in results:
                print(f"{row['ProductName']:<15} | "
                      f"{row['TotalQty']:<5} | "
                      f"{row['UnitCost']:>12,.0f} | "
                      f"{row['TotalProfit']:>15,.0f} | "
                      f"{row['Status']}")

        elif sub_choice == "2":
            print("\n>> Current Inventory Report (PRODUCTS):")
            cursor.execute("SELECT ProductName, StockQuantity FROM Products")
            for p in cursor.fetchall():
                print(f"- {p['ProductName']}: {p['StockQuantity']}")

            print("\n>> Current Inventory Report (MATERIALS):")
            cursor.execute("SELECT MaterialName, StockQuantity, Unit FROM Materials")
            for m in cursor.fetchall():
                print(f"- {m['MaterialName']}: {m['StockQuantity']} {m['Unit']}")
                
    except Exception as e:
        print(f"[!] Error generating report: {e}")
    finally:
        cursor.close()


def view_warehouse_inventory(conn):
    cursor = conn.cursor(dictionary=True)
    try:
        print("\n--- INVENTORY ---")
        
        print("\n>> PRODUCTS:")
        cursor.execute("SELECT ProductID, ProductName, StockQuantity FROM Products")
        products = cursor.fetchall()
        print(f"{'ID':<5} | {'Product':<20} | {'Stock':<10}")
        print("-" * 40)
        for p in products:
            print(f"{p['ProductID']:<5} | {p['ProductName']:<20} | {p['StockQuantity']:<10}")

        print("\n>> MATERIALS:")
        cursor.execute("SELECT MaterialID, MaterialName, StockQuantity, Unit FROM Materials")
        materials = cursor.fetchall()
        print(f"{'ID':<5} | {'Material':<25} | {'Stock':<10} | {'Unit':<10}")
        print("-" * 55)
        for m in materials:
            print(f"{m['MaterialID']:<5} | {m['MaterialName']:<25} | {m['StockQuantity']:<10} | {m['Unit']:<10}")

    except Error as e:
        if e.errno == 1142:
             print("[!] Permission denied.")
        else:
             print(f"[!] Database Error: {e}")
    except Exception as e:
        print(f"[!] Error: {e}")
    finally:
        cursor.close()

def main():
    print("=== Production Management System ===")
    user = input("Username: ")
    password = input("Password: ")
    
    connection = get_db_connection(user, password)
    
    if connection:
        print(f"\n[+] Login successful with role: {user}")
        
        while True:
            print(f"\n--- {user.upper()} DASHBOARD ---")
            
            if user == "pro_manager":
                print("1. Create New Production Order")
                print("2. Update Order Status")
                print("q. Logout")
                choice = input("Select action: ")
                
                if choice == "1":
                    create_order(connection)
                elif choice == "2":
                    update_inventories(connection)
                elif choice == "q":
                    break

            elif user == "warehouse_staff":
                print("1. View Current Inventory")
                print("q. Logout")
                choice = input("Select action: ")
                
                if choice == "1":
                    view_warehouse_inventory(connection)        
                elif choice == "q":
                    break


            elif user == "finance":
                print("1. Generate Profitability or Inventory Report")
                print("q. Logout")
                choice = input("Select action: ")
                
                if choice == "1":
                    generate_report(connection)
                elif choice == "q":
                    break
            
            else:
                print("[!] Role not recognized or permissions not set.")
                break

        connection.close()
        print("\n[i] Connection closed. Goodbye!")
    else:
        print("\n[!] Login failed. Please check your account's info.")


if __name__ == "__main__":
    main()