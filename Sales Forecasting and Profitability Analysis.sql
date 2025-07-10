create DATABASE Sales_forcasting;
use Sales_forcasting;

-- CREATE ORDERS TABLE.
drop table if exists orders;
CREATE TABLE orders (
	OrderID VARCHAR(10) PRIMARY KEY,
	OrderDate VARCHAR(20),
	CustomerID VARCHAR(10),
	ProductID VARCHAR(10),
	Region VARCHAR (50),
	UnitsSold INT,
	UnitPrice DECIMAL(10,2),
	TotalPrice DECIMAL (10,2)
);
describe orders;

-- CREATE PRODUCTS TALBE
drop table if exists products;
CREATE TABLE products (
	ProductID VARCHAR(10),
    ProductName VARCHAR(100),
    Category VARCHAR (50),
	Subcategory VARCHAR(50),
    costprice DECIMAL (10,2)
);
describe products;

-- CREATE CUSTOMERS
drop table if exists Customers;
CREATE TABLE Customers (
	CustomerID VARCHAR(100),
	CustomerName VARCHAR (50),
	Segment VARCHAR (50)
);
describe customers;

-- CREATE DATE TABLE.

drop table if exists Date_Dim;
CREATE TABLE Date_Dim (
    Date DATE,
    Day INT,
    Month INT,
    MonthName VARCHAR(20),
    Year INT,
    Weekday VARCHAR(20),
    Quarter INT
);
describe date_dim;

-- CREATE DELIVERY TABLE
CREATE TABLE if not exists Delivery(
	OrderID VARCHAR(10) PRIMARY KEY,
	DeliveryDate DATE,
	CourierPartner VARCHAR(50),
	DeliveryStatus VARCHAR(50),
	DeliveryDelayDays INT,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);
describe delivery;

select * from orders;
select * from products;
select * from customers;
select * from date_dim;
select * from delivery;
SET SQL_SAFE_UPDATES = 0;

-- CLEANING ORDER TABLE.
-- Fix inconsistent date formats.
-- Create cleaned date column (we can later drop original)
alter table orders 
add  cleaned_order_date date;

update orders
	set cleaned_order_date = STR_TO_DATE(orderdate,'%Y-%m-%d')
    where orderdate like '____-__-__';
    
select * from orders;

UPDATE Orders
SET Cleaned_Order_Date =
  CASE
    WHEN OrderDate LIKE '__-__-____' THEN
      STR_TO_DATE(OrderDate, '%d-%m-%Y')
    WHEN OrderDate LIKE '__/__/____' THEN
      STR_TO_DATE(OrderDate, '%m/%d/%Y')
    ELSE NULL
  END;

select * from orders;
-- 2 Fix negative UnitsSold

select * from orders where UnitsSold < 0;


UPDATE orders set Unitssold = ABS(unitssold) 
	where unitssold <0;

-- 3 Fix TotalPrice mismatch

-- Add a computed column to compare
select *,(unitssold*Unitprice) as ExpectedTotal
from orders
where round(totalprice,2) != round(unitssold*unitprice,2);

-- Option: Update TotalPrice to correct value
update orders 
	set TotalPrice = round( unitssold*unitprice,2)
    where round(totalprice,2) != round(unitssold * unitprice,2);
    
-- 4 Trim and standardize Region
-- Trim whitespaces
select * from orders
	where Region != trim(Region);

update orders
	set Region = trim(Region);

-- Replace NULL or empty with 'Unknown'
SELECT *
FROM Orders
WHERE Region IS NULL
   OR TRIM(Region) = '';
   
update orders
 set Region = 'Unknown'
 where trim(Region) = '';

-- Cleaning products table
select * from products;
select distinct(category) from products;

-- Remove leading/trailing spaces in Category
UPDATE products 
	set category = trim(category);
    
select count(productID) from products;

-- Standardize capitalization
update products
	set category =concat(
		upper(left(category,1)),
        lower(substring(category,2))
    );

select count(*) from products;
-- preview NULLs in Electronics
select * from products where costprice is null and Category = 'Electronics'; 

select * from products;

update products
	set costprice = (
	select round(avg(costprice),2)
    from (select * from products) as temp
    where temp.category = products.category )
    where costprice is null ;


-- Remove duplicate rows
select productID,count(*)
from products group by ProductID having count(*) > 1;

select * from products where ProductID = 'P021';

delete from products where productid = 'p021'
limit 1;

-- Trim spaces in Segment and CustomerName
--  Standardize casing in Segment
-- Handle NULL or empty Segment
-- Check for duplicate CustomerIDs
-- Make CustomerID a Primary Key

select * from customers;
update customers
	set segment = trim(segment),
		customerName = trim(CustomerName);
        
-- Standardize casing in Segment
update customers
	set segment = concat(
		upper(left(segment,1)),
        lower(substring(segment,2))
        );
        
-- Handle NULL or empty Segment

update customers
	set segment = 'Unclassified'
    where segment is null or segment = '';

-- Check for duplicate CustomerIDs
select CustomerID,count(*) 
from customers 
group by CustomerID 
having count(*) > 1;

select * from customers where CustomerID = 'C020';
delete from customers where CustomerID = 'C020' and CustomerName = 'Cust. 20';
update customers
	set segment ='Consumer' where customerID = 'C020';
    
-- Make CustomerID a Primary Key
alter table customers add primary key (CustomerID);

-- Fix DeliveryStatus (trailing spaces, inconsistent casing)

select * from delivery;

update delivery
	set deliverystatus = trim(DeliveryStatus),
		CourierPartner = trim(CourierPartner);
        
-- inconsistent casing
update delivery
	set CourierPartner = concat(
		upper(left(CourierPartner,1)),
        lower(substring(CourierPartner,2))
        );
        
-- Fix DeliveryDate type
-- If DeliveryDate is in string format, convert it to DATE.
alter table delivery add ClanedDeliveryDate date;
alter table delivery rename column ClanedDeliveryDate to CleanedDeliveryDate;

UPDATE delivery
SET CleanedDeliveryDate =
  CASE
    WHEN deliveryDate LIKE '__-__-____' THEN
      STR_TO_DATE(DeliveryDate, '%d-%m-%Y')
    WHEN deliveryDate LIKE '__/__/____' THEN
      STR_TO_DATE(DeliveryDate, '%m/%d/%Y')
	when deliveryDate like '____-__-__' then
	  str_to_date(DeliveryDate,'%Y-%m-%d')
    ELSE NULL
  END;

-- Fix NULL or negative DeliveryDelayDays

update delivery 
	set DeliveryDelayDays = 0
    where DeliveryDelayDays is null or deliverydelaydays = '';
    
update delivery
	set deliverydelaydays = abs(Deliverydelaydays)
		where deliveryDelaydays < 0;

-- Check duplicates in OrderID
select orderid, count(*) from delivery
group by OrderID having count(*) >1;

set sql_safe_updates = 1;		
