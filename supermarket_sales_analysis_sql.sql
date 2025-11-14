use ALLDATA;
SELECT *  FROM supermarket_sales;
-- TO CHECK DATATYPES OF EACH COLUMNS
EXEC SP_HELP  SUPERMARKET_SALES;

-- DATA CLEANING AND PREPAREATION
-- ADD COLUMNS IN EXISTING TABLE
begin transaction;
ALTER TABLE Supermarket_sales ADD  Sale_Date DATE;
alter table supermarket_sales add  sale_time Time;
-- drop existing columns 
ALTER TABLE SUPERMARKET_SALES DROP COLUMN Sale_Date;
ALTER TABLE SUPERMARKET_SALES DROP COLUMN Sale_Time;
-- ADD COLUMNS FOR MONTH, DAY OF THE WEEK AND HOUR
ALTER TABLE SUPERMARKET_SALES ADD sale_Month varchar(20);
ALTER TABLE SUPERMARKET_SALES ADD Day_of_the_week varchar(20);
ALTER TABLE SUPERMARKET_SALES ADD Sale_hour int;

-- feature engineering (Extracting useful components)

-- populate the new columns
UPDATE supermarket_sales SET sale_Month = DATENAME(MONTH, DATE);
UPDATE supermarket_sales SET Day_of_the_week = DATENAME(WEEKDAY, DATE);
UPDATE supermarket_sales SET Sale_hour = DATEPART(HOUR, Time);


-- Handles null and Duplicates 
SELECT COUNT(*) FROM supermarket_sales WHERE Invoice_ID IS NULL;
select count(*) from supermarket_sales where Total is null ;

-- Identify the duplicates records
select Invoice_ID, count(*) from supermarket_sales group by Invoice_ID having count(*) > 1;
commit;


-- 1: Which branch and city is the most profitable/has the highest revenue?
select City , sum(Total) as Total_revenue 
from supermarket_sales 
group by city 
order by Total_revenue desc ;
select TOP 1 City , sum(Total) as Total_revenue 
from supermarket_sales 
group by city 
order by Total_revenue DESC ;
select Branch ,city,  round(sum(Total),2) as Total_revenue 
from supermarket_sales 
group by Branch, City 
order by Total_revenue desc ;

-- 2: What is the most popular payment method?
select Payment , count(Invoice_ID) as Total_transaction, round(sum(Total),2) as Total_revenue 
from supermarket_sales 
group by Payment 
order by Total_transaction DESC;

-- 3: Which product line generates the highest revenue and quantity sold?

select Product_line, count(quantity) as Quantity_sold , round(sum(Total),2) as Total_revenue 
from supermarket_sales
group by Product_line
order by Total_revenue DESC;


--  Who spends more, members or normal customers, and which gender is more frequent?
select Customer_type, Gender , round(sum(Total),2) as Total_revenue , count(Invoice_ID) as total_transaction
from supermarket_sales 
group by Customer_type, Gender 
order by Total_revenue DESC;

select Customer_type,  round(AVG(Total),2) as Average_revenue , count(Invoice_ID) as total_transaction
from supermarket_sales 
group by Customer_type 
order by Average_revenue DESC;

-- 5: Which hour of the day or day of the week has the most sales/transactions?

-- -- Busiest day of the week
select Day_of_the_week, count(Invoice_ID) as Total_transaction
from supermarket_sales
group by Day_of_the_week
order by Total_transaction DESC;

-- Busiest hour of the day
select Sale_hour, count(Invoice_ID) as Total_transaction, round(sum(Total),2) as Total_revenue
from supermarket_sales
group by Sale_hour
order by Total_transaction DESC;

/*Profitability: Branch B is the least profitable. We need to investigate why sales there are lower than A and C.

Customer Behavior: 60% of revenue comes from 'Members'. They spend slightly less per transaction on average than 'Normal' customers, 
but their frequency is higher.

Peak Hours: The busiest periods are 12:00 PM - 2:00 PM and 6:00 PM - 8:00 PM.*/


/*Bar Charts: Compare revenue across Branches, Product Lines, Payment Methods, and Hours of Day.
Pie Charts: Show the distribution of Customer Types or Gender among transactions.
KPI Cards: Highlight key metrics like Total Revenue, Average Rating, and Gross Income.
*/
/*Insight: "Sports and Travel" is the top-grossing product line.	Action: Expand inventory space for "Sports and Travel" products; run a loyalty promotion for this category next quarter.
Insight: The store is quiet between 9 AM and 11 AM.	Action: Offer early-bird specials during this period, or optimize staff scheduling to reduce costs during low traffic times.
Insight: 'E-Wallet' is the fastest-growing payment method.	Action: Ensure marketing materials highlight e-wallet options; check reliability of the payment terminals
.*/
