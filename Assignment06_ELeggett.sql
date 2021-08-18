--*************************************************************************--
-- Title: Assignment06
-- Author: Erin Leggett
-- Desc: This file demonstrates how to use Views
-- Change Log: 2021-08-17,Created views and validated results
-- 2021-08-15,ELeggett,Created file
--**************************************************************************--

Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_ErinLeggett')
	 Begin 
	  Alter Database [Assignment06DB_ErinLeggett] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_ErinLeggett;
	 End
	Create Database Assignment06DB_ErinLeggett;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_ErinLeggett;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
-- Select * From Categories;
-- go
-- Select * From Products;
-- go
-- Select * From Employees;
-- go
-- Select * From Inventories;
-- go

/********************************* Questions and Answers *********************************/
--NOTES------------------------------------------------------------------------------------ 
-- 1) You can use any name you like for you views, but be descriptive and consistent
-- 2) You can use your working code from assignment 5 for much of this assignment
-- 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

--Step 1: Draft SELECT statements to list out each column from each table in the database.
-- SELECT CategoryID
-- 	,CategoryName
-- 	FROM dbo.Categories
-- ;
-- GO

-- SELECT ProductID
-- 	,ProductName
-- 	,CategoryID
-- 	,UnitPrice
-- 	FROM dbo.Products
-- ;
-- GO

-- SELECT EmployeeID
-- 	,EmployeeFirstName
-- 	,EmployeeLastName
-- 	,ManagerID
-- 	FROM dbo.Employees
-- ;
-- GO

-- SELECT InventoryID
-- 	,InventoryDate
-- 	,EmployeeID
-- 	,ProductID
-- 	,Count
-- 	FROM dbo.Inventories
-- ;
-- GO

--Step 2: Use SELECT statements to create views using WITH SCHEMABINDING.
CREATE VIEW vCategories 
	WITH SCHEMABINDING
	AS
		SELECT CategoryID
			,CategoryName
		FROM dbo.Categories
;
GO

CREATE VIEW vProducts 
	WITH SCHEMABINDING
	AS
		SELECT ProductID
		,ProductName
		,CategoryID
		,UnitPrice
		FROM dbo.Products
;
GO

CREATE VIEW vEmployees 
	WITH SCHEMABINDING
	AS
		SELECT EmployeeID
		,EmployeeFirstName
		,EmployeeLastName
		,ManagerID
		FROM dbo.Employees
;
GO

CREATE VIEW vInventories
	WITH SCHEMABINDING
	AS
		SELECT InventoryID
		,InventoryDate
		,EmployeeID
		,ProductID
		,Count
		FROM dbo.Inventories
;
GO

--Step 3: Verify results of newly-created BASIC table views.
-- SELECT * 
-- FROM vCategories
-- ;
-- GO

-- SELECT * 
-- FROM vProducts
-- ;
-- GO

-- SELECT * 
-- FROM vEmployees
-- ;
-- GO

-- SELECT * 
-- FROM vInventories
-- ;
-- GO

-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

--Step 1: Deny SELECT permissions to Public for each table in the database.
DENY 
	SELECT
	ON dbo.Categories
	TO Public
;
GO

DENY 
	SELECT
	ON dbo.Products
	TO Public
;
GO

DENY 
	SELECT
	ON dbo.Inventories
	TO Public
;
GO

DENY 
	SELECT
	ON dbo.Employees
	TO Public
;
GO

--Step 2: Grant SELECT permissions to Public group for the BASIC views created in Question 1.
GRANT
	SELECT
	ON vCategories
	TO Public
;
GO

GRANT
	SELECT
	ON vProducts
	TO Public
;
GO

GRANT
	SELECT
	ON vInventories
	TO Public
;
GO

GRANT
	SELECT
	ON vEmployees
	TO Public
;
GO

-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

--Step 1: Use SELECT statements to preview data and identify common data points.
-- SELECT *
-- FROM vCategories
-- ;
-- GO

-- SELECT *
-- FROM vProducts
-- ;
-- GO

