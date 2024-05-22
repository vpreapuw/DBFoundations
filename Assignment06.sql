--*************************************************************************--
-- Title: Assignment06
-- Author: Vugee Preao
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2024-05-22,VugeePreap,Answered Assignment
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_VugeePreap')
	 Begin 
	  Alter Database [Assignment06DB_VugeePreap] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_VugeePreap;
	 End
	Create Database Assignment06DB_VugeePreap;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_VugeePreap;

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
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

-- Categories
Create View dbo.vwCategories
With SchemaBinding
As
Select CategoryID, CategoryName
From dbo.Categories;
go

-- Products
Create View dbo.vwProducts
With SchemaBinding
As
Select ProductID, ProductName, CategoryID, UnitPrice
From dbo.Products;
go

-- Employees
Create View dbo.vwEmployees
With SchemaBinding
As
Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID
From dbo.Employees;
go

-- Inventories
Create View dbo.vwInventories
With SchemaBinding
As
Select InventoryID, InventoryDate, EmployeeID, ProductID, [Count]
From dbo.Inventories;
go

-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

-- Revoke SELECT permission on tables for public
Revoke Select on dbo.Categories from public;
Revoke Select on dbo.Products from public;
Revoke Select on dbo.Employees from public;
Revoke Select on dbo.Inventories from public;

-- Grant SELECT permission on views for public
Grant Select on dbo.vwCategories to public;
Grant Select on dbo.vwProducts to public;
Grant Select on dbo.vwEmployees to public;
Grant Select on dbo.vwInventories to public;

-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

Create View dbo.vwCategoryProductPrices
As
Select c.CategoryName, p.ProductName, p.UnitPrice
From dbo.Categories c
Join dbo.Products p On c.CategoryID = p.CategoryID
Order By c.CategoryName, p.ProductName;
go

-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

Create View dbo.vwProductInventoryCounts
As
Select p.ProductName, i.InventoryDate, i.[Count]
From dbo.Products p
Join dbo.Inventories i On p.ProductID = i.ProductID
Order By p.ProductName, i.InventoryDate, i.[Count];
go

-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

Create View dbo.vwInventoryDatesEmployees
As
Select i.InventoryDate, e.EmployeeFirstName + ' ' + e.EmployeeLastName As EmployeeName
From dbo.Inventories i
Join dbo.Employees e On i.EmployeeID = e.EmployeeID
Group By i.InventoryDate, e.EmployeeFirstName, e.EmployeeLastName
Order By i.InventoryDate;
go

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

Create View dbo.vwCategoryProductInventory
As
Select c.CategoryName, p.ProductName, i.InventoryDate, i.[Count]
From dbo.Categories c
Join dbo.Products p On c.CategoryID = p.CategoryID
Join dbo.Inventories i On p.ProductID = i.ProductID
Order By c.CategoryName, p.ProductName, i.InventoryDate, i.[Count];
go

-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

Create View dbo.vwCategoryProductInventoryEmployees
As
Select c.CategoryName, p.ProductName, i.InventoryDate, i.[Count], e.EmployeeFirstName + ' ' + e.EmployeeLastName As EmployeeName
From dbo.Categories c
Join dbo.Products p On c.CategoryID = p.CategoryID
Join dbo.Inventories i On p.ProductID = i.ProductID
Join dbo.Employees e On i.EmployeeID = e.EmployeeID
Order By i.InventoryDate, c.CategoryName, p.ProductName, EmployeeName;
go

-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

Create View dbo.vwChaiChangProductInventory
As
Select c.CategoryName, p.ProductName, i.InventoryDate, i.[Count], e.EmployeeFirstName + ' ' + e.EmployeeLastName As EmployeeName
From dbo.Categories c
Join dbo.Products p On c.CategoryID = p.CategoryID
Join dbo.Inventories i On p.ProductID = i.ProductID
Join dbo.Employees e On i.EmployeeID = e.EmployeeID
Where p.ProductName in ('Chai', 'Chang')
Order By i.InventoryDate, c.CategoryName, p.ProductName, EmployeeName;
go

-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

Create View dbo.vwEmployeeManagers
As
Select e1.EmployeeFirstName + ' ' + e1.EmployeeLastName As EmployeeName,
       e2.EmployeeFirstName + ' ' + e2.EmployeeLastName As ManagerName
From dbo.Employees e1
Left Join dbo.Employees e2 On e1.ManagerID = e2.EmployeeID
Order By ManagerName, EmployeeName;
go

-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.

Create View dbo.vwAllData
As
Select p.ProductID, p.ProductName, p.CategoryID, p.UnitPrice,
       c.CategoryName,
       i.InventoryID, i.InventoryDate, i.[Count],
       e.EmployeeID, e.EmployeeFirstName + ' ' + e.EmployeeLastName As EmployeeName,
       m.EmployeeFirstName + ' ' + m.EmployeeLastName As ManagerName
From dbo.Products p
Join dbo.Categories c On p.CategoryID = c.CategoryID
Join dbo.Inventories i On p.ProductID = i.ProductID
Join dbo.Employees e On i.EmployeeID = e.EmployeeID
Left Join dbo.Employees m On e.ManagerID = m.EmployeeID
Order By c.CategoryName, p.ProductName, i.InventoryID, e.EmployeeFirstName, e.EmployeeLastName;
go

-- Test your Views (NOTE: You must change the your view names to match what I have below!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/