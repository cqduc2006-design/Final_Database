import os
import subprocess
from datetime import datetime

def backup_database(user, password, db_name="final_project"):
    backup_folder = "back_up"
    if not os.path.exists(backup_folder):
        os.makedirs(backup_folder)
        print(f"Folder created: {backup_folder}")

    current_date = datetime.now().strftime("%d_%m_%Y")
    filename = f"back_up_{current_date}.sql"
    filepath = os.path.join(backup_folder, filename)
    
    try:
        with open(filepath, 'w', encoding='utf-8') as output_file:
            subprocess.run(
                ["mysqldump", "-u", user, f"-p{password}", db_name],
                stdout=output_file,
                check=True
            )
        print(f"Backup completed successfully! File saved at: {filepath}")
        
    except subprocess.CalledProcessError as e:
        print(f"[!] Error occurred while executing mysqldump (Incorrect password or insufficient privileges): {e}")
        if os.path.exists(filepath):
            os.remove(filepath)
            
    except FileNotFoundError:
        print("[!] Command 'mysqldump' not found.")

if __name__ == "__main__":
    print("=== DATABASE BACKUP TOOL ===")
    db_user = input("Enter username (Recommended 'root'): ")
    db_password = input("Enter password: ")
    backup_database(db_user, db_password)