--Step 2: Join views by CategoryID using a JOIN clause.
-- SELECT * 
-- FROM vCategories
-- JOIN vProducts
-- 	ON vProducts.CategoryID=vCategories.CategoryID
-- ;
-- GO

--Step 3: Eliminate duplicate and unnecessary data removing * and adding column names.
-- SELECT CategoryName
-- 	,ProductName
-- 	,UnitPrice
-- FROM vCategories
-- JOIN vProducts
-- 	ON vProducts.CategoryID=vCategories.CategoryID
-- ;
-- GO

--Step 4: Create a new view to display the results of the previous query.
CREATE VIEW vProductsbyCategories
	AS
		SELECT CategoryName
			,ProductName
			,UnitPrice
		FROM vCategories
		JOIN vProducts
			ON vProducts.CategoryID=vCategories.CategoryID
;
GO

-- Step 5: Alter view to order its results by category and product.
ALTER VIEW vProductsbyCategories
	AS
		SELECT TOP 10000
			CategoryName
			,ProductName
			,UnitPrice
		FROM vCategories
		JOIN vProducts
			ON vProducts.CategoryID=vCategories.CategoryID
		ORDER BY 
			CategoryName
			,ProductName ASC
;
GO

--Step 6: Validate results of the newly-created vProductbyCategories view.
-- SELECT * 
-- FROM vProductsbyCategories
-- ;
-- GO

-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count

--Step 1: Use SELECT statements to preview data and identify common data points.
-- SELECT *
-- FROM vProducts
-- ;
-- GO

-- SELECT *
-- FROM vInventories
-- ;
-- GO

--Step 2: Join views by ProductID using a JOIN clause.
-- SELECT *
-- FROM vProducts
-- JOIN vInventories
--     ON vProducts.ProductID=vInventories.ProductID
-- ;
-- GO

--Step 3: Eliminate duplicate and unnecessary data by removing * and inserting column names.
-- SELECT ProductName
--     ,InventoryDate
--     ,Count
-- FROM vProducts
-- JOIN vInventories
--     ON vProducts.ProductID=vInventories.ProductID
-- ;
-- GO

--Step 4: Create a new view to display the results of the previous query.
CREATE VIEW vInventoriesByProductsByDates
	AS	
		SELECT ProductName
			,InventoryDate
			,Count
		FROM vProducts
		JOIN vInventories
			ON vProducts.ProductID=vInventories.ProductID
;
GO

-- Step 5: Alter view to order results by product, inventory date, and count.
ALTER VIEW vInventoriesByProductsByDates
	AS	
		SELECT TOP 10000
			ProductName
			,InventoryDate
			,Count
		FROM vProducts
		JOIN vInventories
			ON vProducts.ProductID=vInventories.ProductID
		ORDER BY 
			ProductName
			,InventoryDate
			,Count
;
GO

--Step 6: Validate return of newly-created vInventoriesByProductsByDates view using SELECT statement.
-- SELECT * 
-- FROM vInventoriesByProductsByDates
-- ;
-- GO

-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

--Step 1: Use SELECT statements to preview data and identify common data points.
-- SELECT *
-- FROM vInventories
-- ;
-- GO

-- SELECT *
-- FROM vEmployees
-- ;
-- GO

--Step 2: Join views by EmployeeID using a JOIN clause.
-- SELECT *
-- FROM vEmployees
-- JOIN vInventories
--     ON vEmployees.EmployeeID=vInventories.EmployeeID
-- ;
-- GO

--Step 3: Eliminate duplicate and unnecessary data by removing * and inserting column names.
-- SELECT InventoryDate
--     ,EmployeeFirstName
--     ,EmployeeLastName
-- FROM vInventories
-- JOIN vEmployees
--     ON vInventories.EmployeeID=vEmployees.EmployeeID
-- ;
-- GO

--Step 4: Eliminate duplicate rows by selecting only distinct inventory dates using a DISTINCT clause.
-- SELECT
--     DISTINCT(InventoryDate)
--     ,EmployeeFirstName
--     ,EmployeeLastName
-- FROM vInventories
-- JOIN vEmployees
--     ON vInventories.EmployeeID=vEmployees.EmployeeID
-- ;
-- GO

