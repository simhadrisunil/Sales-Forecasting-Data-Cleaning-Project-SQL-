# Sales-Forecasting-Data-Cleaning-Project-SQL-
This project focuses on building and preparing a Sales Forecasting database from scratch and applying data cleaning techniques using MySQL.
Project Highlights – Explained Clearly
📌 1. Created a Normalized Database Structure
Designed and created 5 key tables:

Orders: Contains transaction details like order date, units sold, price, region

Products: Contains product metadata like name, category, and cost price

Customers: Contains customer name and segment

Date_Dim: A custom calendar table with year, month, day, weekday, and quarter info

Delivery: Contains delivery dates, courier partners, and delivery status

Used VARCHAR, DATE, DECIMAL, and INT types appropriately for optimized structure

Implemented Primary Keys and Foreign Keys to ensure referential integrity

🧼 2. Cleaned and Standardized Date Formats
Fixed inconsistent date formats in OrderDate and DeliveryDate columns:

Some dates were in YYYY-MM-DD, others in DD-MM-YYYY or MM/DD/YYYY

Used STR_TO_DATE() and CASE logic to convert all into standard DATE type

Created new columns like Cleaned_Order_Date and CleanedDeliveryDate for accurate tracking

❌ 3. Corrected Negative and Invalid Values
Identified and corrected negative values in:

UnitsSold (converted to absolute values)

DeliveryDelayDays (set to 0 if NULL or negative)

Fixed mismatched values between TotalPrice and expected (UnitsSold * UnitPrice)

🧹 4. Trimmed Whitespaces and Standardized Text
Used TRIM() and CONCAT() functions to clean and standardize:

Region in Orders table (replaced blank with 'Unknown')

Segment and CustomerName in Customers table

Category and Subcategory in Products table

CourierPartner and DeliveryStatus in Delivery table

Capitalized first letter of text fields for uniform formatting

🧾 5. Handled NULLs and Missing Data
Replaced missing values (NULL or empty strings) with logical defaults:

Region → 'Unknown'

Segment → 'Unclassified'

CostPrice → filled with average cost of the same category

This ensured the dataset is ready for analysis without gaps

🔄 6. Removed Duplicates
Checked for duplicate entries in:

ProductID (e.g., duplicate P021 entry deleted)

CustomerID (e.g., duplicate C020 fixed by retaining one clean record)

Ensured all primary keys (OrderID, CustomerID) are unique and reliable

🔐 7. Applied Primary Keys and Constraints
Added PRIMARY KEY constraints to ensure unique identifiers

Enforced data consistency using foreign key relationships (e.g., Orders → Delivery)

🎯 Final Outcome
The final cleaned database is:

Fully normalized and well-structured

Free from invalid, inconsistent, and missing data

Ready to be connected to Power BI for Sales Forecasting & Profitability Analysis

