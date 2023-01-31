--Cleaning Data in SQL

USE MARTINS_SQL;
SELECT *
FROM Nashville;


--populating property address
SELECT *
FROM Nashville
--WHERE propertyaddress is NULL
ORDER BY ParcelID

--since the parcelID is in tandem with the property address, 
--we populate the null property address rows with those that have addresses for similar parcelID
--We Join nashville to itself.


 
SELECT  x.ParcelID, Y.PropertyAddress, Y.parcelID, X.PropertyAddress,ISNULL(X.propertyaddress, Y.PropertyAddress)
FROM Nashville X
Join Nashville Y
ON x.ParcelID  = Y.ParcelID 
AND X.UniqueID != Y.UniqueID
WHERE X.propertyaddress is NULL


UPDATE X
SET Propertyaddress= ISNULL(X.propertyaddress, Y.PropertyAddress)
FROM Nashville X
Join Nashville Y
ON x.ParcelID  = Y.ParcelID 
AND X.UniqueID != Y.UniqueID
WHERE X.propertyaddress is NULL

--Splitting address column into address, city, state


SELECT Propertyaddress,
SUBSTRING(Propertyaddress,1, CHARINDEX(',',Propertyaddress)-1) AS address,
SUBSTRING (Propertyaddress, CHARINDEX(',',Propertyaddress)+1, LEN(PropertyAddress)) AS address
FROM Nashville

Alter Table Nashville
Add Address nvarchar(255);


Alter Table Nashville
Add City nvarchar(255);

Update Nashville
Set address = SUBSTRING(Propertyaddress,1, CHARINDEX(',',Propertyaddress)-1) 


Update Nashville
Set city = SUBSTRING (Propertyaddress, CHARINDEX(',',Propertyaddress)+1, LEN(PropertyAddress))

SELECT*
FROM Nashville

--Splitting the owner address

SELECT	PARSENAME(REPLACE(Owneraddress,',','.'), 3),
		PARSENAME(REPLACE(Owneraddress,',','.'), 2),
		PARSENAME(REPLACE(Owneraddress,',','.'), 1)

FROM Nashville 

ALTER TABLE Nashville
ADD Owneradd nvarchar(255)

ALTER TABLE Nashville
ADD Ownercity Nvarchar(255)

ALTER TABLE Nashville
ADD Ownerstate Nvarchar(255)


UPDATE Nashville
SET Owneradd = PARSENAME(REPLACE(Owneraddress,',','.'), 3)

UPDATE Nashville
SET Ownercity = PARSENAME(REPLACE(Owneraddress,',','.'), 2)

UPDATE Nashville
SET Ownerstate = PARSENAME(REPLACE(Owneraddress,',','.'), 1)


SELECT*
FROM Nashville


--changing 1  to 'Y' and 0 to 'N' in Sold as Vacant

SELECT  DISTINCT(soldasvacant), COUNT(Soldasvacant)
FROM Nashville
GROUP BY soldasvacant
ORDER BY 1,2

ALTER TABLE Nashville
ALTER COLUMN Soldasvacant Nvarchar(255)

SELECT SoldasVacant,
CASE	
	WHEN Soldasvacant = 0 THEN 'NO'
	WHEN Soldasvacant=1 THEN 'YES'
	ELSE Soldasvacant
	END
FROM Nashville

UPDATE Nashville
SET SoldasVacant = CASE	
	WHEN Soldasvacant = 0 THEN 'NO'
	WHEN Soldasvacant=1 THEN 'YES'
	ELSE Soldasvacant
	END


--Remove Duplicates

WITH Row_num AS(
SELECT *,ROW_NUMBER() OVER( PARTITION BY  
				parcelID,
				Propertyaddress,
				saledate,
				saleprice,
				legalreference
				ORDER BY UniqueID)row_num
FROM Nashville)
--ORDER BY Parcelid
DELETE
FROM Row_num
WHERE Row_num>1

WITH Row_num AS(
SELECT *,ROW_NUMBER() OVER( PARTITION BY  
				parcelID,
				Propertyaddress,
				saledate,
				saleprice,
				legalreference
				ORDER BY UniqueID)row_num
FROM Nashville)
--ORDER BY Parcelid
SELECT*
FROM Row_num
WHERE Row_num>1


--removing unused and irrelevant columns

SELECT * INTO cleaned_nashville_data
FROM Nashville
	
	
ALTER TABLE Cleaned_nashville_data
DROP COLUMN Propertyaddress, Owneraddress, taxdistrict 

CREATE VIEW cleaned_nashville AS
SELECT *
FROM cleaned_nashville_data