--Step 5: Consolidate employee names by combining EmployeeFirstName and EmployeeLastName columns into one 
--EmployeeName column.
-- SELECT 
--     DISTINCT(InventoryDate)
--     ,EmployeeFirstName+' '+EmployeeLastName AS EmployeeName
-- FROM vInventories
-- JOIN vEmployees
--     ON vInventories.EmployeeID=vEmployees.EmployeeID
-- ;
-- GO

--Step 6: Create a new view to display the results of the previous query.
CREATE VIEW vInventoriesByEmployeesByDates
	AS
		SELECT
			DISTINCT(InventoryDate)
			,EmployeeFirstName+' '+EmployeeLastName AS EmployeeName
		FROM vInventories
		JOIN vEmployees
			ON vInventories.EmployeeID=vEmployees.EmployeeID
;
GO

-- Step 7: Alter view to order results by inventory date.
ALTER VIEW vInventoriesByEmployeesByDates
	AS
		SELECT DISTINCT TOP 10000
			InventoryDate
			,EmployeeFirstName+' '+EmployeeLastName AS EmployeeName
		FROM vInventories
		JOIN vEmployees
			ON vInventories.EmployeeID=vEmployees.EmployeeID
		ORDER BY InventoryDate ASC
;
GO

--Step 8: Validate results of newly-created vInventoriesByEmployeesByDates view using a SELECT statement.
-- SELECT * 
-- FROM vInventoriesByEmployeesByDates
-- ;
-- GO

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

--Step 1: Use SELECT statements to preview data and identify common data points.
-- SELECT *
-- FROM vCategories
-- ;
-- GO

-- SELECT *
-- FROM vProducts
-- ;
-- GO

-- SELECT *
-- FROM vInventories
-- ;
-- GO

--Step 2: Join views by ProductID and CategoryID using a JOIN clause.
-- SELECT *
-- FROM vInventories
-- JOIN vProducts
--     ON vProducts.ProductID=vInventories.ProductID
-- JOIN vCategories
--     ON vCategories.CategoryID=vProducts.CategoryID
-- ;
-- GO

--Step 3: Eliminate duplicate and unnecessary data by removing * and inserting column names.
-- SELECT CategoryName
--     ,ProductName
--     ,InventoryDate
--     ,Count
-- FROM vInventories
-- JOIN vProducts
--     ON vProducts.ProductID=vInventories.ProductID
-- JOIN vCategories
--     ON vCategories.CategoryID=vProducts.CategoryID
-- ;
-- GO

--Step 4: Create a new view to display the results of the previous query.
CREATE VIEW vInventoriesByProductsByCategories
	AS
		SELECT CategoryName
			,ProductName
			,InventoryDate
			,Count
		FROM vInventories
		JOIN vProducts
			ON vProducts.ProductID=vInventories.ProductID
		JOIN vCategories
			ON vCategories.CategoryID=vProducts.CategoryID
;
GO

-- Step 5: Alter view to order results by category, product, date, and count.
ALTER VIEW vInventoriesByProductsByCategories
	AS
		SELECT TOP 10000
			CategoryName
			,ProductName
			,InventoryDate
			,Count
		FROM vInventories
		JOIN vProducts
			ON vProducts.ProductID=vInventories.ProductID
		JOIN vCategories
			ON vCategories.CategoryID=vProducts.CategoryID
		ORDER BY
			CategoryName
			,ProductName
			,InventoryDate
			,Count ASC
;
GO

--Step 6: Validate results of newly-created vInventoriesByProductsByCategories view using a SELECT statement.
-- SELECT * 
-- FROM vInventoriesByProductsByCategories
-- ;
-- GO

-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

--Step 1: Use SELECT statements to preview data and identify common data points.
-- SELECT *
-- FROM vCategories
-- ;
-- GO

-- SELECT *
-- FROM vProducts
-- ;
-- GO

-- SELECT *
-- FROM vInventories
-- ;
-- GO

-- SELECT *
-- FROM vEmployees
-- ;
-- GO

