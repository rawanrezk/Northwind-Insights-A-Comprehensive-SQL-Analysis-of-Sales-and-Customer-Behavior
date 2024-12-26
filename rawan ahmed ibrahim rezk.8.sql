--Customer Segmentation
--RFM Analysis:

--How many days from the last order "customers"// calculate the days since the last order ?
SELECT 
customerid 
  ,(strftime('%s', 'now') - strftime('%s', MAX(orderdate))) / 86400 AS DaysSinceLastOrder
FROM orders
GROUP BY customerid
Order by 2
--Results, We can see that the last order since  423 Day cause this date is not upated,
--so we can try another thing that we will see the last date. 
SELECT 
customerid
,orderdate
from Orders
order by 2 DESC
--last day in orders was 28-10-2023



--Calculate the total amount spent by each customer
SELECT customerid
,( 
  SELECT sum(unitprice*quantity*(1-discount))
  from 'Order Details' OD
  where OD.orderid=Orders.OrderID
  ) TotalPrice
from Orders
GROUP by 1
order by TotalPrice DESC



--Calculate the total number of orders 
select 
count(orderid) TotalNumberOfOrders
from Orders
--Results the total number of orders the comapany was made 16282 orders

--Calculate the Number of orders per customerid desc
Select 
customerid
, count(orderid) NumberOfOrders
from Orders
group by 1
order by 2 DESC
-- Results we can know from this query that BSBEV is the most customer buy from northwind, he made 210 order from it and thelost one make order was OCEAN made 154 order from north wind 



-- Create at least 3 customer segments:
-- Champions : Bought most Recently and most Often, and spent most
-- Potential: Loyalists Buy Most frequently or Spent Most
-- At Risk: Anyone else
SELECT 
    customerid,
    (strftime('%s','now') - strftime('%s', MAX(orderdate))) / 86400 AS days_since_last_order,
    COUNT(O.OrderID) AS TotalOrders,
    SUM(OD.unitprice * OD.quantity * (1 - OD.discount)) AS TotalSpent,
    CASE
        WHEN (strftime('%s','now') - strftime('%s', MAX(orderdate))) / 86400 >=420
             AND COUNT(O.OrderID) > 7000
             AND SUM(OD.unitprice * OD.quantity * (1 - OD.discount)) > 5000000 THEN 'Champion'
        WHEN (strftime('%s','now') - strftime('%s', MAX(orderdate))) / 86400 > 400
             AND COUNT(O.OrderID) > 5000
             AND SUM(OD.unitprice * OD.quantity * (1 - OD.discount)) > 4000000 THEN 'Potential'
        ELSE 'Risk'
    END AS CustomerCategory
FROM orders O
JOIN 'Order Details' OD 
ON O.OrderID = OD.orderid
GROUP BY customerid
order by 3 DESC
--Results in the report with the insights


--Order Value:	High-Value, Medium-Value, Low-Value customers based on their order revenue value.
SELECT 
	customerid,
	SUM(unitprice * quantity * (1 - discount)) 	AS	Revenue,

	CASE 
		WHEN SUM(unitprice * quantity * (1 - discount))> 500000 THEN 'High-Value'
		WHEN SUM(unitprice * quantity * (1 - discount))> 4000000 THEN 'Medium-Value'
   		eLSE 'Low-Value'
	END AS 'OrderValue'

from 'Order Details' OD
JOIN Orders O
on O.OrderID=OD.OrderID
group by 1
ORDER by 2 DESC
-- the results in the report with the insights


--Product Analysis:

--Identify products with:
--High Revenue Value: Identify the top 10 revenue generator products
 
 SELECT P.productid
 , productname
 ,sum(OD.UnitPrice*quantity*(1-discount)) Revenue
 from 'Order Details' OD 
 inner JOIN Products P
 on	 P.ProductID = OD.ProductID
 GROUP by 1
 order by 2 DESC
 LIMIT 10 
--Results in the report with the insights


 --High Sales Volume: Determine the top 10 most frequently ordered products.
-- how often a product was ordered?
SELECT productname
,COUNT(quantity) TotalQuantity
--,count(*) CountAll
FROM Products P 
inner JOIN 	'Order Details' OD
on OD.productid =P.ProductID
GROUP by 1
order by 2 DESC
limit 10
--Results in the report with the insights


--how many units of the product were sold in total / What are the top 10 products based on the total quantity sold?
SELECT productname
,sum(quantity) TotalQuantity
FROM Products P 
inner JOIN 	'Order Details' OD
on OD.productid =P.ProductID
GROUP by 1
order by 2 DESC
limit 10
--Results in the report with the insights



--Slow Movers: Identify products with low sales volume. (5 product)

 SELECT P.productid
 , productname
 ,sum(OD.UnitPrice*quantity*(1-discount)) 	Sales
