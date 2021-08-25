--*************************************************************************--
-- Title: Assignment07
-- Author: JPrice
-- Desc: This file demonstrates how to use Functions
-- Change Log: When,Who,What
-- 2017-01-01,JPrice,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment07DB_JPrice')
	 Begin 
	  Alter Database [Assignment07DB_JPrice] set Single_user With Rollback Immediate;
	  Drop Database Assignment07DB_JPrice;
	 End
	Create Database Assignment07DB_JPrice;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment07DB_JPrice;

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
,[UnitPrice] [money] NOT NULL
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
,[EmployeeID] [int] NOT NULL
,[ProductID] [int] NOT NULL
,[ReorderLevel] int NOT NULL -- New Column 
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
(InventoryDate, EmployeeID, ProductID, ReorderLevel, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, ReorderLevel, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, ReorderLevel, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, ReorderLevel, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Order By 1, 2
go

-- Adding Views (Module 06) -- 
Create View vCategories With SchemaBinding
 AS
  Select CategoryID, CategoryName From dbo.Categories;
go
Create View vProducts With SchemaBinding
 AS
  Select ProductID, ProductName, CategoryID, UnitPrice From dbo.Products;
go
Create View vEmployees With SchemaBinding
 AS
  Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID From dbo.Employees;
go
Create View vInventories With SchemaBinding 
 AS
  Select InventoryID, InventoryDate, EmployeeID, ProductID, ReorderLevel, [Count] From dbo.Inventories;
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From vCategories;
go
Select * From vProducts;
go
Select * From vEmployees;
go
Select * From vInventories;
go

/********************************* Questions and Answers *********************************/
/* NOTES------------------------------------------------------------------------------------ 
 1) You must use the BASIC views for each table.
 2) Remember that Inventory Counts are Randomly Generated. So, your counts may not match mine
 3) To make sure the Dates are sorted correctly, you can use Functions in the Order By clause!*/
------------------------------------------------------------------------------------------'


-- Question 1 (5% of pts): What built-in SQL Server function can you use to show a list 
-- of Product names, and the price of each product, with the price formatted as US dollars?
-- Order the result by the product!

/*selecting columns */

--Select 
--	 ProductName
--	,UnitPrice
--	From vProducts;
--go

/* using cast to append US dollar sign to unitprice */

--Select ProductName
--	,'$' + CAST(UnitPrice as varchar(15)) UnitPrice
--	From vProducts;
--go

/* ordering data ---
FINAL ANSWER	*/

Select ProductName
	,'$' + CAST(UnitPrice as varchar(15)) UnitPrice
	From vProducts
	Order by ProductName;
go

-- Question 2 (10% of pts): What built-in SQL Server function can you use to show a list 
-- of Category and Product names, and the price of each product, 
-- with the price formatted as US dollars?
-- Order the result by the Category and Product!

/* selecting data */
--Select C.CategoryName, P.ProductName, P.UnitPrice
--	From vProducts as P Join vCategories as C
--	On C.CategoryID = P.CategoryID;
--go

/* appending USD sign, using a different function than in Q1 */
--Select C.CategoryName, P.ProductName, '$' + Convert(nvarchar(10),P.UnitPrice) UnitPrice
--	From vProducts as P Join vCategories as C
--	On C.CategoryID = P.CategoryID;
--go

/* ordering By Cat, Prod
	Final answer	*/

Select C.CategoryName, P.ProductName, '$' + Convert(nvarchar(10),P.UnitPrice) UnitPrice
	From vProducts as P Join vCategories as C
	On C.CategoryID = P.CategoryID
	Order by CategoryName, ProductName;
go

-- Question 3 (10% of pts): What built-in SQL Server function can you use to show a list 
-- of Product names, each Inventory Date, and the Inventory Count,
-- with the date formatted like "January, 2017?" 
-- Order the results by the Product, Date, and Count!

/*	Selecting data	*/
--Select P.ProductName, I.InventoryDate, I.Count
--	From vProducts as P Join vInventories as I
--	On P.ProductID = I.ProductID;
--go

/*	formatting dates	*/
--Select Datename(mm, InventoryDate) + ', ' + Datename(yy, InventoryDate) InventoryDate
--	From vInventories;
--go

/* combining and ordering	
-- note: ordering has to mention I.inventorydate, not just the column inventorydate,
because it will now order alphabetically rather than chronologically due to change in
data type

	FINAL ANSWER	*/

Select
	P.ProductName
	,Datename(mm, InventoryDate) + ', ' + Datename(yy, InventoryDate) InventoryDate
	,InventoryCount = I.Count
	From vProducts as P Join vInventories as I
	On P.ProductID = I.ProductID
	Order by ProductName, I.InventoryDate, Count;
go


-- Question 4 (10% of pts): How can you CREATE A VIEW called vProductInventories 
-- That shows a list of Product names, each Inventory Date, and the Inventory Count, 
-- with the date FORMATTED like January, 2017? Order the results by the Product, Date,
-- and Count!

/* This is asking for the same data as in previous question.
Copying final Select statement from Q3 into a Create View
here -- 
need 'top' for ordering to work*/

Create View vProductInventories
As
Select Top 10000000
	P.ProductName
	,Datename(mm, I.InventoryDate) + ', ' + Datename(yy, InventoryDate) InventoryDate
	,InventoryCount = I.Count
	From vProducts as P Join vInventories as I
	On P.ProductID = I.ProductID
	Order by ProductName, I.InventoryDate, Count;
go

-- Check that it works: Select * From vProductInventories;
go

-- Question 5 (10% of pts): How can you CREATE A VIEW called vCategoryInventories 
-- that shows a list of Category names, Inventory Dates, 
-- and a TOTAL Inventory Count BY CATEGORY, with the date FORMATTED like January, 2017?

/* building select	*/
--Select C.CategoryName, I.InventoryDate
--	From vCategories as C Join vProducts as P
--	On C.CategoryID = P.CategoryID
--	Join vInventories as I
--	On P.ProductID = I.ProductID;
--go

--/* formatting date */
--Select 
--	 C.CategoryName
--	,Datename(mm, I.InventoryDate) + ', ' + Datename(yy, InventoryDate) InventoryDate
--	From vCategories as C Join vProducts as P
--	On C.CategoryID = P.CategoryID
--	Join vInventories as I
--	On P.ProductID = I.ProductID;
--go

--/* getting inventory totals by category */
--Select C.CategoryName, I.InventoryDate, Sum(I.Count)
--	From vCategories as C Join vProducts as P
--	On C.CategoryID = P.CategoryID
--	Join vInventories as I
--	On P.ProductID = I.ProductID
--	Group by CategoryName, InventoryDate
--	Order by CategoryName;
--go

/* combining aggregation with date format	*/
--Select 
--	 C.CategoryName
--	,Datename(mm, I.InventoryDate) + ', ' + Datename(yy, InventoryDate) InventoryDate
--	,InventoryCountByCategory = Sum(I.Count)
--	From vCategories as C Join vProducts as P
--	On C.CategoryID = P.CategoryID
--	Join vInventories as I
--	On P.ProductID = I.ProductID
--	Group by CategoryName, InventoryDate;
--go

/*	creating view	*/
Create View vCategoryInventories
	As
	Select 
		 C.CategoryName
		,Datename(mm, I.InventoryDate) + ', ' + Datename(yy, InventoryDate) InventoryDate
		,InventoryCountByCategory = Sum(I.Count)
		From vCategories as C Join vProducts as P
		On C.CategoryID = P.CategoryID
		Join vInventories as I
		On P.ProductID = I.ProductID
		Group by CategoryName, InventoryDate;
go

-- Check that it works: Select * From vCategoryInventories;
go

-- Question 6 (10% of pts): How can you CREATE ANOTHER VIEW called  --- revised instructions--
-- vProductInventoriesWithPreviousMonthCounts to show 
-- a list of Product names, Inventory Dates, Inventory Count, AND the Previous Month
-- Count? Use a functions to set any January NULL counts to zero. Order the
-- results by the Product, Date, and Count. This new view must use your
-- vProductInventories view!

/* starting select statement*/
--Select * from vProductInventories;
--go

/* creating column for previous month count - and actually listing
columns from vProductsInventories*/
--Select 
--	 ProductName
--	,InventoryDate
--	,InventoryCount
--	,PreviousMonthCount = Lag(InventoryCount) Over (Order By ProductName,Year(InventoryDate)) 
--	From vProductInventories as PI
--	Group by ProductName,InventoryDate,InventoryCount;
--go

/* ordering by date within product name and adding ISNULL, added IIF to  prevent
January entries from pulling prev value as from March of preceding product
have to Cast Date column to order by date rather than alphabetizing*/
--Select 
--	 ProductName
--	,InventoryDate
--	,InventoryCount
--	,PreviousMonthCount = IIF(InventoryDate Like ('January%'),0,IsNull(Lag(InventoryCount) Over (Order By ProductName,Year(InventoryDate)),0))
--	From vProductInventories
--	Order by ProductName,Cast(InventoryDate as Date), InventoryCount;
--go

/* creating view -- add TOP
FINAL ANSWER	*/
Create --drop
View vProductInventoriesWithPreviousMonthCounts
	As
	Select Top 1000000
		 ProductName
		,InventoryDate
		,InventoryCount
		,PreviousMonthCount = IIF(InventoryDate Like ('January%'),0,IsNull(Lag(InventoryCount) Over (Order By ProductName,Year(InventoryDate)),0))
	From vProductInventories
	Order by ProductName,Cast(InventoryDate as Date), InventoryCount;
go

-- Check that it works: Select * From vProductInventoriesWithPreviousMonthCounts;
go

-- Question 7 (20% of pts): How can you CREATE one more VIEW 
-- called vProductInventoriesWithPreviousMonthCountsWithKPIs
-- to show a list of Product names, Inventory Dates, Inventory Count, the Previous Month 
-- Count and a KPI that displays an increased count as 1, 
-- the same count as 0, and a decreased count as -1? Order the results by the 
-- Product, Date, and Count!

/* listing columns to select from vProduct...PrevCounts and Ordering results*/
--Select Top 100000000
--	 ProductName
--	,InventoryDate
--	,InventoryCount
--	,PreviousMonthCount
--	From vProductInventoriesWithPreviousMonthCounts
--	Order By 1,Cast(inventorydate as Date),InventoryCount;
--go

/*	creating column	for KPIs*/
--Select Top 100000000
--	 ProductName
--	,InventoryDate
--	,InventoryCount
--	,PreviousMonthCount
--	,CountVsPreviousCountKPI = Case
--		When InventoryCount > PreviousMonthCount Then 1
--		When InventoryCount = PreviousMonthCount Then 0
--		When InventoryCount < PreviousMonthCount Then -1
--		End
--	From vProductInventoriesWithPreviousMonthCounts
--	Order By 1,Cast(inventorydate as Date),InventoryCount;
--go

/* creating view
FINAL ANSWER	*/

Create --drop
View vProductInventoriesWithPreviousMonthCountsWithKPIs
	As
	Select Top 100000000
	 ProductName
	,InventoryDate
	,InventoryCount
	,PreviousMonthCount
	,CountVsPreviousCountKPI = Case
		When InventoryCount > PreviousMonthCount Then 1
		When InventoryCount = PreviousMonthCount Then 0
		When InventoryCount < PreviousMonthCount Then -1
		End
	From vProductInventoriesWithPreviousMonthCounts
	Order By 1 /* trying to start using column numbers instead of names*/
			,Cast(inventorydate as Date),InventoryCount;
go


-- Important: This new view must use your vProductInventoriesWithPreviousMonthCounts view!
-- Check that it works: Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs;
go

-- Question 8 (25% of pts): How can you CREATE a User Defined Function (UDF) ---pasting in revised instructions
-- CREATE a User Defined Function (UDF) called fProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, the Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- The function must use the ProductInventoriesWithPreviousMonthCountsWithKPIs view!

/* creating select*/
--Select 
--	 ProductName
--	,InventoryDate
--	,InventoryCount
--	,PreviousMonthCount
--	,CountVsPreviousCountKPI 
--	From vProductInventoriesWithPreviousMonthCountsWithKPIs;
--go

/*Create Function, defining a variable KPIValue and using Where clause*/

go
Create --drop
Function dbo.fProductInventoriesWithPreviousMonthCountsWithKPIs(@KPIValue int)
	Returns Table
	As
	Return(
		Select	 ProductName
				,InventoryDate
				,InventoryCount
				,PreviousMonthCount
				,CountVsPreviousCountKPI
		From vProductInventoriesWithPreviousMonthCountsWithKPIs
		Where CountVsPreviousCountKPI = @KPIValue
		);
go

/* Check that it works:
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(1);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(0);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(-1);
*/
go

/***************************************************************************************/