--Step 2: Join tables by CategoryID, ProductID, and EmployeeID using a JOIN clause.
-- SELECT *
-- FROM vInventories
-- JOIN vProducts
--     ON vProducts.ProductID=vInventories.ProductID
-- JOIN vCategories
--     ON vCategories.CategoryID=vProducts.CategoryID
-- JOIN vEmployees
--     ON vInventories.EmployeeID=vEmployees.EmployeeID
-- ;
-- GO

--Step 3: Eliminate duplicate and unnecessary data by removing * and inserting column names.
-- SELECT CategoryName
--     ,ProductName
--     ,InventoryDate
--     ,Count
--     ,EmployeeFirstName
--     ,EmployeeLastName
-- FROM vInventories
-- JOIN vProducts
--     ON vProducts.ProductID=vInventories.ProductID
-- JOIN vCategories
--     ON vCategories.CategoryID=vProducts.CategoryID
-- JOIN vEmployees
--     ON vInventories.EmployeeID=vEmployees.EmployeeID
-- ;
-- GO

--Step 4: Consolidate employee names by combining EmployeeFirstName and EmployeeLastName columns into one 
--EmployeeName column.
-- SELECT CategoryName
--     ,ProductName
--     ,InventoryDate
--     ,Count
--     ,EmployeeFirstName+' '+EmployeeLastName AS EmployeeName
-- FROM vInventories
-- JOIN vProducts
--     ON vProducts.ProductID=vInventories.ProductID
-- JOIN vCategories
--     ON vCategories.CategoryID=vProducts.CategoryID
-- JOIN vEmployees
--     ON vInventories.EmployeeID=vEmployees.EmployeeID
-- ;
-- GO

--Step 4: Create a new view to display the results of the previous query.
CREATE VIEW vInventoriesByProductsByEmployees
	AS
		SELECT CategoryName
			,ProductName
			,InventoryDate
			,Count
			,EmployeeFirstName+' '+EmployeeLastName AS EmployeeName
		FROM vInventories
		JOIN vProducts
			ON vProducts.ProductID=vInventories.ProductID
		JOIN vCategories
			ON vCategories.CategoryID=vProducts.CategoryID
		JOIN vEmployees
			ON vInventories.EmployeeID=vEmployees.EmployeeID
;
GO

-- Step 5: Alter view to order results by inventory date, category, product, and employee.
ALTER VIEW vInventoriesByProductsByEmployees
	AS
		SELECT TOP 10000
			CategoryName
			,ProductName
			,InventoryDate
			,Count
			,EmployeeFirstName+' '+EmployeeLastName AS EmployeeName
		FROM vInventories
		JOIN vProducts
			ON vProducts.ProductID=vInventories.ProductID
		JOIN vCategories
			ON vCategories.CategoryID=vProducts.CategoryID
		JOIN vEmployees
			ON vInventories.EmployeeID=vEmployees.EmployeeID
		ORDER BY
			InventoryDate
			,CategoryName
			,ProductName
			,EmployeeName
;
GO

--Step 6: Validate results of newly-created vInventoriesByProductsByEmployees view using a SELECT statement.
-- SELECT * 
-- FROM vInventoriesByProductsByEmployees
-- ;
-- GO

-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

--Step 1: Use SELECT statements to preview data and identify common data points.
-- SELECT *
-- FROM vCategories
-- ;
-- GO

-- SELECT *
-- FROM vProducts
-- ;
-- GO

-- SELECT *
-- FROM vInventories
-- ;
-- GO

-- SELECT *
-- FROM vEmployees
-- ;
-- GO

--Step 2: Join views by CategoryID, ProductID, and EmployeeID using a JOIN clause.
-- SELECT *
-- FROM vInventories
-- JOIN vProducts
--     ON vProducts.ProductID=vInventories.ProductID
-- JOIN vCategories
--     ON vCategories.CategoryID=vProducts.CategoryID
-- JOIN vEmployees
--     ON vInventories.EmployeeID=vEmployees.EmployeeID
-- ;
-- GO

