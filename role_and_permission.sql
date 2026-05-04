USE final_project;

# CREATE ROLE
DROP ROLE IF EXISTS 'finance', 'production_manager', 'warehouse_staff';
CREATE ROLE 'finance', 'production_manager', 'warehouse_staff';

# FINANCE PERMISSIONS
GRANT SELECT ON final_project.* TO 'finance';


# PRODUCTION MANAGER PERMISSIONS

GRANT SELECT ON final_project.* TO 'production_manager';

GRANT INSERT, UPDATE ON final_project.Orders TO 'production_manager';

GRANT INSERT ON final_project.Materials_Purchase TO 'production_manager';

GRANT UPDATE (StockQuantity) ON final_project.Materials TO 'production_manager';


# WAREHOUSE STAFF
GRANT SELECT (MaterialID, MaterialName, Unit, StockQuantity, SupplierID) 
ON final_project.Materials TO 'warehouse_staff';

GRANT SELECT ON final_project.Products TO 'warehouse_staff';
GRANT SELECT ON final_project.Product_Materials TO 'warehouse_staff';
GRANT SELECT ON final_project.Orders TO 'warehouse_staff';
GRANT SELECT ON final_project.Plants TO 'warehouse_staff';

# CREATE USERS
DROP USER IF EXISTS 'finance'@'localhost', 'pro_manager'@'localhost', 'warehouse_staff'@'localhost';

CREATE USER 'finance'@'localhost' IDENTIFIED BY 'F@123';
CREATE USER 'pro_manager'@'localhost' IDENTIFIED BY 'P@123';
CREATE USER 'warehouse_staff'@'localhost' IDENTIFIED BY 'K@123';

GRANT 'finance' TO 'finance'@'localhost';
GRANT 'production_manager' TO 'pro_manager'@'localhost';
GRANT 'warehouse_staff' TO 'warehouse_staff'@'localhost';

SET DEFAULT ROLE ALL TO 
    'finance'@'localhost', 
    'pro_manager'@'localhost', 
    'warehouse_staff'@'localhost';