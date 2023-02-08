--Data  Exploration, Model Development and Interpretation
USE KPMG;
SELECT *--(List_price)-(Standard_cost) AS Profit
FROM Transactions

ALTER TABLE Transactions
ADD Profit FLOAT NULL;

UPDATE Transactions
SET profit = (List_price)-(Standard_cost)


SELECT DOB, GETDATE() AS Today,DATEDIFF(YY, DOB,GETDATE()) AS AGE
FROM Customer_demographic

ALTER TABLE Customer_demographic
ADD AGE SMALLINT NULL;


UPDATE Customer_demographic
SET AGE = DATEDIFF(YY, DOB,GETDATE())



--Merging the Columns together



SELECT  CD.Customer_id, 
CD.first_name,
CD.last_name,
cd.Gender,cd.Age,cd.job_title, cd.job_industry_category,
CD.past_3_years_bike_related_purchases,
CD.wealth_segment,CD.owns_car,
CD.tenure,
CA.property_valuation,CA.Postcode, CA.State,
T.transaction_id,
T.transaction_date,
T.order_status,T.brand,
T.product_line,
T.product_size,
T.standard_cost, 
t.list_price,T.Profit
INTO Cleaned_kpmg
FROM Customer_demographic CD
 JOIN Customer_address CA
ON CD.customer_id = CA.customer_id
JOIN Transactions T
ON T.customer_id=CD.customer_id
--ORDER BY Transaction_date DESC


SELECT customer_id,First_name,last_name,past_3_years_bike_related_purchases, gender, Age, COUNT(Age) AS Male_age
FROM Cleaned_kpmg
WHERE Gender='Male'
GROUP BY Customer_id,first_name, last_name,past_3_years_bike_related_purchases, gender,Age
--ORDER BY past_3_years_bike_related_purchases DESC, Age DESC

UNION

SELECT customer_id,First_name,last_name,past_3_years_bike_related_purchases, gender, Age, COUNT(Age) AS Male_age
FROM Cleaned_kpmg
WHERE Gender='Female'
GROUP BY Customer_id,first_name, last_name,past_3_years_bike_related_purchases, gender,Age
ORDER BY past_3_years_bike_related_purchases DESC, Age DESC

--SUM OF PROFIT 

SELECT  Sum(ROUND(Profit,0)) AS Total_profit
FROM Cleaned_kpmg


-- SUM PAST_3YRS_PURCHASES
SELECT SUM(past_3_years_bike_related_purchases)AS Total_SUM_PAST_3YRS_PURCHASES
FROM Cleaned_kpmg



--Checking for Which Job Industry category purchased more in the past 3years


SELECT Job_industry_category, SUM(past_3_years_bike_related_purchases) AS Total_past_3_years_bike_related_purchases
FROM Cleaned_kpmg
WHERE job_industry_category != 'N/A'
GROUP BY job_industry_category
ORDER BY Total_past_3_years_bike_related_purchases  DESC


--Perceentage of puchases by gender

SELECT GENDER,
		SUM(CAST(Past_3_years_bike_related_purchases AS FLOAT))/
		(SELECT SUM(past_3_years_bike_related_purchases)
		FROM Cleaned_kpmg)*100
									AS percentage_purchases_by_gender
FROM Cleaned_kpmg
WHERE Gender IN ('mALE', 'Female')
GROUP BY Gender


--SELECT COUNT(Gender)
--FROM Cleaned_kpmg
--WHERE Gender !='U'


--Bike Related Purchases and Profit by customer Segment

SELECT Wealth_segment,SUM(Past_3_years_bike_related_purchases)  AS Total_purchases_by_Customer_segment,
		 SUM(ROUND(Profit, 0)) AS Total_Profit
FROM cleaned_kpmg
WHERE wealth_segment IN  ('Mass Customer','High Net worth','Affluent Customer')
GROUP BY Wealth_segment
ORDER BY Total_purchases_by_Customer_segment DESC