--Step 3: Eliminate duplicate and unnecessary data by removing * and inserting column names.
-- SELECT
--     CategoryName
--     ,ProductName
--     ,InventoryDate
--     ,Count
--     ,EmployeeFirstName
--     ,EmployeeLastName
-- FROM vInventories
-- JOIN vProducts
--     ON vProducts.ProductID=vInventories.ProductID 
-- JOIN vCategories
--     ON vCategories.CategoryID=vProducts.CategoryID
-- JOIN vEmployees
--     ON vInventories.EmployeeID=vEmployees.EmployeeID
-- ;
-- GO

--Step 4: Consolidate employee names by combining EmployeeFirstName and EmployeeLastName columns into one
--EmployeeName column.
-- SELECT
--     CategoryName
--     ,ProductName
--     ,InventoryDate
--     ,Count
--     ,EmployeeFirstName+' '+EmployeeLastName AS EmployeeName
-- FROM vInventories
-- JOIN vProducts
--     ON vProducts.ProductID=vInventories.ProductID 
-- JOIN vCategories
--     ON vCategories.CategoryID=vProducts.CategoryID
-- JOIN vEmployees
--     ON vInventories.EmployeeID=vEmployees.EmployeeID
-- ;
-- GO

--Step 5: Restrict results to display only the products Chai and Chang.
-- SELECT
--     CategoryName
--     ,ProductName
--     ,InventoryDate
--     ,Count
--     ,EmployeeFirstName+' '+EmployeeLastName AS EmployeeName
-- FROM vProducts
-- JOIN vInventories
--     ON vProducts.ProductID=vInventories.ProductID
--     AND vProducts.ProductID IN(
--         SELECT ProductID
-- 		FROM vProducts
-- 		WHERE ProductName
--         IN('Chai','Chang')
--     )
-- JOIN vCategories
--     ON vCategories.CategoryID=vProducts.CategoryID
-- JOIN vEmployees
--     ON vInventories.EmployeeID=vEmployees.EmployeeID
-- ;
-- GO

--Step 6: Create a new view to display the results of the previous query.
CREATE VIEW vInventoriesForChaiAndChangByEmployees
	AS
		SELECT
			CategoryName
			,ProductName
			,InventoryDate
			,Count
			,EmployeeFirstName+' '+EmployeeLastName AS EmployeeName
		FROM vProducts
		JOIN vInventories
			ON vProducts.ProductID=vInventories.ProductID
			AND vProducts.ProductID IN(
				SELECT ProductID
				FROM vProducts
				WHERE ProductName
				IN('Chai','Chang')
			)
		JOIN vCategories
			ON vCategories.CategoryID=vProducts.CategoryID
		JOIN vEmployees
			ON vInventories.EmployeeID=vEmployees.EmployeeID
;
GO

-- Step 7: Alter view to order results by inventory date, category, and product.
ALTER VIEW vInventoriesForChaiAndChangByEmployees
	AS
		SELECT TOP 10000
			CategoryName
			,ProductName
			,InventoryDate
			,Count
			,EmployeeFirstName+' '+EmployeeLastName AS EmployeeName
		FROM vProducts
		JOIN vInventories
			ON vProducts.ProductID=vInventories.ProductID
			AND vProducts.ProductID IN(
				SELECT ProductID
				FROM vProducts
				WHERE ProductName
				IN('Chai','Chang')
   			)
		JOIN vCategories
			ON vCategories.CategoryID=vProducts.CategoryID
		JOIN vEmployees
			ON vInventories.EmployeeID=vEmployees.EmployeeID
		ORDER BY
			InventoryDate
			,CategoryName
			,ProductName
;
GO

--Step 8: Validate results of newly-created vInventoriesForChaiAndChangByEmployees view using a SELECT statement.
-- SELECT *
-- FROM vInventoriesForChaiAndChangByEmployees
-- ;
-- GO

-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

--Step 1: Use SELECT statements to preview data and identify common data points.
-- SELECT *
-- FROM vEmployees
-- ;
-- GO

--Step 2: Self join view using the EmployeeID and ManagerID columns to populate supervisor (Sup) and employee (Emp)
-- details.
-- SELECT *
-- FROM vEmployees Sup
-- JOIN vEmployees Emp
--     ON Sup.EmployeeID=Emp.ManagerID
-- ;
-- GO

