USE KPMG;



--Identifying nulls 

--DOB 
SELECT *
FROM Customer_demographic
WHERE DOB  IS NULL
--ORDER BY DOB ASC

SELECT *
FROM Customer_demographic
WHERE DOB  IS NOT NULL
ORDER BY DOB ASC

UPDATE Customer_demographic
SET DOB = '1943-12-21'
WHERE customer_id = 34

-- First_name and Last_name 
SELECT *
FROM Customer_demographic
WHERE Last_name IS NULL

--Aligning the Owns car column
USE Kpmg;
SELECT Owns_car, LTRIM(OWNS_CAR)
FROM Customer_demographic
--GROUP BY owns_car

--Job Title
SELECT Job_title
FROM Customer_demographic
WHERE Job_title IS NULL

--Gender
SELECT Gender,COUNT(Gender)
FROM Customer_demographic
GROUP BY gender


SELECT Gender,
(CASE WHEN Gender = 'F' THEN 'Female'
	 WHEN Gender = 'Femal' THEN 'Female'
	 WHEN Gender = 'M' Then 'Male' 
	 WHEN Gender = 'Male' THEN 'Male'
	 WHEN Gender = 'Female' THEN 'Female'
	 WHEN Gender= 'U' THEN 'U' 
	 END	)	AS Gender	   
FROM Customer_demographic

UPDATE Customer_demographic
SET Gender =(CASE WHEN Gender = 'F' THEN 'Female'
	 WHEN Gender = 'Femal' THEN 'Female'
	 WHEN Gender = 'M' Then 'Male' 
	 WHEN Gender = 'Male' THEN 'Male'
	 WHEN Gender = 'Female' THEN 'Female'
	 WHEN Gender= 'U' THEN 'U' 
	 END	)
	 
--Deceased indicator

SELECT deceased_indicator, COUNT(Deceased_indicator)
FROM Customer_demographic
GROUP BY deceased_indicator

DELETE Customer_demographic
WHERE Deceased_indicator='Y'


--Cleaning the State column in  the Customer address Table

SELECT State,Count(state)
FROM Customer_address
GROUP BY State


SELECT State,
CASE 
		WHEN [state] =  'Victoria' THEN 'VIC'
		WHEN [state] = 'VIC'  THEN 'VIC'
		WHEN [State] = 'New south Wales' THEN 'NSW'
		WHEN [State] = 'NSW' THEN 'NSW'
		WHEN [State] = 'QLD' THEN 'QLD'
		END
FROM Customer_address


UPDATE Customer_address
SET State = CASE 
		WHEN [state] =  'Victoria' THEN 'VIC'
		WHEN [state] = 'VIC'  THEN 'VIC'
		WHEN [State] = 'New south Wales' THEN 'NSW'
		WHEN [State] = 'NSW' THEN 'NSW'
		WHEN [State] = 'QLD' THEN 'QLD'
		END

--Validating the Postcode Column  in Customer Address
SELECT Postcode, LEN(Postcode)
FROM Customer_address
GROUP BY Postcode
HAVING LEN(Postcode) <4 OR LEN(Postcode) >4





--Checking for Duplicates

SELECT Customer_id, COUNT(Customer_id)
FROM Customer_demographic
GROUP BY Customer_id
HAVING COUNT(Customer_id)>1

SELECT First_name, last_name, COUNT(*)
FROM Customer_demographic
GROUP BY First_name, Last_name
HAVING COUNT(*)>1 

WITH NEW AS
(SELECT customer_id, Transaction_id,
ROW_NUMBER() OVER (PARTITION BY Customer_id, Transaction_id ORDER BY Customer_id DESC) AS New
FROM Transactions)
--ORDER BY  New DESC 
SELECT *
FROM NEW
WHERE New>1


--Changing  the Owns_car column to Yes when = 1 anD NO When = 0

ALTER TABLE customer_demographic
ALTER COLUMN Owns_car nvarchar(255)



SELECT Owns_car,
	(CASE
		WHEN owns_car = 1 THEN 'YES'
		WHEN owns_car = 0 THEN 'NO'
		ELSE owns_car
		END) AS Owns_car_ed
FROM Customer_demographic


UPDATE customer_demographic
SET Owns_car = 
	(CASE
		WHEN owns_car = 1 THEN 'YES'
		WHEN owns_car = 0 THEN 'NO'
		ELSE owns_car
		END) 

SELECT *
FROM Customer_demographic

--Removing irrelevant  Column

ALTER TABLE  Customer_demographic
DROP COLUMN [default]



--Cleaning the  Transaction Table

SELECT*-- Product_first_sold_date, CAST(CONVERT(bigint,Product_first_sold_date) AS DATE)
FROM Transactions

ALTER TABLE Transactions
DROP COLUMN Product_first_sold_date




-- Changing 0  TO FALSE and 1 to TRUE in the Online Order Column

ALTER TABLE Transactions
ALTER COLUMN Online_Order nvarchar(255)

SELECT online_order,
	CASE 
	WHEN online_order = 0 THEN 'FALSE'
	WHEN Online_order = 1 THEN 'TRUE'
	ELSE Null
	END
FROM Transactions
--WHERE Transaction_date IS NULL
--ORDER BY transaction_date DESC

UPDATE Transactions
SET Online_order= CASE 
	WHEN online_order = 0 THEN 'FALSE'
	WHEN Online_order = 1 THEN 'TRUE'
	ELSE Null
	END


SELECT*
FROM Transactions


--Rounding List price to two decimal places

SELECT List_price, ROUND(List_price,2)
FROM Transactions

UPDATE Transactions
SET List_price=ROUND(List_price,2)







--Merging the customer demographic table , customer address table and Transactions Tables together to identify outliers


SELECT  CD.Customer_id, CA.customer_id,T.CUSTOMER_ID,
CD.first_name,
CD.last_name,
CD.past_3_years_bike_related_purchases,
CD.wealth_segment,CD.owns_car,
CD.tenure,
CA.property_valuation,
T.transaction_id,
T.transaction_date,
T.order_status,
T.product_line,
T.product_size,
T.standard_cost,
t.list_price
FROM Customer_demographic CD
 full OUTER JOIN Customer_address CA
ON CD.customer_id = CA.customer_id
FULL OUTER JOIN Transactions T
ON T.customer_id=CD.customer_id
WHERE CD.customer_id IS NULL 
	AND CA.customer_ID IS NOT NULL
--From the above, we can see that we have 5 customer_ids in the customer_address table that are not in the main table customer demographic table

	DELETE Customer_address
	WHERE Customer_id IN (753,3790,4001,4002,4003)

SELECT  CD.Customer_id, CA.customer_id,T.CUSTOMER_ID
FROM Customer_demographic CD
 RIGHT JOIN Customer_address CA
ON CD.customer_id = CA.customer_id
RIGHT JOIN Transactions T
ON T.customer_id=CD.customer_id
WHERE CD.customer_id IS NULL 
	AND CA.customer_ID IS NULL

--From the above query, we have 50 ccustomers in the transaction table that are not in the customer_demographic table.
DELETE Transactions
WHERE Customer_id IN (22,753,22,22,10,22,23,10,
					  753,23,23,2322,753,5034,
                      10,3,3,3,753,33,10,22,3,
					  23,753,10,22,5034,3,22,
					  5034,23,23,753,753,10,3,753)



		