,COUNT(quantity) TotalQuantity
 from 'Order Details' OD 
 inner JOIN Products P
 on	 P.ProductID = OD.ProductID
 GROUP by 1
 order by 2 ASC
 LIMIT 5 



-- Order Analysis: 
--Seasonality: Identify any seasonal fluctuations in order volume.
--
 select productname
 , count(O.OrderID) NumberOForders
 , strftime('%Y',orderdate) Years
 ,	(CAST(strftime('%m', orderdate) AS INTEGER) + 2) / 3 AS Quarter
 FROM Orders O
 join 'Order Details' OD
 on O.OrderID=OD.OrderID
 join Products P 
 on P.ProductID = 	OD.ProductID
group by 4 ,3

--Results
--Q1: "Chai" and "Chang" show moderate to low fluctuations in order volume.
--Q2: Some products like "Chai" and "Chang" experience higher volumes, especially in 2015 and 2020.
--Q3: Peaks in orders, especially for "Chai" and "Chang" in 2015, 2020, and 2021.
--Q4: Consistently high volumes for "Chai," with notable spikes in 2015, 2020, and 2021.
--Overall, the highest order volumes tend to occur in Q3 and Q4, likely reflecting seasonal demand



--Day-of-the-Month: Determine the most popular order days.
SELECT strftime('%d',orderdate) Days
,COUNT(orderid) NumberOfOrders
from Orders
group by 1
order by  2 desc
-- Results:  orders are generally more frequent early in the month, with a significant decline towards the month's end.

--Day-of-the-Week Analysis: Determine the most popular order days.
SELECT CASE strftime('%w', orderdate)
            WHEN '0' THEN 'Sunday'
            WHEN '1' THEN 'Monday'
            WHEN '2' THEN 'Tuesday'
            WHEN '3' THEN 'Wednesday'
            WHEN '4' THEN 'Thursday'
            WHEN '5' THEN 'Friday'
            WHEN '6' THEN 'Saturday'
        END AS DayOfWeek,
       COUNT(orderid) AS NumberOfOrders
FROM Orders
GROUP BY DayOfWeek
ORDER BY NumberOfOrders DESC;
--Results:The data shows a consistent trend of high orders at the beginning and end of the week, with Monday having the highest number of orders, while Thursday has the lowest.



--Order Size Analysis: Analyze the distribution of order quantities.
--a list of how many orders had 1 item, how many orders had 2 items, how many had 3 items, and so on.
SELECT quantity,
COUNT(ORDERID) NumberOfOrders
FROM 'Order Details'
GROUP BY 1
ORDER BY 1 
--Results :
--the most common order quantities range from 1 to 31 items, 
--with the highest number of orders for quantities of 10, 5, 15, 20, and 30 items.



-- Employee Performance:

-- 1-Evaluate employee performance based on: Total Revenue Generated.
select e.employeeid
,firstname||' '||lastname EmployeeName
,sum(unitprice*quantity*(1-discount)) TotalRevenue
from Employees e
join Orders o
on e.EmployeeID=o.EmployeeID
JOIN 'Order Details' od
on od.orderid =o.OrderID
GROUP by 1
order by 3 DESC
-- Results:
--Margaret Peacock is the highest contributor by order value,
--with the remaining top performers showing a relatively close range of values,
--all exceeding $48 million.



--2-Total Sales Volume (Number of orders processed).
SELECT e.employeeid
,firstname||' '||lastname FullName
, count(orderid) NumberOfOrders
from Employees e
join Orders o
on e.EmployeeID=o.EmployeeID
group by 2
order by 3 DESC

--Results: 
--Margaret Peacock is the highest contributor by num of orders. 
--Margaret Peacock leads with the highest orders processed (1,908), 
--showing top productivity. Nancy Davolio and Janet Leverling follow with 1,846 orders each.
--The remaining employees show balanced performance, with totals ranging from 1,804 to 1,754, 
--indicating a fairly even workload distribution overall.



--3-Evaluate employee performance based on: Average order value.

SELECT e.employeeid,
e.firstname || ' ' || e.lastname EmployeeName,
ROUND(SUM(od.quantity * od.unitprice*(1-discount)) / COUNT(o.orderid), 2) AverageOrderValue
FROM Employees e
JOIN Orders o
ON e.employeeid = o.employeeid
JOIN 'Order Details' od
ON o.orderid = od.orderid
GROUP BY e.employeeid, EmployeeName
ORDER BY AverageOrderValue DESC;
--Results: Michael Suyama leads with the highest score (742.41), followed closely by Janet Leverling (739.17) and Anne Dodsworth (738.67),
--showcasing a closely matched performance among the top contenders.