--Step 3: Eliminate duplicate and unnecessary data by removing * and inserting column names.
-- SELECT Emp.EmployeeFirstName
--     ,Emp.EmployeeLastName
--     ,Sup.EmployeeFirstName
--     ,Sup.EmployeeLastName
-- FROM vEmployees Sup
-- JOIN vEmployees Emp
--     ON Sup.EmployeeID=Emp.ManagerID
-- ;
-- GO

--Step 4: Consolidate employee names by combining EmployeeFirstName and EmployeeLastName columns from
--the Emp and Sup tables into distinct Employee and Manager columns.
-- SELECT Sup.EmployeeFirstName+' '+Sup.EmployeeLastName AS Manager
--     ,Emp.EmployeeFirstName+' '+Emp.EmployeeLastName AS Employee
-- FROM vEmployees Sup
-- JOIN vEmployees Emp
--     ON Sup.EmployeeID=Emp.ManagerID
-- ;
-- GO

--Step 5: Create a new view to display the results of the previous query.
CREATE VIEW vEmployeesByManager
	AS
		SELECT Sup.EmployeeFirstName+' '+Sup.EmployeeLastName AS Manager
			,Emp.EmployeeFirstName+' '+Emp.EmployeeLastName AS Employee
		FROM vEmployees Sup
		JOIN vEmployees Emp
			ON Sup.EmployeeID=Emp.ManagerID
;
GO

--Step 6: Alter view to order results by manager.
ALTER VIEW vEmployeesByManager
	AS
		SELECT TOP 10000
			Sup.EmployeeFirstName+' '+Sup.EmployeeLastName AS Manager
			,Emp.EmployeeFirstName+' '+Emp.EmployeeLastName AS Employee
		FROM vEmployees Sup
		JOIN vEmployees Emp
			ON Sup.EmployeeID=Emp.ManagerID
		ORDER BY
			Manager
			,Employee ASC
;
GO

--Step 7: Validate results of newly-created vEmployeesByManager view.
-- SELECT *
-- FROM vEmployeesByManager
-- ;
-- GO

-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views?

--Step 1: Use SELECT statements to preview data and identify common data points.
-- SELECT * 
-- FROM vCategories

-- SELECT * 
-- FROM vProducts

-- SELECT * 
-- FROM vInventories

-- SELECT * 
-- FROM vEmployees

--Step 2: Join views by CategoryID, ProductID, and EmployeeID.
SELECT *
FROM vCategories
JOIN vProducts
	ON vCategories.CategoryID=vProducts.CategoryID
JOIN vInventories
	ON vProducts.ProductID=vInventories.ProductID
JOIN vEmployees
	ON vInventories.EmployeeID=vEmployees.EmployeeID
;
GO

--Step 3: Eliminate duplicate columns by removing * and adding column names.
-- SELECT vCategories.CategoryID
-- 	,vCategories.CategoryName
-- 	,vProducts.ProductID
-- 	,vProducts.ProductName
-- 	,vProducts.UnitPrice
-- 	,vInventories.InventoryID
-- 	,vInventories.InventoryDate
-- 	,vInventories.Count
-- 	,vInventories.EmployeeID
-- 	,vEmployees.EmployeeFirstName
-- 	,vEmployees.EmployeeLastName
-- 	,vEmployees.ManagerID
-- FROM vCategories
-- JOIN vProducts
-- 	ON vCategories.CategoryID=vProducts.CategoryID
-- JOIN vInventories
-- 	ON vProducts.ProductID=vInventories.ProductID
-- JOIN vEmployees
-- 	ON vInventories.EmployeeID=vEmployees.EmployeeID
-- ;
-- GO

