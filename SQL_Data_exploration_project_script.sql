--SELECT *
--FROM Covid_vaccinations
--ORDER BY 1, 2, 3, 4




USE Covid;
SELECT Location, Date, total_cases, New_cases,total_deaths,population 
FROM Covid_deaths
ORDER BY 1,2,3,4

--looking at total cases versus total deaths

USE COVID;

SELECT 
	Location, 
	Date, total_cases,
	New_cases,
	total_deaths,
	population,
CASE
	WHEN total_cases=0
	THEN NULL 
	ELSE TRY_CONVERT (FLOAT, Total_deaths)/ TRY_CONVERT (FLOAT, total_cases)*100
	END AS Death_percentage
FROM Covid_deaths
WHERE Location ='Nigeria'
ORDER BY 1,2

--total cases versus population


SELECT 
	Location, 
	Date,population, total_cases,	
CASE 
	WHEN population=  0
	THEN NULL
	ELSE  TRY_CONVERT (FLOAT, Total_cases)/ TRY_CONVERT (FLOAT, population)*100 
	END AS population_percentage	
FROM Covid_Deaths
ORDER BY 1,2,3,4

--lookin at couuntries with highest infection rates to population



ALTER TABLE COVID_DEATHS
ALTER COLUMN population FLOAT;

ALTER TABLE COVID_DEATHS
ALTER COLUMN total_deaths FLOAT;

ALTER TABLE COVID_DEATHS
ALTER COLUMN total_cases FLOAT;

ALTER TABLE COVID_DEATHS
ALTER COLUMN new_cases float;




SELECT 
	Location, 
	population,
	MAX (total_cases)AS Highest_infection,
CASE
	WHEN population IS NULL  OR  Total_cases IS NULL 
	THEN NULL
	ELSE MAX ((Total_cases/population))*100  
	END AS Population_percentage_infected
FROM Covid_deaths
GROUP BY Location,population,total_cases
ORDER BY Population_percentage_infected DESC





SELECT 
	Location, 
	population,
	MAX (total_cases)AS Highest_infection,
	MAX (Total_cases/ NULLIF(population,0))*100   AS Population_percentage_infected
FROM Covid_deaths
WHERE Location LIKE 'United%'
GROUP BY Location,population,total_cases
ORDER BY Population_percentage_infected DESC


--showing Countries with Hghest death count per population 


SELECT 
	Location,  
	MAX(total_deaths) AS Highestdeathcount
FROM Covid_deaths
WHERE continent IS NOT NULL
GROUP  BY Location
ORDER BY Highestdeathcount DESC


--showing continents with highest deathcount per population

USE COVID;
SELECT 
	Continent,  
	MAX(total_deaths) AS Highestdeathcount
FROM Covid_deaths
WHERE continent IS NOT NULL
GROUP  BY continent
ORDER BY Highestdeathcount DESC

--Global Numbers

SELECT  Date, SUM(New_cases) AS Total_Cases,
		SUM(CAST(New_deaths AS INT)) AS total_deaths, 
		SUM(CAST(New_deaths AS INT))/SUM(NULLIF(New_cases, 0)) *100 AS Newdeathpercentage
FROM Covid_deaths
--WHERE Continent IS NOT NULL
GROUP BY Date
ORDER BY 1,2


SELECT  SUM(New_cases) AS Total_Cases,
		SUM(CAST(New_deaths AS INT)) AS total_deaths, 
		SUM(CAST(New_deaths AS INT))/SUM(NULLIF(New_cases, 0)) *100 AS Newdeathpercentage
FROM Covid_deaths
--GROUP BY Date
ORDER BY 1,2


--Merging Deaths and Vaccination Table

SELECT *
FROM Covid_Deaths CD
JOIN 
	Covid_Vaccinations CV
ON
	CD.location=CV.location
AND cd.date=CV.date


--Total Population VS Vaccination