------XX ----- SQL RETAIL DATA CASE STUDY  -----XX------ Name: Arjun Pawar

------XX ----- DATA PREPARATION -----XX------

--Q1: 
SELECT COUNT(*) FROM Transactions
SELECT COUNT(*) FROM Customer
SELECT COUNT(*) FROM prod_cat_info
--> The no of rows in transactions is 23053, Customer = 5647, prod_cat_info = 23


--Q2: 
SELECT COUNT(*) from transactions where qty<0
--> The answer is 2177 transactions (assuming that negative qty means returned)

--Q3: 
 select * , 
 CONVERT(date, tran_date,103) as Formatted_Date
 from Transactions 
 

 --Q4: 

Select max(Formatted_Date) as Max_Date, min(Formatted_Date) as Min_Date, 

floor (DATEDIFF(day, min(Formatted_Date),max(Formatted_Date))/365.25) 
as 'RANGE (years)',

floor ((DATEDIFF(day, min(Formatted_Date),max(Formatted_Date)) -  365.25*floor (DATEDIFF(day, min(Formatted_Date),max(Formatted_Date))/365.25))/30.5)
 as 'RANGE (months)',

floor(DATEDIFF(day, min(Formatted_Date),max(Formatted_Date))
-365.25*round (DATEDIFF(day, min(Formatted_Date),max(Formatted_Date))/365.25,0) 
-30.5*round ((DATEDIFF(day, min(Formatted_Date),max(Formatted_Date)) -  365.25*round (DATEDIFF(day, min(Formatted_Date),max(Formatted_Date))/365.25,0))/30.5, 0)
)as 'RANGE (days)'

from 
 (
 select * , 
 CONVERT(date, tran_date,103) as Formatted_Date
 from Transactions
 ) as t1

 ---> THE DATA WHICH WE HAVE SPANS 3 YEARS, 1 MONTH AND 3 DAYS. 
 


  --Q5:

SELECT prod_cat 
FROM prod_cat_info
WHERE prod_subcat = 'DIY'

---> IT BELONGS TO BOOKS


------XX ----- DATA ANALYSIS  -----XX------

--Q1:
SELECT TOP 1 Store_type, COUNT(transaction_id)
FROM  Transactions
GROUP BY Store_type
ORDER BY COUNT(transaction_id) DESC

---> eSHOP IS MOST FREQUENTLY USED 


--Q2:
SELECT Gender, COUNT(customer_Id) as CountOfCustomers FROM Customer
GROUP BY Gender
---> THERE ARE 2753 FEMALES, 2892 MALES AND 2 UNSPECIFIED RECORDS


--Q3:

SELECT TOP 1 city_code, COUNT(customer_Id) as CountofCustomer from Customer
Group by city_code
ORDER BY COUNT(customer_Id) DESC
---> The city with citycode 3 has maximum customers i.e. 595


--Q4:

SELECT prod_cat, count(prod_subcat) as NoOfSubCats from prod_cat_info
WHERE prod_cat='Books'
group by prod_cat
---> There are 6 subcategories under books

--Q5:
SELECT max(Qty) FROM transactions

---> 5 products

--Q6:
select sum(TOTAL) as 'TOTAL REVENUE FROM BOOKS + ELECTRONICS' from (
SELECT prod_cat_code, SUM(total_amt) as TOTAL FROM transactions 
WHERE prod_cat_code IN
(SELECT prod_cat_code FROM prod_cat_info where prod_cat = 'Electronics' OR prod_cat = 'Books')
GROUP BY prod_cat_code
) t1

/*SELECT transactions.prod_cat_code, round(SUM(transactions.total_amt),2) as TOTAL 
FROM transactions
WHERE transactions.prod_cat_code IN
(SELECT prod_cat_code FROM prod_cat_info where prod_cat = 'Electronics' OR prod_cat = 'Books')
GROUP BY transactions.prod_cat_code */


--alternative: total revenue by category
SELECT t0.prod_cat, round(SUM(total_amt),2) as Total
FROM ( 
SELECT prod_cat, total_amt
FROM Transactions
INNER JOIN (select distinct prod_cat_code, prod_cat from prod_cat_info) tt
ON Transactions.prod_cat_code = tt.prod_cat_code) t0
Where t0.prod_cat in  ('Books', 'Electronics')
Group by t0.prod_cat

