/*
COVID 19 Data Exploration (Worldwide vs Vietnam) from 2020-02-24 to 2021-09-12

Data source: https://ourworldindata.org/covid-deaths

Skills used: Creating Views, Converting Data Types, Windows Functions, Aggregate Functions

*/

CREATE VIEW CovidDeathsByCountry AS
SELECT * FROM CovidDeaths
WHERE continent IS NOT NULL

SELECT * FROM CovidDeathsByCountry

-- Finding Top 10 Countries with the Highest Infection Percentage compared to Population
SELECT TOP 10 continent, location, population, MAX(CAST(total_cases AS INT)) AS TotalInfectionCount, 
		MAX((CAST(total_cases AS REAL)/CAST(population AS REAL))*100) AS InfectedPercentage
FROM CovidDeathsByCountry
GROUP BY continent, location, population
ORDER BY InfectedPercentage DESC 


-- Comparing the Infected Percentage Ranking of Vietnam and The United States
DROP VIEW WorldInfectedPercentage
CREATE VIEW WorldInfectedPercentage AS
		SELECT *, RANK() OVER(ORDER BY InfectedPercentage DESC) AS Rankings FROM (
				SELECT continent, location, population, MAX(CAST(total_cases AS INT)) AS TotalInfectionCount, 
				MAX((CAST(total_cases AS REAL)/CAST(population AS REAL))*100) AS InfectedPercentage
				FROM CovidDeathsByCountry
				GROUP BY continent, location, population) AS WMP

SELECT * FROM WorldInfectedPercentage WHERE location='Vietnam' 
UNION 
SELECT * FROM WorldInfectedPercentage WHERE location='United States'


-- Finding the Average Infected Percentage of continents
SELECT continent, AVG (InfectedPercentage) AS AverageInfectedPercentage FROM WorldInfectedPercentage
GROUP BY continent
ORDER BY 2 DESC


-- Finding Top 10 Countries with the Highest Death Count per Population 
SELECT TOP 10 continent, location, population, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM CovidDeathsByCountry
GROUP BY continent, location, population
ORDER BY 4 DESC


-- Comparing the Death Percentage Ranking of Vietnam and The United States
DROP VIEW WorldDeathPercentage
CREATE VIEW WorldDeathPercentage AS
		SELECT *, RANK() OVER(ORDER BY DeathPercentage DESC) AS Rankings FROM 
		(SELECT continent, location, population, MAX((CAST(total_deaths AS REAL)/CAST(population AS REAL))*100) AS DeathPercentage
		FROM CovidDeathsByCountry
		GROUP BY continent, location, population) AS WorldMaxDeathCount

SELECT * FROM WorldDeathPercentage WHERE location='Vietnam'
UNION 
SELECT * FROM WorldDeathPercentage WHERE location='United States'


-- Finding the Average Death Percentage of continents
SELECT continent, AVG (DeathPercentage) AS AverageDeathPercentage FROM WorldDeathPercentage
GROUP BY continent
ORDER BY 2 DESC


-- Finding vaccination doses given and the number of fully vaccinated people in Vietnam
DROP VIEW WorldVacByDate
CREATE VIEW WorldVacByDate AS
	SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations_smoothed AS NewVaccinations, 
	SUM(CAST(v.new_vaccinations_smoothed AS INT)) OVER (PARTITION BY d.location ORDER BY d.date) AS TotalVacByDate,
	v.people_fully_vaccinated,
	SUM(CAST(v.people_fully_vaccinated AS INT)) OVER (PARTITION BY d.location ORDER BY d.date) AS TotalFullyVaccinatedPeople
	FROM CovidDeathsByCountry d JOIN CovidVaccinations v
	ON d.location=v.location AND d.date=v.date
	WHERE new_vaccinations_smoothed	IS NOT NULL
	
SELECT * FROM WorldVacByDate WHERE location='Vietnam' 


-- Finding the number of vaccinations given each month in Southeast Asia
SELECT VacTime, [Brunei], [Myanmar], [Cambodia], [Timor], [Indonesia], [Laos], [Malaysia], 
		[Philippines], [Singapore], [Thailand], [Vietnam] FROM (
	SELECT continent, location, CAST(TotalVacByDate AS BIGINT) AS TotalVacByDateBIGINT, FORMAT(date, 'yyyy-MM') AS VacTime 
	FROM WorldVacByDate 
	WHERE continent='Asia') AS AsiaTotalVac
PIVOT (
	SUM(TotalVacByDateBIGINT)
	FOR location IN ([Brunei], [Myanmar], [Cambodia], [Indonesia], [Laos], [Malaysia], 
					[Philippines], [Singapore], [Thailand], [Timor], [Vietnam])
) AS pivot_table
ORDER BY VacTime ASC




















