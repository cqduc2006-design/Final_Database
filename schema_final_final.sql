CREATE SCHEMA IF NOT EXISTS final_project;

USE final_project;


# CREATE TABLE FOR DATABASE 

CREATE TABLE Suppliers (
    SupplierID INT AUTO_INCREMENT PRIMARY KEY,
    SupplierName VARCHAR(255) NOT NULL UNIQUE,
    Address VARCHAR(255) NOT NULL,
    PhoneNumber VARCHAR(20) NOT NULL
);

CREATE TABLE Materials (
    MaterialID INT AUTO_INCREMENT PRIMARY KEY,
    MaterialName VARCHAR(255) NOT NULL UNIQUE,
    Unit VARCHAR(50) NOT NULL,
    UnitCost DECIMAL(10, 2) NOT NULL CHECK (UnitCost >= 0),
    StockQuantity DECIMAL(10, 2) NOT NULL DEFAULT 0 CHECK (StockQuantity >= 0),
    SupplierID INT NOT NULL,
    FOREIGN KEY (SupplierID) REFERENCES Suppliers(SupplierID) 
        ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE Products (
    ProductID INT AUTO_INCREMENT PRIMARY KEY,
    ProductName VARCHAR(255) NOT NULL UNIQUE,
    Description TEXT, 
    UnitPrice DECIMAL(10, 2) NOT NULL CHECK (UnitPrice >= 0),
    StockQuantity INT NOT NULL DEFAULT 0 CHECK (StockQuantity >= 0)
);

CREATE TABLE Product_Materials (
    ProductID INT NOT NULL,
    MaterialID INT NOT NULL,
    Quantity DECIMAL(10, 2) NOT NULL CHECK (Quantity > 0), 
    PRIMARY KEY (ProductID, MaterialID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (MaterialID) REFERENCES Materials(MaterialID) 
        ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE Plants (
    PlantID INT AUTO_INCREMENT PRIMARY KEY,
    PlantName VARCHAR(255) NOT NULL UNIQUE,
    Address VARCHAR(255) NOT NULL
);

CREATE TABLE Orders (
    OrderID INT AUTO_INCREMENT PRIMARY KEY,
    ProductID INT NOT NULL,
    PlantID INT NOT NULL,
    Quantity INT NOT NULL CHECK (Quantity > 0),
    StartDate DATE NOT NULL,
    Status ENUM('In Progress', 'Completed') NOT NULL DEFAULT 'In Progress',
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (PlantID) REFERENCES Plants(PlantID) 
        ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE Materials_Purchase (
    MaterialsPurchaseID INT AUTO_INCREMENT PRIMARY KEY,
    SupplierID INT NOT NULL,
    MaterialID INT NOT NULL,
    Quantity DECIMAL(10, 2) NOT NULL CHECK (Quantity > 0),
    UnitPrice DECIMAL(10, 2) NOT NULL CHECK (UnitPrice >= 0),
    PurchaseDate DATE NOT NULL, 
    FOREIGN KEY (SupplierID) REFERENCES Suppliers(SupplierID) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (MaterialID) REFERENCES Materials(MaterialID) ON DELETE RESTRICT ON UPDATE CASCADE
);

# ADVANCED DATABASE OBJECTS

# TRIGGERS

DELIMITER //
CREATE TRIGGER After_MaterialPurchase_Insert
AFTER INSERT ON Materials_Purchase
FOR EACH ROW
BEGIN
    UPDATE Materials
    SET StockQuantity = StockQuantity + NEW.Quantity
    WHERE MaterialID = NEW.MaterialID;
END //
DELIMITER ;


DELIMITER //
CREATE TRIGGER AfterUpdateOrderStatus
AFTER UPDATE ON Orders
FOR EACH ROW
BEGIN
    IF NEW.Status = 'Completed' AND OLD.Status <> 'Completed' THEN
        UPDATE Products
        SET StockQuantity = StockQuantity + NEW.Quantity
        WHERE ProductID = NEW.ProductID;
    END IF;
END //
DELIMITER ;

# UDF

DELIMITER //
CREATE FUNCTION CalculateProductCost(p_ProductID INT) 
RETURNS DECIMAL(10,2)
READS SQL DATA
BEGIN
    DECLARE TotalCost DECIMAL(10,2);
    
    SELECT SUM(pm.Quantity * m.UnitCost) INTO TotalCost
    FROM Product_Materials pm
    JOIN Materials m ON pm.MaterialID = m.MaterialID
    WHERE pm.ProductID = p_ProductID;
    
    RETURN TotalCost;
END //
DELIMITER ;

# VIEWS

CREATE VIEW vw_ProductionStatus AS
SELECT 
    o.OrderID,
    p.ProductName,
    pl.PlantName,
    o.Quantity,
    p.UnitPrice AS SellingPrice,
    CalculateProductCost(p.ProductID) AS MaterialCostPerUnit,
    (p.UnitPrice - CalculateProductCost(p.ProductID)) * o.Quantity AS EstimatedProfit,
    o.Status,
    o.StartDate
FROM Orders o
JOIN Products p ON o.ProductID = p.ProductID
JOIN Plants pl ON o.PlantID = pl.PlantID;


CREATE VIEW vw_MaterialUsage AS
SELECT 
    o.OrderID,
    p.ProductName,
    m.MaterialName,
    (pm.Quantity * o.Quantity) AS TotalMaterialRequired,
    m.StockQuantity AS CurrentInventory,
    o.Status
FROM Orders o
JOIN Products p ON o.ProductID = p.ProductID
JOIN Product_Materials pm ON p.ProductID = pm.ProductID
JOIN Materials m ON pm.MaterialID = m.MaterialID;

CREATE VIEW vw_SupplierDeliveries AS
SELECT 
    mp.MaterialsPurchaseID,
    s.SupplierName,
    m.MaterialName,
    mp.Quantity,
    mp.UnitPrice,
    (mp.Quantity * mp.UnitPrice) AS TotalCost,
    mp.PurchaseDate
FROM Materials_Purchase mp
JOIN Suppliers s ON mp.SupplierID = s.SupplierID
JOIN Materials m ON mp.MaterialID = m.MaterialID;


# INDEXES
CREATE INDEX idx_order_date_status ON Orders(StartDate, Status);
CREATE INDEX idx_material_supplier ON Materials(MaterialName, SupplierID);
CREATE INDEX idx_bom_product ON Product_Materials(ProductID);




