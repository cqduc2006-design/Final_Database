# SUPPLIERS
INSERT INTO Suppliers (SupplierName, Address, PhoneNumber) VALUES
('Supplier A', 'A City', '090000111'),
('Supplier B', 'B City', '090111222'),
('Supplier C', 'C City', '090222333'),
('Supplier D', 'D City', '090333444'),
('Supplier E', 'E City', '090444555'),
('Supplier F', 'F City', '090555666'),
('Supplier G', 'G City', '090666777'),
('Supplier H', 'H City', '090777888'),
('Supplier I', 'I City', '090888999'),
('Supplier J', 'J City', '090999000');


# MATERIALS
INSERT INTO Materials (MaterialName, Unit, UnitCost, StockQuantity, SupplierID) VALUES
('ABS Plastic', 'Kg', 55000, 0, 1),
('Aluminum Alloy Frame', 'Piece', 150000, 0, 2),
('Lithium Battery 5000mAh', 'Piece', 80000, 0, 3),
('PCB Board', 'Piece', 120000, 0, 4),
('Multi-core Processor Chip', 'Piece', 450000, 0, 5),
('LCD Display', 'Piece', 500000, 0, 6),
('OLED Display', 'Piece', 900000, 0, 7),
('E-ink Display', 'Piece', 600000, 0, 8),
('Speaker Driver', 'Set', 150000, 0, 9),
('VR Optical Lens', 'Set', 300000, 0, 10);

# PRODUCTS
INSERT INTO Products (ProductName, Description, UnitPrice, StockQuantity) VALUES
('Laptop', 'Gaming Laptop, Intel Core i7, RTX 3050 Ti', 25000000, 5000),
('Smartphone', 'Gaming Smartphone, Snapdragon 8 Gen 2, 128GB', 18000000, 5000),
('Tablet', '11 inch, 128GB', 12000000, 100000),
('Smartwatch', 'Smartwatch with phone features', 4500000, 5000),
('Smart Speaker', 'Speaker with voice assistant', 2500000, 5000),
('VR Headset', 'VR Headset supports every android phones', 8500000, 5000),
('Headphone', 'Headset with noise cancellation', 3500000, 5000),
('TV', 'Smart TV OLED 55 inch', 22000000, 5000),
('E-reader', 'E-reader with high-resolution display', 4000000, 5000),
('Computer monitor', 'Monitor 27 inch', 6500000, 5000);


# BILL OF MATERIALS
INSERT INTO Product_Materials (ProductID, MaterialID, Quantity) VALUES
(1, 1, 1.0), (1, 2, 1.0), (1, 3, 1.0), (1, 4, 1.0), (1, 5, 1.0),
(2, 1, 1.0), (2, 2, 1.0), (2, 3, 1.0), (2, 4, 1.0), (2, 6, 1.0),
(3, 1, 1.0), (3, 2, 1.0), (3, 3, 1.0), (3, 4, 1.0), (3, 5, 1.0),
(4, 1, 0.05), (4, 3, 0.5), (4, 4, 1.0), (4, 5, 1.0), (4, 7, 0.5),
(5, 1, 0.5), (5, 4, 1.0), (5, 5, 1.0), (5, 9, 2.0),
(6, 1, 0.3), (6, 3, 1.0), (6, 4, 1.0), (6, 5, 1.0), (6, 7, 1.0), (6, 10, 1.0),
(7, 1, 0.2), (7, 3, 0.5), (7, 4, 1.0), (7, 9, 2.0),
(8, 2, 2.0), (8, 4, 2.0), (8, 5, 1.0), (8, 7, 2.0), (8, 9, 4.0),
(9, 1, 0.2), (9, 3, 1.0), (9, 4, 1.0), (9, 5, 1.0), (9, 8, 1.0),
(10, 1, 0.5), (10, 4, 1.0), (10, 6, 1.0);


# PLANTS
INSERT INTO Plants (PlantName, Address) VALUES
('Plant AA', 'AA City'),
('Plant BB', 'BB City'),
('Plant CC', 'CC City'),
('Plant DD', 'DD City'),
('Plant EE', 'EE City'),
('Plant FF', 'FF City'),
('Plant GG', 'GG City'),
('Plant HH', 'HH City'),
('Plant II', 'II City'),
('Plant JJ', 'JJ City');


# MATERIALS_PURCHASE
INSERT INTO Materials_Purchase (SupplierID, MaterialID, Quantity, UnitPrice, PurchaseDate) VALUES
(1, 1, 5000, 55000, '2026-01-05'),
(2, 2, 5000, 150000, '2026-01-06'),
(3, 3, 5000, 80000, '2026-01-07'),
(4, 4, 5000, 120000, '2026-01-08'),
(5, 5, 5000, 450000, '2026-01-09'),
(6, 6, 5000, 500000, '2026-01-10'),
(7, 7, 5000, 900000, '2026-01-11'),
(8, 8, 5000, 600000, '2026-01-12'),
(9, 9, 5000, 150000, '2026-01-13'),
(10, 10, 5000, 300000, '2026-01-14');


# ORDERS
INSERT INTO Orders (ProductID, PlantID, Quantity, StartDate, Status) VALUES
(1, 1, 50, '2026-02-01', 'In Progress'),
(2, 2, 100, '2026-02-05', 'In Progress'),
(3, 3, 30, '2026-02-10', 'Completed'),
(4, 4, 200, '2026-02-15', 'Completed'),
(5, 5, 80, '2026-03-01', 'In Progress'),
(6, 6, 40, '2026-03-05', 'In Progress'),
(7, 7, 150, '2026-03-10', 'Completed'),
(8, 8, 20, '2026-03-15', 'In Progress'),
(9, 9, 60, '2026-04-01', 'In Progress'),
(10, 10, 10, '2026-04-05', 'In Progress');