--Exploring Which Product Brand makes up the bulk of  the profit And Purchases



SELECT	brand, SUM(Past_3_years_bike_related_purchases) AS Total_past_3yrs_purchases,

--COUNT(DISTINCT(Brand)),
SuM(ROUND(Profit, 0)) AS total_profit
FROM Cleaned_kpmg
WHERE brand IN ('Giant bicycles', 'Norco Bicycles','OHM Cycles','Solex','Trek Bicycles','WeareA2B')
GROUP  BY Brand
ORDER BY Total_pROFIT DESC


--Analyzing Age Group to Know which of them Makes up purchases

ALTER TABLE Cleaned_kpmg
ADD Age_Category Nvarchar(100) NULL


SELECT AGE, CASE
			WHEN AGE <20 THEN 'Under20'
			WHEN Age BETWEEN 20 AND 29 THEN '20-29'
			WHEN Age BETWEEN 30 AND 39 THEN '30-39'
			WHEN Age BETWEEN 40 AND 49 THEN '40-49'
			WHEN Age BETWEEN 50 AND 59 THEN '50-59'
			WHEN AGE >60 THEN 'Above60'
			END 
FROM Cleaned_kpmg

UPDATE Cleaned_kpmg
SET Age_category =CASE
			WHEN AGE <20 THEN 'Under20'
			WHEN Age BETWEEN 20 AND 29 THEN '20-29'
			WHEN Age BETWEEN 30 AND 39 THEN '30-39'
			WHEN Age BETWEEN 40 AND 49 THEN '40-49'
			WHEN Age BETWEEN 50 AND 59 THEN '50-59'
			WHEN AGE >60 THEN 'Above60'
			END 


SELECT Age_category, SUM(past_3_years_bike_related_purchases) AS Total_Purchases_by_age_category, 
					 SUM(ROUND(Profit,0)) AS Total_profit_by_age_category
FROM Cleaned_kpmg
WHERE Age_category IN ('Under20','20-29','30-39','40-49','50-59','Above60')
GROUP BY Age_Category
ORDER BY Total_Purchases_by_age_category DESC


--Number of Genders between age 40-49 That do not own a car

SELECT Age_category, Gender,State, COUNT(owns_car) AS No_of_Gender_without_car
FROM Cleaned_kpmg
WHERE owns_car = 'NO' AND Gender IN ('Male','Female')
GROUP BY  [State], Age_Category, Gender
HAVING [State] IN ('VIC','NSW','QLD') AND Age_Category IN ('40-49')
ORDER BY No_of_Gender_without_car DESC

--Product Line And Product Size Analysis
SELECT Product_line, Product_size,
	   COUNT( product_line) AS No_product_line,
	   COUNT(Product_Size) AS No_produuct_size
FROM Cleaned_kpmg
GROUP BY Product_line, Product_size
ORDER BY No_product_line desc, No_produuct_size DESC


--Top  Customers to Target for the Marketing Campaign

WITH Targetcustomers AS (
SELECT	 ROW_NUMBER() OVER(PARTITION BY Customer_id ORDER BY Customer_id)AS Topcustomers_marketing,
		Customer_id, First_name,Last_name, Gender,Age,Job_industry_category,past_3_years_bike_related_purchases,
		Wealth_segment,Owns_car,State, Postcode		
FROM Cleaned_kpmg
WHERE Gender IN ('Male', 'Female') AND owns_car ='NO'  
		AND  wealth_segment ='Mass_customer' 
	   OR job_industry_category= 'Manufacturing'
GROUP BY Customer_id, First_name,Last_name, Gender,Age,Job_industry_category,past_3_years_bike_related_purchases,
		Wealth_segment,Owns_car,Postcode,State	
HAVING  Age BETWEEN 40 AND 49)
--ORDER BY past_3_years_bike_related_purchases)

SELECT *
FROM Targetcustomers
WHERE Topcustomers_marketing =1
ORDER BY past_3_years_bike_related_purchases


	