---> The total revenue made from books is 12822694.04, from electronics is 10722463.63 while their combined total is 23545157.67 


--Q7: 

select count(NoOfTrans) from 
(SELECT cust_id, count(transaction_id) as NoOfTrans from Transactions
where total_amt>=0
GROUP BY cust_id) t
where NoOfTrans>10

---> There are 6 such customers


--Q8: 
SELECT SUM (total_amt) from Transactions
WHERE
Store_type = 'Flagship store' AND prod_cat_code IN 
(   SELECT prod_cat_code from prod_cat_info where prod_cat in ('Electronics' ,'Clothing') 
)
 
---> The combined revenue is  3409559.27 

--Q9: 
 

SELECT prod_subcat , sum (total_amt) as 'Total Revenue from Males'  
FROM 
(Transactions as t1
LEFT JOIN prod_cat_info as t2
ON t1.prod_cat_code = t2.prod_cat_code AND t1.prod_subcat_code = t2.prod_sub_cat_code) 
WHERE prod_cat = 'Electronics' AND cust_id IN (SELECT customer_Id from Customer where gender = 'M') 
group by prod_subcat

----> The total revenue from all subcategories combined is 5703109
 
--Q10:

select top 5 prod_subcat_code as 'Top 5 SubCategories Code', sum(total_amt) as 'Total sales + returns amt',
sum(total_amt)*100/(select sum(total_amt) from Transactions) as 'Percentage or market share'
from Transactions
group by prod_subcat_code
order by sum(total_amt) desc


--Q11:

Select sum(total_amt) as 'TOTAL REVENUE' from 
(
SELECT *, 
CONVERT(date, tran_date,103) as ModifiedTranDate, 
floor(DATEDIFF(DAY, CONVERT(date, Customer.DOB ,103), GETDATE())/365.25) as Age
FROM (Transactions left join Customer on Transactions.cust_id = Customer.customer_Id)
) t1
where t1.Age between 25 and 35  
and DATEDIFF(day, ModifiedTranDate, (SELECT MAX(t2.ModifiedDate) FROM (SELECT CONVERT(date, tran_date,103) as ModifiedDate from Transactions)t2))<=30 

---> The total revenue for transactions satisfying the criteria is 341049.41 

--Q12:
 
select top 1 prod_cat_code,sum(total_amt) as SumTotal from (

select *, CONVERT(date, tran_date, 103) as NewDate  
from Transactions
WHERE
total_amt<0  
 
) t1
where DATEDIFF(day, t1.NewDate,(SELECT MAX(t2.ModifiedDate) FROM (SELECT CONVERT(date, tran_date,103) as ModifiedDate from Transactions)t2))<=91
group by prod_cat_code
order by SumTotal
 
---> The category #5 has most return value


--Q13:
SELECT top 1 Store_type, SUM (Qty) as 'Total  sales'  from Transactions
GROUP BY Store_type
ORDER BY SUM (Qty) desc

---> By sales value the maximum is e-shop while the maximum by qty is also e-shop 

 
--Q14: 
SELECT t1.prod_cat_code, t2.prod_cat, avg(total_amt) as 'AVG REVENUE' from (Transactions t1 LEFT JOIN prod_cat_info t2 ON t1.prod_cat_code = t2.prod_cat_code AND t1.prod_subcat_code = t2.prod_sub_cat_code)
group by t1.prod_cat_code,t2.prod_cat
having avg(total_amt) > (SELECT avg(total_amt) from Transactions)

---> The categories where avg revenue is above overall avg are Books, Electronics, Clothing.


--Q15:

select prod_cat_code, prod_subcat_code, avg(total_amt) as 'Avg revenue', sum (total_amt) as 'Total revenue' from Transactions 
where prod_cat_code IN (
SELECT  top 5 prod_cat_code from Transactions
GROUP BY prod_cat_code
ORDER BY SUM (Qty) desc
)
GROUP BY prod_cat_code, prod_subcat_code
ORDER BY prod_cat_code, prod_subcat_code  