-- Step 4: Define Manager and Employee columns via self-join on the vEmployees view.
-- SELECT vCategories.CategoryID
-- 	,vCategories.CategoryName
-- 	,vProducts.ProductID
-- 	,vProducts.ProductName
-- 	,vProducts.UnitPrice
-- 	,vInventories.InventoryID
-- 	,vInventories.InventoryDate
-- 	,vInventories.Count
-- 	,Emp.EmployeeID
-- 	,Sup.EmployeeFirstName+' '+Sup.EmployeeLastName AS Manager
-- 	,Emp.EmployeeFirstName+' '+Emp.EmployeeLastName AS Employee
-- FROM vEmployees Sup
-- JOIN vEmployees Emp
-- 	ON Sup.EmployeeID=Emp.ManagerID
-- JOIN vInventories
-- 	ON vInventories.EmployeeID=Emp.EmployeeID
-- JOIN vProducts
-- 	ON vProducts.ProductID=vInventories.ProductID
-- JOIN vCategories
-- 	ON vCategories.CategoryID=vProducts.CategoryID	
-- ;
-- GO

--Step 4: Create a new view to display the results of the previous of query.
CREATE VIEW vInventoriesByProductsByCategoriesByEmployees
	AS
		SELECT vCategories.CategoryID
			,vCategories.CategoryName
			,vProducts.ProductID
			,vProducts.ProductName
			,vProducts.UnitPrice
			,vInventories.InventoryID
			,vInventories.InventoryDate
			,vInventories.Count
			,Emp.EmployeeID
			,Emp.EmployeeFirstName+' '+Emp.EmployeeLastName AS Employee
			,Sup.EmployeeFirstName+' '+Sup.EmployeeLastName AS Manager
		FROM vEmployees Sup
		JOIN vEmployees Emp
			ON Sup.EmployeeID=Emp.ManagerID
		JOIN vInventories
			ON vInventories.EmployeeID=Emp.EmployeeID
		JOIN vProducts
			ON vProducts.ProductID=vInventories.ProductID
		JOIN vCategories
			ON vCategories.CategoryID=vProducts.CategoryID
;
GO

-- Step 5: Alter view to order results by inventory date, category, and product.
ALTER VIEW vInventoriesByProductsByCategoriesByEmployees
	AS
		SELECT TOP 10000
			vCategories.CategoryID
			,vCategories.CategoryName
			,vProducts.ProductID
			,vProducts.ProductName
			,vProducts.UnitPrice
			,vInventories.InventoryID
			,vInventories.InventoryDate
			,vInventories.Count
			,Emp.EmployeeID
			,Emp.EmployeeFirstName+' '+Emp.EmployeeLastName AS Employee
			,Sup.EmployeeFirstName+' '+Sup.EmployeeLastName AS Manager
		FROM vEmployees Sup
		JOIN vEmployees Emp
			ON Sup.EmployeeID=Emp.ManagerID
		JOIN vInventories
			ON vInventories.EmployeeID=Emp.EmployeeID
		JOIN vProducts
			ON vProducts.ProductID=vInventories.ProductID
		JOIN vCategories
			ON vCategories.CategoryID=vProducts.CategoryID
		ORDER BY
			vCategories.CategoryName
			,vProducts.ProductName
			,vInventories.InventoryDate
			,vInventories.Count
;
GO

--Step 6: Validate results of newly-created vInventoriesByProductsByCategoriesByEmployees view
-- SELECT * 
-- FROM vInventoriesByProductsByCategoriesByEmployees
-- ;
-- GO

/***************************************************************************************/
--Test final views! ^___^
SELECT * FROM [dbo].[vCategories]
SELECT * FROM [dbo].[vProducts]
SELECT * FROM [dbo].[vInventories]
SELECT * FROM [dbo].[vEmployees]

SELECT * FROM [dbo].[vProductsByCategories]
SELECT * FROM [dbo].[vInventoriesByProductsByDates]
SELECT * FROM [dbo].[vInventoriesByEmployeesByDates]
SELECT * FROM [dbo].[vInventoriesByProductsByCategories]
SELECT * FROM [dbo].[vInventoriesByProductsByEmployees]
SELECT * FROM [dbo].[vInventoriesForChaiAndChangByEmployees]
SELECT * FROM [dbo].[vEmployeesByManager]
SELECT * FROM [dbo].[vInventoriesByProductsByCategoriesByEmployees]
/***************************************************************************************/